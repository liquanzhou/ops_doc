yum install -y make gcc  openssl-devel pcre-devel  bzip2-devel libxml2 libxml2-devel curl-devel libmcrypt-devel libjpeg libjpeg-devel libpng libpng-devel openssl

# ngx_module_lua
# yum install lua-devel lua

groupadd nginx
useradd nginx -g nginx -M -s /sbin/nologin
mkdir -p /usr/local/nginx/tmp
mkdir -p /usr/local/nginx/run
mkdir -p /usr/local/nginx/lock

./configure --help
--with     # 默认不加载 需指定编译此参数才使用
--without  # 默认加载，可用此参数禁用

pcre                     # 正则模块
http_gzip_static_module  # 压缩发送
http_realip_module       # 做代理时后的log取到真实IP
ngx_cache_purge          # --add-module=path 做代理时 用来清除缓存模块
nginx-devel-kit          # --add-module=path NDK(nginx development kit)模块是一个拓展nginx服务器核心功能的模块，第三方模块开发可以基于它来快速实现。
echo-nginx-module        # --add-module=path 提供直接在 Nginx 配置使用包括 "echo", "sleep", "time" 等指令。
http_dav_module          # 为Http webDAV 增加 PUT, DELETE, MKCOL, COPY 和 MOVE 等方法
http_proxy_module        # 代理模块,默认开启

# --add-module=/opt/ngx_module_upstream_check \         # nginx 代理状态页面  
# ngx_module_upstream_check  编译前需要打对应版本补丁 patch -p1 < /opt/nginx_upstream_check_module/check_1.2.6+.patch

#做代理缓存服务
wget http://labs.frickle.com/files/ngx_cache_purge-1.6.tar.gz
tar fxz ngx_cache_purge-1.6.tar.gz
cd nginx-1.4.4
./configure \
--user=nginx \
--group=nginx \
--prefix=/usr/local/nginx \
--pid-path=/usr/local/nginx/nginx.pid \
--lock-path=/usr/local/nginx/nginx.lock \
--with-http_ssl_module \
--with-http_realip_module \
--with-http_stub_status_module \
--add-module=../ngx_cache_purge-1.6 \
--http-client-body-temp-path=/usr/local/nginx/tmp/client \
--http-proxy-temp-path=/usr/local/nginx/tmp/proxy \
--http-fastcgi-temp-path=/usr/local/nginx/tmp/fastcgi \
--http-uwsgi-temp-path=/usr/local/nginx/tmp/uwsgi \
--http-scgi-temp-path=/usr/local/nginx/tmp/scgi

make && make install

#清除缓存，假设一个URL为http://192.168.12.133/test.txt 通过访问 http://192.168.12.133/purge/test.txt 就可以清除该URL的缓存。

#做web服务
cd nginx-1.4.4
./configure \
--user=nginx \
--group=nginx \
--prefix=/usr/local/nginx \
--pid-path=/usr/local/nginx/run/nginx.pid \
--lock-path=/usr/local/nginx/lock/nginx.lock \
--with-http_ssl_module \
--with-http_dav_module \
--with-http_flv_module \
--with-http_gzip_static_module \
--with-http_stub_status_module

make && make install


/usr/local/nginx/sbin/nginx –t    # 检查Nginx配置文件 但并不执行
/usr/local/nginx/sbin/nginx -t -c /opt/nginx/conf/nginx.conf  # 检查Nginx配置文件
/usr/local/nginx/sbin/nginx       # 启动nginx
kill -HUP pid               # 平滑重启
kill -QUIT pid              # 关闭nginx

0.7.53以前都是用 kill -HUP `cat /usr/local/nginx/logs/nginx.pid` 方法来重新加载配置，现在只需要用 
/usr/local/nginx/sbin/nginx -s reload 
-s参数包含四个命令分别是 stop/quit/reopen/reload



# NGINX上传最大默认为1M 如需要改变在http{}中加如下参数.
client_max_body_size 30M

# 默认nginx是不记录 rewrite 操作的日志.如需要开启,也可以单独指定location中日志文件
rewrite_log on;
