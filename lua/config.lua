local _M = {
    --waf status
    waf_enable = true,
    --log dir
    log_dir = "/home/betta/kwaf/logs",
    --rule setting
    rule_dir = "/home/betta/kwaf/rule",
    --enable/disable http_protocol_validation
    http_protocol_validation = true,
    --enable/disable web_general_sec
    web_general_sec = true,
    --enable/disable upload_limit
    upload_limit = true,
    --enable/disable sensitive_info
    sensitive_info = true,
}

return _M
