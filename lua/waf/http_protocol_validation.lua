require "waf/tools"
require "resty.core.regex"

local _M = {}

local mt = {  __index = _M }
local get_headers = ngx.req.get_headers
local error_code = {
    HTTP_BAD_REQUEST= "request could not be understood",
    HTTP_METHOD_NOT_ALLOWED= "request method is not allowed",
    HTTP_LENGTH_REQUIRED= "request method requires a valid Content-length",
    HTTP_REQUEST_ENTITY_TOO_LARGE= "request exceeds system's limit",
    HTTP_PROTOCOL_VERSION_FORBIDDEN= "request use forbidden http protocol version",
    HTTP_REQUEST_BAD_METHOD= "the requested method is unknown",
    HTTP_REQUEST_BAD_URI= "request with invalid uri",
    HTTP_REQUEST_BAD_SCHEMA= "request with bad schema",
    HTTP_REQUEST_BAD_PROTOCOL= "request with bad protocol version",
    HTTP_REQUEST_BAD_CRLF= "request end failed, bad CRLF",
    HTTP_RESPONSE_ENTITY_TOO_LARGE= "response exceed system's limit",
}

local max_uri_length = 4096
local max_uri_arg_count = 20
local max_user_agent_length = 1024
local max_cookie_length = 1024
local max_cookie_count = 64
local max_referer_length = 4096
local max_accept_length = 1024
local max_accpet_charset_length = 128
local max_content_length = 10485760
local max_range_count = 5
local max_uri_length = 5242880
local max_http_header_count = 32
local max_http_header_name_length = 64
local max_http_header_value_length = 128
local max_post_arg_count = 256
local repeat_arg = false
local repeat_header = true
local double_url_encode = false
local abnormal_port = true
local abnormal_host = true


function _M.new()
    local t = {
        var = {},
    }
    return setmetatable(t, mt)
end

function _M.check_in_decode()
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

function _M.exist_repeat_args(self, args)
    flag = self:is_key_repeat(args)
    return flag
end

function _M.exist_repeat_headers(self, headers)
    flag = self:is_key_repeat(headers)
    return flag
end

function _M.is_key_repeat(self, keys)
    local flag = false
    -- local sort_func = function( a,b ) return a[1] < b[1] end
    -- table.sort(keys, sort_func)
    len = table_leng(keys)
    for key, value in pairs(keys) do
        if type(value) == "table" then
            -- it means have double key-value
            flag = true
        end
    end
    return flag
end

function _M.check_in_strategy(self)
    local headers = get_headers()
    tprint(headers)
    local args = ngx.req.get_uri_args()
    -- start check
    if self:exist_repeat_headers(headers) then
        return ngx.exit(ngx.HTTP_BAD_REQUEST)
    end
    if self:exist_repeat_args(args) then
        return ngx.exit(ngx.HTTP_BAD_REQUEST)
    end
     -- for k,v in pairs(args) do
        -- ngx.log(ngx.INFO, "arg: ", k, " value: ", v)
        -- if string.find(v, '.*alert') then
            -- ngx.log(ngx.INFO, "match")
            -- return ngx.exit(ngx.HTTP_NOT_FOUND)
        -- end
    -- end
    -- for i = 1, #header do
        -- ngx.log(ngx.INFO, "header:", header[i])
    -- end
    return true
end

return _M
