local serialization = require("serialization")

Request = {}

Request.__index = Request
Request.GET = "get"
Request.HEAD = "head"
Request.POST = "post"
Request.PUT = "put"
Request.DELETE = "delete"
Request.PATCH = "patch"

function Request:new(method, uri, port)
    if not self:isValideMethod(method) then
        error("Request method is not valid", 2)
    end

    local request = {}
    setmetatable(request, Request) 

    request.method = method
    request.uri = uri
    request.port = port
    request.head = {
        host = nil,
        port = nil
    }
    request.body = {}

    return request
end

function Request:setHost(host)
    self.head.host = host
end

function Request:setBody(body)
    self.body = body
end

function Request:isValideMethod(method)
    return  method == self.GET or 
            method == self.HEAD or 
            method == self.POST or 
            method == self.PUT or
            method == self.DELETE or
            method == self.PATCH
end

function Request:unserialize(request)
    if request == nil then
        error("Can't unserialize Request. Request is nil")
    end
    return serialization.unserialize(request)
end

function Request:serialize()
    return serialization.serialize(self)
end

return Request