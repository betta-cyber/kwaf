local tools = require "waf/tools"
local cjson = require "cjson";
local engine = require "waf/waf_engine"
local redis = require "resty.redis"

local _M = {}

local mt = {  __index = _M }
local get_headers = ngx.req.get_headers

function _M.new(self, host, port, pass)
    local waf_engine = engine:new()
    local red = redis:new()
    red:set_timeout(1000)

    local ok, err = red:connect(host, port)
    if not ok then
        ngx.say("failed to connect: ", err)
        return
    end
    -- 请注意这里 auth 的调用过程
    local count
    count, err = red:get_reused_times()
    if 0 == count then
        ok, err = red:auth(pass)
        if not ok then
            ngx.say("failed to auth: ", err)
            return
        end
    elseif err then
        ngx.say("failed to get reused times: ", err)
        return
    end
    local t = {
        var = {},
        red = red,
        waf_engine = waf_engine,
    }
    return setmetatable(t, mt)
end

function _M.xss_rule(self)
    local XSS_RULES_JSON = self.red:get('xss')
    if XSS_RULES_JSON == ngx.null then
        XSS_RULES_JSON = get_rule('xss')
        self.red:set('xss', XSS_RULES_JSON)
    end
    -- 0.14ms decode json
    local XSS_RULES = cjson.decode(XSS_RULES_JSON)
    for _, rule in pairs(XSS_RULES) do
        if rule.enable then
            ngx.log(ngx.INFO, "start rule id "..rule.rule_id)
            xss_res = self.waf_engine:run(rule.content)
            if xss_res then
                ngx.log(ngx.INFO, "!!! rule match !!! "..rule.rule_id)
                return true
            end
        end
    end
    return false
end

function _M.sql_injection(self)
    local SQL_INJECTION_RULES_JSON = self.red:get('sql_injection')
    if SQL_INJECTION_RULES_JSON == ngx.null then
        SQL_INJECTION_RULES_JSON = get_rule('sql_injection')
        self.red:set('sql_injection', SQL_INJECTION_RULES_JSON)
    end
    local SQL_INJECTION_RULES = cjson.decode(SQL_INJECTION_RULES_JSON)
    for _, rule in pairs(SQL_INJECTION_RULES) do
        if rule.enable then
            ngx.log(ngx.INFO, "start rule id "..rule.rule_id)
            sql_injection_res = self.waf_engine:run(rule.content)
            if sql_injection_res then
                ngx.log(ngx.INFO, "!!! rule match !!! "..rule.rule_id)
                return true
            end
        end
    end
    return false
end

function _M.web_plugin(self)
    local WEB_PLUGIN_RULES_JSON = self.red:get('web_plugin')
    if WEB_PLUGIN_RULES_JSON == ngx.null then
        WEB_PLUGIN_RULES_JSON = get_rule('web_plugin')
        self.red:set('web_plugin', WEB_PLUGIN_RULES_JSON)
    end
    local WEB_PLUGIN_RULES = cjson.decode(WEB_PLUGIN_RULES_JSON)
    for _, rule in pairs(WEB_PLUGIN_RULES) do
        if rule.enable then
            ngx.log(ngx.INFO, "start rule id "..rule.rule_id)
            web_plugin_res = self.waf_engine:run(rule.content)
            if web_plugin_res then
                ngx.log(ngx.INFO, "!!! rule match !!! "..rule.rule_id)
                return true
            end
        end
    end
    return false
end

function _M.path_travel(self)
    local PATH_TRAVEL_RULES_JSON = self.red:get('path_travel')
    if PATH_TRAVEL_RULES_JSON == ngx.null then
        PATH_TRAVEL_RULES_JSON = get_rule('path_travel')
        self.red:set('path_travel', PATH_TRAVEL_RULES_JSON)
    end
    local PATH_TRAVEL_RULES = cjson.decode(PATH_TRAVEL_RULES_JSON)
    for _, rule in pairs(PATH_TRAVEL_RULES) do
        if rule.enable then
            ngx.log(ngx.INFO, "start rule id "..rule.rule_id)
            web_plugin_res = self.waf_engine:run(rule.content)
            if web_plugin_res then
                ngx.log(ngx.INFO, "!!! rule match !!! "..rule.rule_id)
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
    if self:web_plugin() then
        return ngx.exit(ngx.HTTP_BAD_REQUEST)
    end
    if self:path_travel() then
        return ngx.exit(ngx.HTTP_BAD_REQUEST)
    end
    -- if all rule pass
    return true
end

return _M
