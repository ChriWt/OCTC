package.path = package.path .. ";../?.lua"
local PortRequestMessage = require("Utils.PortRequestMessage")
local Http = require("Utils.Http")
local Request = require("Utils.Request")
local component = require("component")
local event = require("event")
local Response = require("Utils.Response")
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

function Client:connect(adress, port)
    self:__checkIfServerIsReachable(adress, port)
end

function Client:__connect(adress, port)
    if adress ~= "" and port ~= defaultPort then
        self:__searchServer(adress, port)
    else
        self:__searchServer()
    end
end

function Client:__searchServer(address, port)
    
end

function Client:__searchServer()
    
end

function Client:__checkIfServerIsReachable(adress, port)
    local serverAddress = adress or ""
    local port = port or defaultPort
    
    if self.serverAddress == "" then
        self:__connect(serverAddress, port)
    else
        self:__askServerStatus()
    end
end

function Client:__askServerStatus()
    local http = Http:new()
    local request = Request:new(Request.GET, "status", defaultPort)
    http:sendRequest(request, function (...) Client:__onServerStatusResponce(...) end, TIMEOUT)
end

function Client:__onServerStatusResponce(responce)
    print(responce)
    if responce == nil then
        print("No server could be reached")
    else
        local serverResponce = Response:unserialize(responce)
        if serverResponce.code == Codes.OK then
            print(serverResponce:serialize())
        end
    end
end

-- function Client:connect()
--     print("Connecting...")
--     self:askGroupPort()
--     if self._connected then
--         print("Connected")
--     else
--         print("No Connection...")
--     end
-- end

-- function Client:askGroupPort()
--     print("Asking server for the port for group: " .. self.group)
--     local message = PortRequestMessage:new(PortRequestMessage.REQUEST, self.group)

--     print("Broadcasting request...")
--     modem.broadcast(defaultPort, message:serialize())

--     print("Opening port " .. tostring(defaultPort))
--     modem.open(defaultPort)

--     print("Waiting for responce..")
--     self:waitForServerResponce()

--     modem.close(defaultPort)
-- end

-- function Client:waitForServerResponce()
--     local sender, responce = self:getSenderAndMessage(event.pull(TIMEOUT, "modem_message"))

--     if responce == nil then
--         print("Timeout: Could not establish a connection with server")
--         self._connected = false
--     else
--         local unserializedMessage = self:messageToObj(responce)
--         self:handleMessage(sender, unserializedMessage)
--     end
-- end

-- function Client:handleMessage(sender, message)
--     if self:isServerResponce(message) then
--         print("Server " .. sender .. " responded with port " .. tostring(message:getPort()))
--         self.serverAddress = sender
--         self.port = message:getPort()
--         self._connected = true
--     else
--         self:waitForServerResponce()
--     end
-- end

-- function Client:getSenderAndMessage(...)
--     local _type, _receiver, sender, port, _distance, message = ...
--     return sender, message
-- end

-- function Client:messageToObj(message)
--     return PortRequestMessage:newFromSerialize(message)
-- end

-- function Client:isServerResponce(obj)
--     return obj:getType() == PortRequestMessage.RESPONCE
-- end

function Client:sendMessageToServer(message)
     
end

return Client