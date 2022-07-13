package.path = package.path .. ";../?.lua"
local PortRequestMessage = require("Utils.PortRequestMessage")
local component = require("component")
local event = require("event")
local modem = component.modem
-- local gpu = component.gpu

local TIMEOUT = 5

local defaultPort = 1

Client = { 
    group = "", 
    serverAddress = "", 
    port = nil, 
    _eventListenerID = nil,
    _eventTimerID = nil
}
Client.__index = Client

function Client:new(group)
    local client = {}
    setmetatable(client, Client)

    client.group = group

    return client
end

function Client:connect()
    print("Connecting...")
    self:askGroupPort()
end

function Client:askGroupPort()
    print("Asking server for the port for group: " .. self.group)
    local message = PortRequestMessage:new(PortRequestMessage.REQUEST, self.group)
    print("Broadcasting request...")
    modem.broadcast(defaultPort, message:serialize())
    print("Opening port " .. tostring(defaultPort))
    modem.open(defaultPort)
    self._eventListenerID = event.listen("modem_message", function(...) self:eventHandler(...) end)
    self._eventTimerID = event.timer(TIMEOUT, function() self:checkIfConnected() end, 1)
end

function Client:eventHandler(...)
    local _type, _receiver, sender, port, _distance, message = ...
    local responce = PortRequestMessage:newFromSerialize(message)
    print("Received message from " .. sender .. " of type (" .. responce:getType() .. ")")
    if responce:getType() == PortRequestMessage.RESPONCE then
        self.serverAddress = sender
        self.port = responce:getPort()
        self:_closePortAndListeners(defaultPort)
    end
end

function Client:checkIfConnected()
    if self.port ~= nil then 
        print("Connected to server: ", self.serverAddress, "port", self.port)
    else 
        print("TIMEOUT: Could not connect to server")
    end
    self:_closePortAndListeners(defaultPort)
end

function Client:_closePortAndListeners(port)
    print("Closing ports and listeners...")
    event.cancel(self._eventListenerID)
    event.cancel(self._eventTimerID)
    modem.close(port)
end

return Client