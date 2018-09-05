function table_leng(t)
  local leng=0
  for k, v in pairs(t) do
    leng=leng+1
  end
  return leng;
end

function tprint (t, s)
    for k, v in pairs(t) do
        local kfmt = '["' .. tostring(k) ..'"]'
        if type(k) ~= 'string' then
            kfmt = '[' .. k .. ']'
        end
        local vfmt = '"'.. tostring(v) ..'"'
        if type(v) == 'table' then
            tprint(v, (s or '')..kfmt)
        else
            if type(v) ~= 'string' then
                vfmt = tostring(v)
            end
            print(type(t)..(s or '')..kfmt..' = '..vfmt)
        end
    end
end

function get_rule(ruledirname)
    local lfs = require 'lfs'
    local io = require 'io'
    local cjson = require "cjson";
    -- local RULE_PATH = config_rule_dir
    local RULE_PATH = '/home/betta/kwaf/rule'
    local RULE_DIR = RULE_PATH..'/'..ruledirname..'_rule'

    if RULE_DIR == nil then
        return
    end
    RULE_JSON = ''

    for file in lfs.dir(RULE_DIR) do
        if file~='.' and file~='..' then
            local RULE_FILE = io.open(RULE_DIR..'/'..file,"r")
            local content = RULE_FILE:read("*all")
            RULE_JSON = RULE_JSON..','..content
            RULE_FILE:close()
        end
    end
    RULE_JSON = string.sub(RULE_JSON,2,string.len(RULE_JSON))
    RULE_JSON = '['..RULE_JSON..']'
    -- tprint(RULE_JSON)
    return(RULE_JSON)
end
