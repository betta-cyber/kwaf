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
    local method = ngx.req.get_method()

    if method == "POST" then
        ngx.req.read_body()
        local post_args, err = ngx.req.get_post_args()
    end

    local rule_check_flag = false

    for k, v in pairs(rule) do
        local rule_part_flag = false
        if k == 'method' then
            local method_flag = false
            local _method = string.lower(method)
            -- waf http method check
            if (v['match'] == 'eq') then
                for _, method_v in pairs(v['value']) do
                    if method_v == _method then
                        method_flag = true
                    end
                end
            end
            if (v['match'] == 'co') then
                for _, method_v in pairs(v['value']) do
                    if rulematch(_method, method_v, "jo") then
                        method_flag = true
                    end
                end
            end
            if not method_flag then
                goto continue
            end
        end
        -- waf check uri part
        if k == 'uri' then
            print(v['match'])
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
        ::continue::
        if not rule_part_flag then
            rule_check_flag = true
        end
    end
    return false
end

return _M
