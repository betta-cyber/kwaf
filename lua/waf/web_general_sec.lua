require 'waf/tools'
local _M = {}

local mt = {  __index = _M }
local get_headers = ngx.req.get_headers

function _M.new()
    local t = {
        var = {},
    }
    return setmetatable(t, mt)
end

function _M.load_secrules(ruleset, opts)
    local a = 1
    local header = get_headers()
    tprint(header)
    ngx.log(ngx.INFO, "header:", header)
    return true
end

return _M
