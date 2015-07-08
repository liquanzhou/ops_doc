nginx限制请求数ngx_http_limit_req_module模块



一. 前言
在《nginx限制连接数ngx_http_limit_conn_module模块》我们说到了ngx_http_limit_conn_module 模块，来限制连接数。那么请求数的限制该怎么做呢？这就需要通过ngx_http_limit_req_module 模块来实现，该模块可以通过定义的 键值来限制请求处理的频率。特别的，可以限制来自单个IP地址的请求处理频率。 限制的方法如同漏斗，每秒固定处理请求数，推迟过多请求。

二. ngx_http_limit_req_module模块指令
limit_req_zone
语法: limit_req_zone $variable zone=name:size rate=rate;
默认值: none
配置段: http
设置一块共享内存限制域用来保存键值的状态参数。 特别是保存了当前超出请求的数量。 键的值就是指定的变量（空值不会被计算）。如
limit_req_zone $binary_remote_addr zone=one:10m rate=1r/s;

说明：区域名称为one，大小为10m，平均处理的请求频率不能超过每秒一次。
键值是客户端IP。
使用$binary_remote_addr变量， 可以将每条状态记录的大小减少到64个字节，这样1M的内存可以保存大约1万6千个64字节的记录。
如果限制域的存储空间耗尽了，对于后续所有请求，服务器都会返回 503 (Service Temporarily Unavailable)错误。
速度可以设置为每秒处理请求数和每分钟处理请求数，其值必须是整数，所以如果你需要指定每秒处理少于1个的请求，2秒处理一个请求，可以使用 “30r/m”。

limit_req_log_level
语法: limit_req_log_level info | notice | warn | error;
默认值: limit_req_log_level error;
配置段: http, server, location
设置你所希望的日志级别，当服务器因为频率过高拒绝或者延迟处理请求时可以记下相应级别的日志。 延迟记录的日志级别比拒绝的低一个级别；比如， 如果设置“limit_req_log_level notice”， 延迟的日志就是info级别。

limit_req_status
语法: limit_req_status code;
默认值: limit_req_status 503;
配置段: http, server, location
该指令在1.3.15版本引入。设置拒绝请求的响应状态码。

limit_req
语法: limit_req zone=name [burst=number] [nodelay];
默认值: —
配置段: http, server, location
设置对应的共享内存限制域和允许被处理的最大请求数阈值。 如果请求的频率超过了限制域配置的值，请求处理会被延迟，所以所有的请求都是以定义的频率被处理的。 超过频率限制的请求会被延迟，直到被延迟的请求数超过了定义的阈值，这时，这个请求会被终止，并返回503 (Service Temporarily Unavailable) 错误。这个阈值的默认值为0。如：
limit_req_zone $binary_remote_addr zone=ttlsa_com:10m rate=1r/s;
server {
    location /www.ttlsa.com/ {
        limit_req zone=ttlsa_com burst=5;
    }
}

限制平均每秒不超过一个请求，同时允许超过频率限制的请求数不多于5个。
如果不希望超过的请求被延迟，可以用nodelay参数,如：
limit_req zone=ttlsa_com burst=5 nodelay;

三. 完整实例配置
http {
    limit_req_zone $binary_remote_addr zone=ttlsa_com:10m rate=1r/s;
 
    server {
        location  ^~ /download/ { 
            limit_req zone=ttlsa_com burst=5;
            alias /data/www.ttlsa.com/download/;
        }
    }
}

可能要对某些IP不做限制，需要使用到白名单。名单设置参见后续的文档，我会整理一份以供读者参考。请专注。

如需转载请注明出处：http://www.ttlsa.com/html/3185.html