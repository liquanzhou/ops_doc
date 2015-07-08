Nginx限制ip连接数，Nginx限制并发，同一IP，Nginx怎么限制流量/限制带宽？

nginx 限制ip并发数，也是说限制同一个ip同时连接服务器的数量。如何Nginx限制同一个ip的连接数，限制并发数目，限制流量/限制带宽？ 通过下面nginx模块的使用，我们可以设置一旦并发链接数超过我们的设置，将返回503错误给对方。这样可以非常有效的防止CC攻击。在配合 iptables防火墙，基本上CC攻击就可以无视了。Nginx限制ip链接数，Nginx如何限制并发数，同1个IP，nginx怎么限制流量/限制带宽？请看下文：

nginx 限制ip并发数，nginx限制IP链接数的范例参考：

limit_zone lit_zone $binary_remote_addr 20m;
limit_req_zone $binary_remote_addr zone=ctohome_req_zone:20m rate=2r/s;

server {
listen *:80;
server_name www.hostsoft.cn .hostsoft.cn;

location / {
proxy_pass http://1.2.3.4;
include vhosts/conf.proxy_cache;
}

location ~ .*\.(php|jsp|cgi|phtml|asp|aspx)?$ {
limit_conn lit_zone 2;
limit_req zone=lit_req_zone burst=3;
proxy_pass http://1.1.1.1;
include vhosts/conf.proxy_no_cache;
}
}

如何Nginx限制同一个ip的连接数，限制并发数目

1.添加limit_zone
这个变量只能在http使用
vi /usr/local/nginx/conf/nginx.conf
limit_zone lit_zone $remote_addr 10m;

2.添加limit_conn
这个变量可以在http, server, location使用
我只限制一个站点，所以添加到server里面
vi /usr/local/nginx/conf/host/hostsoft.cn.conf
limit_conn lit_zone 2;

3.重启nginx
killall -HUP nginx

Nginx限制流量/限制带宽？

关于limit_zone：http://wiki.nginx.org/NginxHttpLimitZoneModule
关于limit_rate和limit_conn：http://wiki.nginx.org/NginxHttpCoreModule
nginx可以通过HTTPLimitZoneModule和HTTPCoreModule两个组件来对目录进行限速。

http {
limit_zone one $binary_remote_addr 10m;
server {
location /download/ {
limit_conn lit_zone 2;

limit_rate 300k;
}
}
}

limit_zone，是针对每个IP定义一个存储session状态的容器。这个示例中定义了一个10m的容器，按照32bytes/session，可以处理320000个session。

limit_conn lit_zone 2;
限制每个IP只能发起2个并发连接。

limit_rate 300k;
对每个连接限速300k. 注意，这里是对连接限速，而不是对IP限速。如果一个IP允许两个并发连接，那么这个IP就是限速limit_rate×2。
ngx_http_limit_zone_module