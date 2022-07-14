local component = require("component")
local event = require("event")
local modem = component.modem

if modem == nil then
    error("Modem is required")
end

Http = {
    defaultPort = 1, 
    modemMessage = "modem_message",
    _eventListenerID = nil,
    _eventTimerID = nil,
    _port = nil
}
Http.__index = Http

function Http:new()
    local http = {}
    setmetatable(http, Http)

    return http
end

function Http:sendRequest(request, callback, timeout)
    local address = request.head.host
    self._port = request.head.port or self.defaultPort

    print("Sending...")
    local isSent = self:_send(address, request) 
    if isSent then
        self:_setTimeoutEventHandler(timeout, callback)
        self:_listen(self.modemMessage, callback)
    else
        print("Could not send request to server")
    end
end

function Http:_send(address, request)
    if address == nil then 
        return modem.broadcast(self._port, request:serialize())
    end
    modem.send(address, self._port, request)
end

function Http:_setTimeoutEventHandler(timeout, callback)
    local repetition = 1
    self._eventTimerID = event.timer(
        timeout, 
        function () self:_onServerResponse(callback, nil) end, 
        repetition
    )
end

function Http:_listen(messageType, callback)
    print("Start listening for a response")
    
    modem.open(self.defaultPort)

    self._eventListenerID = event.listen(
        messageType, 
        function (...) self:_onServerResponse(callback, ...) end
    )
end

function Http:_onServerResponse(callback, ...)
    print("On server response")

    self:_closePortsAndEvents()
    callback(...)
end

function Http:_closePortsAndEvents()
    print("closing: listener", self._eventListenerID, "timer", self._eventTimerID, "port", self._port)

    event.cancel(self._eventTimerID)
    event.cancel(self._eventListenerID)
    modem.close(self._port)

    self._eventListenerID = nil
    self._eventTimerID = nil
    self._port = nil
end

return Http