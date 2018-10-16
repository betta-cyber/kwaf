local tools = require "waf/tools"
local cjson = require "cjson";
local engine = require "waf/waf_engine"

local _M = {}

local mt = {  __index = _M }
local get_headers = ngx.req.get_headers

function _M.new(self)
    local waf_engine = engine:new()
    -- local red = redis:new()
    -- red:set_timeout(1000)

    -- local ok, err = red:connect(host, port)
    -- if not ok then
    --     ngx.say("failed to connect: ", err)
    --     return
    -- end
    -- -- 请注意这里 auth 的调用过程
    -- local count
    -- count, err = red:get_reused_times()
    -- if 0 == count then
    --     ok, err = red:auth(pass)
    --     if not ok then
    --         ngx.say("failed to auth: ", err)
    --         return
    --     end
    -- elseif err then
    --     ngx.say("failed to get reused times: ", err)
    --     return
    -- end
    local t = {
        var = {},
        waf_engine = waf_engine,
    }
    return setmetatable(t, mt)
end

function _M.get_rule_json(self, keyword)
    local RULES_JSON = get_from_cache(keyword)
    if RULES_JSON == nil then
        RULES_JSON = get_rule(keyword)
        set_to_cache(keyword, RULES_JSON)
    end
    -- disable redis
    -- local RULES_JSON = self.red:get(keyword)
    -- if RULES_JSON == ngx.null then
    --     RULES_JSON = get_rule(keyword)
    --     self.red:set(keyword, RULES_JSON)
    -- end
    -- 0.14ms decode json
    return cjson.decode(RULES_JSON)
end

function _M.xss_rule(self) 
    local XSS_RULES = self:get_rule_json('xss')
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
    local SQL_INJECTION_RULES = self:get_rule_json('sql_injection')
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
    local WEB_PLUGIN_RULES = self:get_rule_json('web_plugin')
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
    local PATH_TRAVEL_RULES = self:get_rule_json('path_travel')
    for _, rule in pairs(PATH_TRAVEL_RULES) do
        if rule.enable then
            ngx.log(ngx.INFO, "start rule id "..rule.rule_id)
            path_travel_res = self.waf_engine:run(rule.content)
            if path_travel_res then
                ngx.log(ngx.INFO, "!!! rule match !!! "..rule.rule_id)
                return true
            end
        end
    end
    return false
end

function _M.cmd_injection(self)
    local CMD_INJECTION_RULES = self:get_rule_json('cmd_injection')
    for _, rule in pairs(CMD_INJECTION_RULES) do
        if rule.enable then
            ngx.log(ngx.INFO, "start rule id "..rule.rule_id)
            cmd_injection_res = self.waf_engine:run(rule.content)
            if cmd_injection_res then
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
    if self:cmd_injection() then
        return ngx.exit(ngx.HTTP_BAD_REQUEST)
    end
    -- if all rule pass
    return true
end

return _M
