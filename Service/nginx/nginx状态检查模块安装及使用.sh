nginx状态检查模块安装及使用

nginx_upstream_check_module

./configure --user=www --group=www --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_ssl_module --with-mail --with-mail_ssl_module --with-http_realip_module --with-pcre --add-module=/opt/soft/nginx_mod/nginx-push-stream-module --add-module=/opt/soft/nginx_mod/ngx_cache_purge-1.4 --add-module=/opt/soft/nginx_mod/headers-more-nginx-module-master --add-module=/opt/soft/nginx_mod/nginx_upstream_hash-master --add-module=/opt/soft/nginx_mod/nginx-upload-progress-module-master --add-module=/opt/soft/nginx_mod/nginx_upstream_check_module-master



    upstream data_pool {
        server 10.10.81.125:9090;
        server 10.10.81.220:9090;
        check interval=5000 rise=2 fall=10 timeout=3000 type=http;
        check_http_send "GET /login.html HTTP/1.0\r\n\r\n";
        check_http_expect_alive http_2xx http_3xx;
    }