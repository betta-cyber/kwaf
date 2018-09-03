local web_general_sec = require 'waf/web_general_sec'
local http_protocol_validation = require 'waf/http_protocol_validation'

local content_length = tonumber(ngx.req.get_headers()['content-length'])
local method = ngx.req.get_method()


if method == "POST" then
    local web_general_sec = web_general_sec:new()
    -- if web_general_sec:load_secrules() then
        -- ngx.say("111111")
    -- end

    local http_protocol_validation = http_protocol_validation:new()
    http_protocol_validation:check_in_strategy()

    local web_general_sec = web_general_sec:new()
    web_general_sec:check()
end
