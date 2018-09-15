local web_general_sec = require 'waf/web_general_sec'
local http_protocol_validation = require 'waf/http_protocol_validation'

local content_length = tonumber(ngx.req.get_headers()['content-length'])
local method = ngx.req.get_method()

local waf_protection = true

if waf_protection then
    local http_protocol_validation = http_protocol_validation:new()
    http_protocol_validation:check_in_strategy()

    local web_general_sec = web_general_sec:new()
    web_general_sec:check()

    -- todo:
    -- white list
    -- black list
    -- upload limit
    -- download limit
    -- info leak
    -- brute force
end
