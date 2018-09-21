local tools = require "waf/tools"
local regex = require "resty.core.regex"
local cjson = require "cjson";
local engine = require "waf/waf_engine"
local parser = require "lib/parser"

local find = string.find
local sub = string.sub
local re_match = ngx.re.match
local re_find = ngx.re.find

local _M = {}

local mt = {  __index = _M }
local match_table = {}

function _M.new()
    local t = {
        var = {},
    }
    return setmetatable(t, mt)
end

function _M.sensitive_info_check(self, res)
    local result = res
    local pattern = ""
    match_table[1] = nil
    match_table[2] = nil

    -- identity_card
    local m, err = re_match(result,
            [[([1-9]\d{5}[1-9]\d{3}(0\d|1[0-2])([0|1|2]\d|3[0-1])\d{3}([0-9]|X))]],
            "joim", nil, match_table)
    local identity_card
    if m then
        identity_card = m[1]
    end
    if identity_card then
        identity_card_s = sub(identity_card, 1, 4).."XXXXXXXXXX"..sub(identity_card, -4, -1)
        result = string.gsub(result, identity_card, identity_card_s)
    end

    -- phone number
    local m, err = re_match(result,
            [[(?i)(((86)[^a-zA-Z0-9]{0,6}?){0,1}(13[0-9]|14[579]|15[0-35-9]|16[6]|17[0135678]|18[0-9]|19[89])[0-9]{8})]],
            "joim", nil, match_table)
    local phone_number
    if m then
        phone_number = m[1]
    end
    if phone_number then
        phone_number_s = sub(phone_number, 1, 3).."XXXXX"..sub(phone_number, -3, -1)
        result = string.gsub(result, phone_number, phone_number_s)
    end

    return result
end

-- main function
function _M.check(self, res)
    return self:sensitive_info_check(res)
end

return _M
