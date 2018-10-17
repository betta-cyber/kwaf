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

-- upload limit
-- @params nil
-- @return bool
function _M.upload_check(self)
    ngx.req.read_body()
    local body = ngx.req.get_body_data()
    if body then
        local p, err = parser.new(body, ngx.var.http_content_type)
        if not p then
            ngx.log(ngx.ERR, "failed to create parser: "..err)
            return
        end
        -- load upload file
        while true do
            -- file['name']         eg:aaa
            -- file['mine']         eg:application/octet-stream
            -- file['filename']     eg:aaa.php
            -- file['part_body']
            local file = p:parse_part()
            if not file then
                break
            end
            local ext = self:parse_ext(file['filename'])
            if self:check_php_ext(ext) then
                if self:php_check(file['part_body']) then
                    return true
                end
            end
            if self:check_python_ext(ext) then
                if self:python_check(file['part_body']) then
                    return true
                end
            end
        end
    end
    return false
end

-- 根据扩展名判断文件是否为php文件
-- @params ext_name
-- @return bool
function _M.check_php_ext(self, ext_name)
    if rulematch(ext_name, '(?i)(php|inc|php3|php4|php5|htaccess)', "jo") then
        return true
    end
    return false
end

-- 根据扩展名判断文件是否为java文件
-- @params ext_name
-- @return bool
function _M.check_java_ext(self, ext_name)
    if rulematch(ext_name, '(?i)(java|jsp|js|jar|war)', "jo") then
        return true
    end
    return false
end

-- 根据扩展名判断文件是否为python文件
-- @params ext_name
-- @return bool
function _M.check_python_ext(self, ext_name)
    if rulematch(ext_name, '(?i)(py|pyc)', "jo") then
        return true
    end
    return false
end

-- 根据扩展名判断文件是否为po文件
-- @params ext_name
-- @return bool
function _M.check_po_ext(self, ext_name)
    if rulematch(ext_name, '(?i)(bat|cmd|vbs)', "jo") then
        return true
    end
    return false
end

-- 根据扩展名判断文件是否为perl文件
-- @params ext_name
-- @return bool
function _M.check_perl_ext(self, ext_name)
    if rulematch(ext_name, '(?i)(pl|cgi)', "jo") then
        return true
    end
    return false
end

-- 根据扩展名判断文件是否为linux script文件
-- @params ext_name
-- @return bool
function _M.check_ls_ext(self, ext_name)
    if rulematch(ext_name, '(?i)(sh)', "jo") then
        return true
    end
    return false
end

-- 根据扩展名判断文件是否为asp文件
-- @params ext_name
-- @return bool
function _M.check_asp_ext(self, ext_name)
    if rulematch(ext_name, '(?i)(asp|aspx|asa|cer|cdx|htr|stm)', "jo") then
        return true
    end
    return false
end

-- 根据扩展名判断文件是否为ruby文件
-- @params ext_name
-- @return bool
function _M.check_ruby_ext(self, ext_name)
    if rulematch(ext_name, '(?i)(rb)', "jo") then
        return true
    end
    return false
end

-- 根据扩展名判断文件是否为PE文件
-- @params ext_name
-- @return bool
function _M.check_pe_ext(self, ext_name)
    if rulematch(ext_name, '(?i)(exe|com|dll|pif|scr|msi|msp)', "jo") then
        return true
    end
    return false
end

-- description parse ext name from file name
-- parse eg:
--      file name-> extent name
--      a.b      ->     b
--      a.b.     ->     b
--      a.b.c    ->     c
--      a.       ->     NULL

function _M.parse_ext(self, file_name)
    local ext = file_name:match("^.+(%..+)$")
    if(ext) then
        return string.gsub(ext, "%.", "")
    else
        return nil
    end
end

function _M.php_check(self, part_body)
    -- match php start tag
    if rulematch(part_body, '<\\?[\\s\\n\\b]*php', "jo") then
        return true
    end
    -- match eval
    if rulematch(part_body, '@?eval[\\s\\b]*\\w*\\(+', "jo") then
        return true
    end
end

function _M.python_check(self, part_body)
    
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
