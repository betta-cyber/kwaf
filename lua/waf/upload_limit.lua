local tools = require "waf/tools"
local regex = require "resty.core.regex"
local cjson = require "cjson";
local engine = require "waf/waf_engine"
local parser = require "lib/parser"

local _M = {}

local mt = {  __index = _M }
local rulematch = ngx.re.find

function _M.new()
    local t = {
        var = {},
    }
    return setmetatable(t, mt)
end

function _M.upload_check(self)
    ngx.req.read_body()
    local body = ngx.req.get_body_data()
    local p, err = parser.new(body, ngx.var.http_content_type)
    if not p then
        ngx.log(ngx.ERROR, "failed to create parser: "..err)
        return
    end
    -- load upload file
    while true do
        local file = p:parse_part()
        if not file then
            break
        end
        tprint(file)
        if self:php_check(file['part_body']) then
            return true
        end
    end
    return false
end

function _M.php_check(self, part_body)
    -- match php start tag
    if rulematch(part_body, '<\\?[\\s\\n\\b]*php', "jo") then
        return true
    end
end
    

-- main function
function _M.check(self)
    if self:upload_check() then
        return ngx.exit(ngx.HTTP_BAD_REQUEST)
    end
    -- if all rule pass
    return true
end

return _M