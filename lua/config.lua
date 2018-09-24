local _M = {
    --waf status
    waf_enable = true,
    --log dir
    log_dir = "/Users/shokill/kwaf/logs",
    --rule setting
    rule_dir = "/Users/shokill/kwaf/rule",
    --enable/disable http_protocol_validation
    http_protocol_validation = true,
    --enable/disable web_general_sec
    web_general_sec = true,
    --enable/disable upload_limit
    upload_limit = true,
    --enable/disable sensitive_info
    sensitive_info = true,
    --redis config
    redis_host = "127.0.0.1",
    --redis port
    redis_port = 6379,
    --redis pass
    redis_pass = "root"
}

return _M
