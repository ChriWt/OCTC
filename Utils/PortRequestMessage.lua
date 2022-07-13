local serializer = require("serialization")
local component = require("component")
local modem = component.modem

PortRequestMessage = {
    RESPONCE = "responce",
    REQUEST = "request",
    type = "",
    address = "",
    group = "",
    port = nil,
}

PortRequestMessage.__index = PortRequestMessage

function PortRequestMessage:new(type, group)
    local message = {}
    setmetatable(message, PortRequestMessage)

    message.type = type
    message.address = modem.address
    message.group = group

    return message
end

function PortRequestMessage:newFromSerialize(object)
    local message = serializer.unserialize(object) or {}
    setmetatable(message, PortRequestMessage)
    return message
end

function PortRequestMessage:serialize()
    return serializer.serialize(self)
end

function PortRequestMessage:getAddress()
    return self.address
end

function PortRequestMessage:getType()
    return self.type
end

function PortRequestMessage:getGroup()
    return self.group
end

function PortRequestMessage:setPort(port)
    self.port = port
end

return PortRequestMessage