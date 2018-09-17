local tools = require "waf/tools"
local regex = require "resty.core.regex"
local cjson = require "cjson";
local engine = require "waf/waf_engine"

local _M = {}

local mt = {  __index = _M }
local get_headers = ngx.req.get_headers

function _M.new()
    local t = {
        var = {},
    }
    return setmetatable(t, mt)
end

function _M.upload_check(self)
    ngx.req.read_body()
    local data = ngx.req.get_body_data()
    print(data)
    return false
end

-- main function
function _M.check(self)
    if self:upload_check() then
        return ngx.exit(ngx.HTTP_BAD_REQUEST)
    end
    -- if all rule pass
    return true
end

return _M