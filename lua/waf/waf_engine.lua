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
    self.cookie = ck:new()
    self.cookies = self.cookie:get_all()
    self.method = ngx.req.get_method()

    if method == "POST" then
        ngx.req.read_body()
        self.post_args, err = ngx.req.get_post_args()
    end

    local rule_check_flag = true
    return self:parser(rule)
end

function _M.parser(self, lex)
    ngx.log(ngx.INFO, "--------"..lex['key'].."--------")
    local c_flag = false
    if lex['key'] == 'method' then
        ngx.log(ngx.INFO, "method check")
        local vlist = split(lex['value'], ':')
        if vlist[1] == 'belong' then
            belong_list = split(string.sub(vlist[2], 2, -2), ',')
            local _match = false
            for _, bv in pairs(belong_list) do
                if string.lower(bv) == string.lower(self.method) then
                    _match = true
                    if (lex['flag'] == 's') then
                        return true
                    elseif (lex['flag'] == 'c') then
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
    if lex['key'] == 'uri' then
        ngx.log(ngx.INFO, "uri check")
        local vlist = split(lex['value'], ':')
        -- regex match
        if vlist[1] == 'co' then
            if rulematch(self.uri, vlist[2], "jo") then
                if (lex['flag'] == 's') then
                    return true
                elseif (lex['flag'] == 'c') then
                    c_flag = true
                end
            else
                return false
            end
        elseif vlist[1] == 'eq' then
            if vlist[2] == self.uri then
                if (lex['flag'] == 's') then
                    return true
                elseif (lex['flag'] == 'c') then
                    c_flag = true
                end
            else
                return false
            end
        end
    end
    if lex['key'] == 'arg' then
        ngx.log(ngx.INFO, "arg check")
        local vlist = split(lex['value'], ':')
        local arg_flag = false
        -- regex match
        if vlist[1] == 'co' then
            for _arg_name, _arg_value in pairs(self.args) do
                if rulematch(_arg_value, vlist[2], "jo") then
                    arg_flag = true
                    if (lex['flag'] == 's') then
                        return true
                    elseif (lex['flag'] == 'c') then
                        c_flag = true
                    end
                end
            end
        elseif vlist[1] == 'eq' then
            for _arg_name, _arg_value in pairs(self.args) do
                if vlist[2] == _arg_value then
                    arg_flag = true
                    if (lex['flag'] == 's') then
                        return true
                    elseif (lex['flag'] == 'c') then
                        c_flag = true
                    end
                end
            end
        end
        if not arg_flag then
            return false
        end
    end
    if lex['key'] == 'cookie' then
        ngx.log(ngx.INFO, "cookie check")
        local vlist = split(lex['value'], ':')
        local cookie_flag = false
        -- regex match
        if vlist[1] == 'co' then
            for _cookie_name, _cookie_value in pairs(self.cookies) do
                if rulematch(_cookie_value, vlist[2], "jo") then
                    cookie_flag = true
                    if (lex['flag'] == 's') then
                        return true
                    elseif (lex['flag'] == 'c') then
                        c_flag = true
                    end
                end
            end
        elseif vlist[1] == 'eq' then
            for _cookie_name, _cookie_value in pairs(self.cookies) do
                if vlist[2] == _cookie_value then
                    cookie_flag = true
                    if (lex['flag'] == 's') then
                        return true
                    elseif (lex['flag'] == 'c') then
                        c_flag = true
                    end
                end
            end
        end
        if not cookie_flag then
            return false
        end
    end
    -- this is for multiline check. and you can think it is "&"
    if lex['key'] == 'multiline' then
        ngx.log(ngx.INFO, "multiline check")
        local mulit_flag = true
        for _, lv in pairs(lex['value']) do
            mulit_flag = (mulit_flag and self:parser(lv))
            print(mulit_flag)
        end
        if mulit_flag then
            if(lex['flag'] == 's') then
                return true
            elseif(lex['flag'] == 'c') then
                c_flag = true
            end
        else
            return false
        end
    end
    -- this is for single continue check. and you can think it is "|"
    if (c_flag) then
        local v_flag = false
        for _, lv in pairs(lex['next']) do
            v_flag = (v_flag or self:parser(lv))
            ngx.log(ngx.DEBUG, "current flag: ", v_flag)
            -- break and do not go next check
            if(v_flag == true) then
                return v_flag
            end
        end
    end
    -- if no match return false
    return false
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
