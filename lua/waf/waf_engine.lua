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
    self.header = get_headers()
    self.args = ngx.req.get_uri_args()
    self.uri = ngx.var.uri
    local cookie = ck:new()
    self.cookies = cookie:get_all()
    self.method = ngx.req.get_method()

    if method == "POST" then
        ngx.req.read_body()
        self.post_args, err = ngx.req.get_post_args()
    end

    local rule_check_flag = true
    self:parser(rule)

end

function _M.parser(self, lex)
    print("--------")
    tprint(lex)
    for k, v in pairs(lex) do
        local c_flag = false
        if k == 'method' then
            local vlist = split(v['value'], ':')
            if vlist[1] == 'belong' then
                belong_list = split(string.sub(vlist[2], 2, -2), ',')
                local _match = false
                for _, bv in pairs(belong_list) do
                    if string.lower(bv) == string.lower(self.method) then
                        _match = true
                        if (v['flag'] == 's') then
                            return true
                        elseif (v['flag'] == 'c') then
                            c_flag = true
                            break
                        end
                    end
                end
                -- not belong
                if( _match == false) then
                    return false
                end
            end
        end
        if k == 'uri' then
            print("dddd")
        end
        if k == 'multiline' then
            print("multiline")
        end
        if k == 'cookie' then
            print("cookie")
        end
        if (c_flag) then
            local v_flag = false
            for lk, lv in pairs(v['next']) do
                v_flag = (v_flag or self:parser(lv))
            end
            return v_flag
        end
    end
end

    -- for k, v in pairs(rule) do
        -- local rule_part_flag = false
        -- if k == 'method' then
            -- local method_flag = false
            -- local _method = string.lower(method)
            -- -- waf http method check
            -- if (v['match'] == 'eq') then
                -- for _, method_v in pairs(v['value']) do
                    -- if method_v == _method then
                        -- if (v["flag"] == 'b') then
                            -- return true
                        -- elseif(v["flag"] == 'c') then
                            -- rule_part_flag = true
                        -- end
                    -- end
                -- end
            -- elseif (v['match'] == 'co') then
                -- for _, method_v in pairs(v['value']) do
                    -- if rulematch(_method, method_v, "jo") then
                        -- if (v["flag"] == 'b') then
                            -- return true
                        -- elseif(v["flag"] == 'c') then
                            -- rule_part_flag = true
                        -- end
                    -- end
                -- end
            -- end
        -- -- waf check uri part
        -- elseif k == 'uri' then
            -- if (v["match"] == 'co') then
                -- if rulematch(uri, v["value"], "jo") then
                    -- if (v["flag"] == 'b') then
                        -- return true
                    -- elseif(v["flag"] == 'c') then
                        -- rule_part_flag = true
                    -- end
                -- end
            -- end
            -- if (v["match"] == 'eq') then
                -- if v["value"] == uri then
                    -- if (v["flag"] == 'b') then
                        -- return true
                    -- elseif(v["flag"] == 'c') then
                        -- rule_part_flag = true
                    -- end
                -- end
            -- end
        -- -- waf check arg part
        -- elseif k == 'arg' then
            -- if (v["match"] == 'co') then
                -- for key, value in pairs(args) do
                    -- if rulematch(value, v["value"], "jo") then
                        -- rule_part_flag = true
                        -- if (v["flag"] == 'b') then
                            -- return true
                        -- end
                    -- end
                -- end
            -- end
            -- if (v["match"] == 'eq') then
                -- for key, value in pairs(args) do
                    -- if v["value"] == value then
                        -- rule_part_flag = true
                        -- if (v["flag"] == 'b') then
                            -- return true
                        -- end
                    -- end
                -- end
            -- end
        -- -- waf check cookie part
        -- elseif k == 'cookie' then
            -- print(111)
            -- if (v["match"] == 'co') then
                -- for key, value in pairs(cookies) do
                    -- print(value)
                    -- print(v["value"])
                    -- if rulematch(value, v["value"], "jo") then
                        -- rule_part_flag = true
                        -- if (v["flag"] == 'b') then
                            -- return true
                        -- end
                    -- end
                -- end
            -- end
            -- if (v["match"] == 'eq') then
                -- for key, value in pairs(cookies) do
                    -- if v["value"] == value then
                        -- rule_part_flag = true
                        -- if (v["flag"] == 'b') then
                            -- return true
                        -- end
                    -- end
                -- end
            -- end
        -- end
        -- print(rule_part_flag)
        -- if not rule_part_flag then
            -- rule_check_flag = false
            -- -- break loop
            -- break
        -- end
    -- end
    -- return rule_check_flag

return _M
