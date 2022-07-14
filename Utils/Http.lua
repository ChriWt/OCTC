local component = require("component")
local Responce = require("Response")
local event = require("event")
local modem = component.modem

if modem == nil then
    error("Modem is required")
end

Http = {
    defaultPort = nil, 
    modemMessage = "modem_message",
    _eventListenerID = nil,
    _eventTimerID = nil
}
Http.__index = Http

function Http:new(defaultPort)
    local http = {}
    setmetatable(http, Http)

    http.defaultPort = defaultPort

    return http
end

function Http:sendRequest(request, callback, timeout)
    local address = request.head.host
    local port = request.head.port or self.defaultPort

    print("Sending...")
    local isSent = self:_send(address, port, request) 
    if isSent then
        self._eventTimerID = event.timer(timeout, function () self:_onServerResponse(callback, port, nil) end, 1)
        self:_listen(self.modemMessage, port, callback)
    else
        print("Could not send request to server")
    end
end

function Http:_send(address, port, request)
    if address == nil then 
        return modem.broadcast(port, request)
    end
    modem.send(address, port, request)
end

function Http:_listen(messageType, port, callback)
    print("Start listening for a response")
    modem.open(self.defaultPort)
    self._eventListenerID = event.listen(
        messageType, 
        function (...) self:_onServerResponse(callback, port, ...) end
    )
end

function Http:_onServerResponse(callback, port, ...)
    print("On server response")
    self:_closePortsAndEvents(port)
    callback(...)
end

function Http:_closePortsAndEvents(port)
    print("closing: listener", self._eventListenerID, "timer", self._eventTimerID, "port", port)
    event.cancel(self._eventTimerID)
    event.cancel(self._eventListenerID)
    modem.close(port)
end
