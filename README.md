# kwaf

this is a light waf depend on openresty

# require

Lua library for HTTP cookie

https://github.com/cloudflare/lua-resty-cookie

Lua CJSON is a fast JSON encoding/parsing module for Lua

https://github.com/openresty/lua-cjson

# install

add this in your nginx conf

```
access_by_lua_file 'lua/waf.lua';
```
