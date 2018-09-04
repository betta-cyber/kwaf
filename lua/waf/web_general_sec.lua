require "waf/tools"
require "resty.core.regex"
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
    -- local XSS_RULES = '[{"rule_id":1310101,"content":{"arg":{"match":"co","value":"ccs"}}},{"rule_id":1310102,"content":{"cookie":{"match":"co","value":"ccs"}}}]';
    local XSS_RULES = get_rule(xss)
    local XSS_RULES = cjson.decode(XSS_RULES);
    local waf_engine = engine:new()
    for _, rule in pairs(XSS_RULES) do
        print(rule.rule_id)
        res = waf_engine:run(rule.content)
        if res then
            return true
        end
    end
    return false
end

function _M.check(self)
    local header = get_headers()
    local args = ngx.req.get_uri_args()

    if self:xss_rule() then
        return ngx.exit(ngx.HTTP_BAD_REQUEST)
    end

    return true
end

return _M
