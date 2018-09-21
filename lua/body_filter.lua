local config = require 'config'
local sensitive_info = require 'waf/sensitive_info'

-- response body
local res_body = ngx.arg[1]

if config.waf_enable then
    if config.sensitive_info then
        local sensitive_info = sensitive_info:new()
        res = sensitive_info:check(res_body)
    end
end

-- write to response
ngx.arg[1] = res
