local serialization = require("serialization")

Response = {
    code = nil,
    body = nil
}
Response.__index = Response

function Response:new()
    local response = {}
    setmetatable(response, Response)

    return response
end

function Response:setCode(code)
    self.code = code
end

function Response:setBody(body)
    self.body = body
end

function Response:unserialize(request)
    if request == nil then
        error("Can't unserialize Request. Request is nil")
    end
    return serialization.unserialize(request)
end

function Response:serialize()
    return serialization.serialize(self)
end

return Response