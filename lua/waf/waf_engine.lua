require "waf/tools"
require "resty.core.regex"
local ck = require "resty.cookie"

local rulematch = ngx.re.find

local _M = {}

local mt = {  __index = _M }
local get_headers = ngx.req.get_headers

function _M.new()
    local t = {
        var = {},
    }
    return setmetatable(t, mt)
end


function _M.run(self, rule)
    local header = get_headers()
    local args = ngx.req.get_uri_args()
    local uri = ngx.var.uri
    local cookie = ck:new()
    local cookies = cookie:get_all()
    if ngx.req.get_method() == "POST" then
        ngx.req.read_body()
        local post_args, err = ngx.req.get_post_args()
    end

    for k, v in pairs(rule) do
        -- waf check uri part
        if k == 'uri' then
            if (v["match"] == 'co') then
                if rulematch(uri, v["value"], "jo") then
                    return true
                end
            end
            if (v["match"] == 'eq') then
                print(uri)
                if v["value"] == uri then
                    return true
                end
            end
        end
        -- waf check arg part
        if k == 'arg' then
            if (v["match"] == 'co') then
                for key, value in pairs(args) do
                    if rulematch(value, v["value"], "jo") then
                        return true
                    end
                end
            end
            if (v["match"] == 'eq') then
                for key, value in pairs(args) do
                    if v["value"] == value then
                        return true
                    end
                end
            end
        end
        -- waf check cookie part
    end
    return false
end

return _M
