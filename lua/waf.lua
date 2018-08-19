local web_general_sec = require 'waf/web_general_sec'

local content_length = tonumber(ngx.req.get_headers()['content-length'])
local method = ngx.req.get_method()


if method == "POST" then
    local web_general_sec = web_general_sec:new()
    if web_general_sec:load_secrules() then
        ngx.say("111111")
    end
end
