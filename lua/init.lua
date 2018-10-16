-- local config = require 'config'
-- local tools = require 'waf/tools'

-- local RULES_JSON = self.red:get(keyword)
-- if RULES_JSON == ngx.null then
--     RULES_JSON = get_rule(keyword)
--     self.red:set(keyword, RULES_JSON)
-- end
-- -- 0.14ms decode json
-- return cjson.decode(RULES_JSON)

-- config.set_to_cache()