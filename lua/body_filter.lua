local config = require 'config'
local info_leak = require 'waf/info_leak'

-- response body
local res_body = ngx.arg[1]

if config.waf_enable then
    if config.info_leak then
        local info_leak = info_leak:new()
        res = info_leak:check(res_body)
    end
end

-- write to response
ngx.arg[1] = res