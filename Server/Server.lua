package.path = package.path .. ";../?.lua"
local PortRequestMessage = require("Utils.PortRequestMessage")
local component = require("component")
local event = require("event")
local modem = component.modem

Server = { 
    defaultPort = 1,
    group = {
        sieve = {
            port = 2,
            priority = 2,
            endpoint = {}
        },
            farmer = {
            port = 3,
            priority = 1,
            endpoint = {}
        }
    }
}
Server.__index = Server

function Server:new()
    local server = {}
    setmetatable(server, Server)
    return server
end

function Server:start()
    print("Starting...")
    self:openPorts()
    return self:startListening()
end

function Server:openPorts()
    modem.open(self.defaultPort)
    for key, _value in pairs(self.group) do
        local port = self.group[key]["port"]
        modem.open(port)
    end
    print("Ports opened")
end

function Server:startListening()
    return event.listen("modem_message", function (...) self:eventHandler(...) end)
end

function Server:eventHandler(...)
    local _type, _receiver, _sender, port, _distance, message = ...
    print("Received message:")
    self:handleMessage(port, message)
end

function Server:handleMessage(port, message)
    if port == 1 then
        print("Type: port request")
        self:portRequestHandler(message)
    end
end

function Server:portRequestHandler(request)
    local portRequest = PortRequestMessage:newFromSerialize(request)

    local requestGroup = portRequest:getGroup()
    local port = self.group[requestGroup]["port"]

    local portResponce = PortRequestMessage:new(PortRequestMessage.RESPONCE, requestGroup)
    portResponce:setPort(port)

    modem.send(portRequest:getAddress(), 1, portResponce:serialize())
    print("Sent port (" .. tostring(port) .. ") to " .. portRequest:getAddress())
end

function Server:stop(eventID)
    print("Stopping...")
    local isServerStopped = event.cancel(eventID)
    print("Server " .. (isServerStopped and "stopped listening" or "wasn't up"))
    self:closePorts()
end

function Server:closePorts()
    modem.close(self.defaultPort)
    for key, _value in pairs(self.group) do
        local port = self.group[key]["port"]
        modem.close(port)
    end
    print("Ports closed")
end

return Server