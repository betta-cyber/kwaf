require "waf/tools"
require "resty.core.regex"
local ck = require "resty.cookie"

local rulematch = ngx.re.find

local _M = {
    _VERSION = "0.0.1"
}

local mt = {  __index = _M }
local get_headers = ngx.req.get_headers

function _M.new()
    local t = {
        var = {},
    }
    return setmetatable(t, mt)
end


function _M.run(self, rule)
    self.headers = get_headers()
    self.args = ngx.req.get_uri_args()
    self.uri = ngx.var.uri
    self.cookie = ck:new()
    self.cookies = self.cookie:get_all()
    self.method = ngx.req.get_method()

    if method == "POST" then
        ngx.req.read_body()
        self.post_args, err = ngx.req.get_post_args()
    end

    return self:parser(rule)
end

-- v1 input value
-- v2 rule value
-- keyword
function _M.syntax(self, keyword, v1, v2)
    if keyword == 'belong' then
        belong_list = split(string.sub(v2, 2, -2), ',')
        for _, bv in pairs(belong_list) do
            if string.lower(bv) == string.lower(v1) then
                return true
            end
        end
    elseif keyword == 'eq' then
        if string.lower(v1) == string.lower(v2) then
            return true
        end
    elseif keyword == 're' then
        if rulematch(v1, v2, "jo") then
            return true
        end
    end
    return false
end

-- todo:
-- need add not regular and not equal and exists and not exists and not belong
-- and type and between and length between and count between

function _M.parser(self, lex)
    ngx.log(ngx.INFO, "--------"..lex['key'].."--------")
    -- c flag means continue , if c flag is true, this rule will go on to check
    -- and we need to get the "next" rule result, if next Conditions return true
    -- this rule return true.
    -- if the rule content flag is s, means we will stop at this node, no need to
    -- check continue, just return current node check result.
    local c_flag = false
    -- method check
    if lex['key'] == 'method' then
        ngx.log(ngx.INFO, "method check")
        local vlist = split(lex['value'], ':')
        local _match = self:syntax(vlist[1], self.method, vlist[2])
        if _match then
            if (lex['flag'] == 's') then
                return true
            elseif (lex['flag'] == 'c') then
                c_flag = true
            end
        end
        -- not match
        if( _match == false) then
            return false
        end
    end
    -- this conditions is for uri.
    -- uri check
    if lex['key'] == 'uri' then
        ngx.log(ngx.INFO, "uri check")
        local vlist = split(lex['value'], ':')
        local _match = self:syntax(vlist[1], self.uri, vlist[2])
        -- match rule
        if _match then
            if (lex['flag'] == 's') then
                return true
            elseif (lex['flag'] == 'c') then
                c_flag = true
            end
        end
        -- not match
        if( _match == false) then
            return false
        end
    end
    -- this conditions is for args.
    -- include check for arg name and arg value.
    if lex['key'] == 'arg' or lex['key'] == 'arg-name' then
        ngx.log(ngx.INFO, lex['key'].." check")
        local vlist = split(lex['value'], ':')
        local arg_flag = false

        for _arg_name, _arg_value in pairs(self.args) do
            -- check for arg name
            if lex['key'] == 'arg-name' then
                check_v = _arg_name
            -- check for arg value
            else
                check_v = _arg_value
            end
            local _match = self:syntax(vlist[1], check_v, vlist[2])
            if _match then
                arg_flag = true
                if (lex['flag'] == 's') then
                    return true
                elseif (lex['flag'] == 'c') then
                    c_flag = true
                end
            end
        end
        if not arg_flag then
            return false
        end
    end
    -- this Conditions is for cookies.
    -- include check for cookie name and cookie value.
    if lex['key'] == 'cookie' or lex['key'] == 'cookie_name' then
        ngx.log(ngx.INFO, lex['key'].." check")
        local vlist = split(lex['value'], ':')
        local cookie_flag = false
        
        for _cookie_name, _cookie_value in pairs(self.cookies) do
            if (lex['key'] == 'cookie_name') then
                check_v = _cookie_name
            else
                check_v = _cookie_value
            end
            local _match = self:syntax(vlist[1], check_v, vlist[2])
            if _match then
                cookie_flag = true
                if (lex['flag'] == 's') then
                    return true
                elseif (lex['flag'] == 'c') then
                    c_flag = true
                end
            end
        end
        if not cookie_flag then
            return false
        end
    end
    -- header check
    if lex['key'] == 'header' or lex['key'] == 'header_name' then
        ngx.log(ngx.INFO, lex['key'].." check")
        local vlist = split(lex['value'], ':')
        local header_flag = false

        for _header_name, _header_value in pairs(self.headers) do
            if (lex['key'] == 'header_name') then
                check_v = _header_name
            else
                check_v = _header_value
            end
            local _match = self:syntax(vlist[1], check_v, vlist[2])
            if _match then
                header_flag = true
                if (lex['flag'] == 's') then
                    return true
                elseif (lex['flag'] == 'c') then
                    c_flag = true
                end
            end
        end
        if not header_flag then
            return false
        end
    end
    -- this is single check. and you can think it is "or"
    if lex['key'] == 'single' then
        ngx.log(ngx.INFO, "single check")
        local single_flag = false
        for _, lv in pairs(lex['value']) do
            single_flag = (single_flag or self:parser(lv))
            ngx.log(ngx.DEBUG, "current single flag: ", single_flag)
        end
        if single_flag then
            if(lex['flag'] == 's') then
                return true
            elseif(lex['flag'] == 'c') then
                c_flag = true
            end
        else
            return false
        end
    end
    -- this is for multiline check. and you can think it is "and"
    if lex['key'] == 'multiline' then
        ngx.log(ngx.INFO, "multiline check")
        local mulit_flag = true
        for _, lv in pairs(lex['value']) do
            mulit_flag = (mulit_flag and self:parser(lv))
            ngx.log(ngx.DEBUG, "current mulit flag: ", mulit_flag)
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
            ngx.log(ngx.DEBUG, "current c_flag: ", v_flag)
            -- break and do not go next check
            if(v_flag == true) then
                return v_flag
            end
        end
    end
    -- if no match return false
    return false
end

return _M
