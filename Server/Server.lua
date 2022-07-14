package.path = package.path .. ";../?.lua"
--local PortRequestMessage = require("Utils.PortRequestMessage")
local Response = require("Utils.Response")
local Request = require("Utils.Request")
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
    },
    ports = {
        sieve = 2,
        farmer = 3
    }
}
Server.__index = Server
Server.OK = 200
Server.NOT_FOUND = 404

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
    local _type, _receiver, sender, _port, _distance, message = ...
    print("Received message:")
    self:handleMessage(sender, message)
end

function Server:handleMessage(sender, message)
    local request = Request:unserialize(message)
    if request.method == Request.GET then
        self:handleGET(sender, request)
    end
end

function Server:handleGET(sender, request)
    local resource = self:_getResource(request.uri)
    local port = request.head.host

    local response = Response:new()
    response:setCode(resource ~= nil and self.OK or self.NOT_FOUND)
    response:setBody({value = resource})
    print("VALORE: ", resource)
    modem.send(sender, port, response:serialize())
end

function Server:_getResource(uri)
    local resource = self 
    for element in string.gmatch(uri, "([^/]+)") do
        print("GET RES", element)
        if resource == nil then
            return nil
        end
        resource = resource[element]
    end 
    return resource
end

-- function Server:handleMessage(port, request)
    -- if port == 1 then
    --     print("Type: port request")
    --     self:portRequestHandler(request)
    -- end
-- end

-- function Server:portRequestHandler(request)
--     local portRequest = PortRequestMessage:newFromSerialize(request)

--     local requestGroup = portRequest:getGroup()
--     local port = self.group[requestGroup]["port"]

--     local portResponce = PortRequestMessage:new(PortRequestMessage.RESPONCE, requestGroup)
--     portResponce:setPort(port)

--     modem.send(portRequest:getAddress(), self.defaultPort, portResponce:serialize())
--     print("Sent port (" .. tostring(port) .. ") to " .. portRequest:getAddress())
-- end

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