package.path = package.path .. ";../?.lua"
local PortRequestMessage = require("Utils.PortRequestMessage")
local component = require("component")
local event = require("event")
local modem = component.modem

local TIMEOUT = 5

local defaultPort = 1

Client = { 
    group = "", 
    serverAddress = "", 
    port = nil, 
    _eventListenerID = nil,
    _eventTimerID = nil,
    _connected = false
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
    if self._connected then
        print("Connected")
    else
        print("No Connection...")
    end
end

function Client:askGroupPort()
    print("Asking server for the port for group: " .. self.group)
    local message = PortRequestMessage:new(PortRequestMessage.REQUEST, self.group)
    print("Broadcasting request...")
    modem.broadcast(defaultPort, message:serialize())
    print("Opening port " .. tostring(defaultPort))
    modem.open(defaultPort)
    print("Waiting for responce..")
    self:waitForServerResponce()
    modem.close(defaultPort)
end

function Client:waitForServerResponce()
    local sender, responce = self:getSenderAndMessage(event.pull(TIMEOUT, "modem_message"))
    if responce == nil then
        print("Timeout: Could not establish a connection with server")
        self._connected = false
        return
    else
        local unserializedMessage = self:messageToObj(responce)
        if self:isResponce(unserializedMessage) then
            print("Server " .. sender .. " responded with port " .. tostring(unserializedMessage:getPort()))
            self.serverAddress = sender
            self.port = unserializedMessage:getPort()
            self._connected = true
            return
        else
            return self:waitForServerResponce()
        end
    end
end

function Client:getSenderAndMessage(...)
    local _type, _receiver, sender, port, _distance, message = ...
    return sender, message
end

function Client:messageToObj(message)
    return PortRequestMessage:newFromSerialize(message)
end

function Client:isResponce(obj)
    return obj:getType() == PortRequestMessage.RESPONCE
end

return Client