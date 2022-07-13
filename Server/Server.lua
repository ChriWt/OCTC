local PortRequestMessage = require("Utils.PortRequestMessage")
local component = require("component")
local event = require("event")
local serialization = require("serialization")
local modem = component.modem
local gpu = component.gpu

local defaultPort = 1
local group = {
    sieve = {
        port = 2,
        priority = 2,
        endpoint = {}
    },
    farmer = 
    {
        port = 3,
        priority = 1,
        endpoint = {}
    }
}

function openPorts()
    modem.open(defaultPort)
    for key, value in pairs(group) do
        local port = group[key]["port"]
        modem.open(port)
    end
end

function startListening(port)
    displayStatus()
    setListener()
end

function displayStatus()
    local status = arePortsOpen()
    local text = "SERVER STATUS: "
    if status then
        text = text .. "Online"
    else
        text = text .. "Offline"
    end
    gpu.set(1, 1, text)
end

function arePortsOpen()
    for key, value in pairs(group) do
        if not modem.isOpen(group[key]["port"]) then
            return false
        end
    end
    return modem.isOpen(defaultPort)
end

function setListener()
    event.listen("modem_message", eventHandler)
end

function eventHandler(...)
    local type, receiver, sender, port, distance, message = ...
    handleEventByPort(port, message)
end

function handleEventByPort(port, message)
    if port == 1 then
        portRequestHandler(message)
    end
end

function portRequestHandler(message)
    local portRequest = PortRequestMessage:newFromSerialize(message)

    local requestGroup = portRequest:getGroup()
    local port = group[requestGroup]["port"]

    local portResponce = PortRequestMessage:new("responce", requestGroup)
    portResponce:setPort(port)

    modem.send(portRequest:getAddress(), 1, portResponce:serialize())
end

gpu.fill(1, 1, 160, 50, " ")
openPorts()
startListening(defaultPort)