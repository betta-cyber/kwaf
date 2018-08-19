require "waf/tools"
require "resty.core.regex"

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
    local args = ngx.req.get_uri_args()
    tprint(header)
    for k,v in pairs(args) do
        ngx.log(ngx.INFO, "arg: ", k, " value: ", v)
        if string.find(v, '.*alert') then
            ngx.log(ngx.INFO, "match")
            return ngx.exit(ngx.HTTP_NOT_FOUND)
        end
    end
    -- for i = 1, #header do
        -- ngx.log(ngx.INFO, "header:", header[i])
    -- end
    return true
end

return _M
