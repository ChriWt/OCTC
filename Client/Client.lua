local PortRequestMessage = require("utils.PortRequestMessage")
local component = require("component")
local event = require("event")
local modem = component.modem

local TIMEOUT = 5
local WAIT_TIME = 0.05

local defaultPort = 1

Client = { group = "", serverAddress = "", port = nil }
Client.__index = Client

function Client:new(group)
    local client = {}
    setmetatable(client, Client)

    client.group = group

    return client
end

function Client:connect()
    self:askPort()
end

function Client:askPort()
    local message = PortRequestMessage:new("request", self.group)
    modem.broadcast(defaultPort, message:serialize())
    self.eventListenerID = event.listen("modem_message", function(...) self:eventHandler(...) end)
    self.eventTimerID = event.timer(WAIT_TIME, function() self:checkIfConnected() end, TIMEOUT / WAIT_TIME)
end

function Client:eventHandler(...)
    local _, _, sender, _, _, message = ...
    local responce = PortRequestMessage:newFromSerialize(message)
    if responce:getType() == PortRequestMessage.RESPONCE then
        self.serverAddress = sender
        self.port = responce:getPort()
        event.cancel(self.eventListenerID)
    end
end

function Client:checkIfConnected()
    if self.port ~= nil then
        event.cancel(self.eventTimerID)
        print("Connected to server: ", self.serverAddress, "port", self.port)
    end
end

return Client