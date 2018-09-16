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

function _M.xss_rule()
    local XSS_RULES_JSON = get_rule('xss')
    local XSS_RULES = cjson.decode(XSS_RULES_JSON);
    local waf_engine = engine:new()
    for _, rule in pairs(XSS_RULES) do
        if rule.enable then
            ngx.log(ngx.INFO, "start rule id "..rule.rule_id)
            xss_res = waf_engine:run(rule.content)
            if xss_res then
                ngx.log(ngx.INFO, "!!! rule match "..rule.rule_id)
                return true
            end
        end
    end
    return false
end

function _M.sql_injection()
    local SQL_INJECTION_RULES_JSON = get_rule('sql_injection')
    local SQL_INJECTION_RULES = cjson.decode(SQL_INJECTION_RULES_JSON);
    local waf_engine = engine:new()
    for _, rule in pairs(SQL_INJECTION_RULES) do
        if rule.enable then
            ngx.log(ngx.INFO, "start rule id "..rule.rule_id)
            sql_injection_res = waf_engine:run(rule.content)
            if sql_injection_res then
                ngx.log(ngx.INFO, "!!! rule match "..rule.rule_id)
                return true
            end
        end
    end
    return false
end

-- main function
function _M.check(self)
    if self:xss_rule() then
        return ngx.exit(ngx.HTTP_BAD_REQUEST)
    end
    if self:sql_injection() then
        return ngx.exit(ngx.HTTP_BAD_REQUEST)
    end
    -- if all rule pass
    return true
end

return _M
