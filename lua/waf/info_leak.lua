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

function _M.server_info_check(self, res)
    local result = res
    local pattern = ""
    match_table[1] = nil
    match_table[2] = nil
    local m, err = re_match(res,
            [[([1-9]\d{5}[1-9]\d{3}(0\d|1[0-2])([0|1|2]\d|3[0-1])\d{3}([0-9]|X))]],
            "joim", nil, match_table)
    local identity_card
    if m then
        identity_card = m[1]
    end
    if identity_card then
        identity_card_s = sub(identity_card, 1, 4).."XXXXXXXXXX"..sub(identity_card, -4, -1)
        result = string.gsub(res, identity_card, identity_card_s)
    end

    return result
end

-- main function
function _M.check(self, res)
    return self:server_info_check(res)
end

return _M