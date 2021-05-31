
Nginx的平滑升级

1、查看当然版本
#cd /usr/local/nginx/ #进入Nginx安装目录
# sbin/nginx -V #查看版本
nginx version: nginx/0.7.60
configure arguments: –user=www –group=www –prefix=/usr/local/nginx –with-http_stub_status_module –with-http_ssl_module #编译项
得到原来./configure 的编译项

2.下载最新版
前往查看最新版，http://nginx.org/en/download.html
#cd /data/soft/
#wget http://nginx.org/download/nginx-0.8.36.tar.gz #下载
#tar xzvf nginx-0.8.36.tar.gz #解压缩
#cd nginx-0.8.36

3.编译
#./configure –user=www –group=www –prefix=/usr/local/nginx –with-http_stub_status_module –with-http_ssl_module #按原来的选项configure
#make #编译
#mv /usr/local/nginx/sbin/nginx /usr/local/nginx/sbin/nginx.old #移动旧版本
#cp objs/nginx /usr/local/nginx/sbin/ #复制新版本nginx过去
#cd /usr/local/nginx
#sbin/nginx -t #测试下，显示如下就是通过
the configuration file /usr/local/nginx/conf/nginx.conf syntax is ok
configuration file /usr/local/nginx/conf/nginx.conf test is successful

4.启动新的，关掉旧的
让nginx把nginx.pid改成nginx.pid.oldbin 跟着启动新的nginx
# kill -USR2 `cat /usr/local/nginx/nginx.pid`
退出旧的nignx
# kill -QUIT `cat /usr/local/nginx/nginx.pid.oldbin`

5.升级完成。
# sbin/nginx -V
nginx version: nginx/0.8.36
TLS SNI support disabled
configure arguments: --user=www --group=www --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_ssl_module 