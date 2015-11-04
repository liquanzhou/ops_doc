nginx rewrite 参数和例子


http://www.cnblogs.com/analyzer/articles/1377684.html

]

本位转自：http://blog.c1gstudio.com/archives/434

推荐参考地址：
Mailing list ARChives 官方讨论区
http://marc.info/?l=nginx

Nginx 常见应用技术指南[Nginx Tips]
http://bbs.linuxtone.org/thread-1685-1-1.html

本日志内容来自互联网和平日使用经验，整理一下方便日后参考。

正则表达式匹配，其中：

    * ~ 为区分大小写匹配
    * ~* 为不区分大小写匹配
    * !~和!~*分别为区分大小写不匹配及不区分大小写不匹配

文件及目录匹配，其中：

    * -f和!-f用来判断是否存在文件
    * -d和!-d用来判断是否存在目录
    * -e和!-e用来判断是否存在文件或目录
    * -x和!-x用来判断文件是否可执行

flag标记有：

    * last 相当于Apache里的[L]标记，表示完成rewrite  不跳新地址
    * break 终止匹配, 不再匹配后面的规则
    * redirect 返回302临时重定向 地址栏会显示跳转后的地址
    * permanent 返回301永久重定向 地址栏会显示跳转后的地址

一些可用的全局变量有，可以用做条件判断(待补全)

    $args
    $content_length
    $content_type
    $document_root
    $document_uri
    $host
    $http_user_agent
    $http_cookie
    $limit_rate
    $request_body_file
    $request_method
    $remote_addr
    $remote_port
    $remote_user
    $request_filename
    $request_uri
    $query_string
    $scheme
    $server_protocol
    $server_addr
    $server_name
    $server_port
    $uri

结合QeePHP的例子

    if (!-d $request_filename) {
    rewrite ^/([a-z-A-Z]+)/([a-z-A-Z]+)/?(.*)$ /index.php?namespace=user&amp;controller=$1&amp;action=$2&amp;$3 last;
    rewrite ^/([a-z-A-Z]+)/?$ /index.php?namespace=user&amp;controller=$1 last;
    break;

	}
多目录转成参数
abc.domian.com/sort/2 => abc.domian.com/index.php?act=sort&name=abc&id=2

    if ($host ~* (.*)/.domain/.com) {
    set $sub_name $1;   
    rewrite ^/sort//(/d+)//?$ /index.php?act=sort&cid=$sub_name&id=$1 last;
    }

目录对换
/123456/xxxx -> /xxxx?id=123456

    rewrite ^/(/d+)/(.+)/ /$2?id=$1 last;

例如下面设定nginx在用户使用ie的使用重定向到/nginx-ie目录下：

    if ($http_user_agent ~ MSIE) {
    rewrite ^(.*)$ /nginx-ie/$1 break;
    }

目录自动加“/”

    if (-d $request_filename){
    rewrite ^/(.*)([^/])$ http://$host/$1$2/ permanent;
    }

禁止htaccess

    location ~//.ht {
             deny all;
         }

禁止多个目录

    location ~ ^/(cron|templates)/ {
             deny all;
    break;
         }

禁止以/data开头的文件
可以禁止/data/下多级目录下.log.txt等请求;

    location ~ ^/data {
             deny all;
         }

禁止单个目录
不能禁止.log.txt能请求

    location /searchword/cron/ {
             deny all;
         }

禁止单个文件

    location ~ /data/sql/data.sql {
             deny all;
         }

给favicon.ico和robots.txt设置过期时间;
这里为favicon.ico为99天,robots.txt为7天并不记录404错误日志

    location ~(favicon.ico) {
                     log_not_found off;
    expires 99d;
    break;
         }
     
         location ~(robots.txt) {
                     log_not_found off;
    expires 7d;
    break;
         }

设定某个文件的过期时间;这里为600秒，并不记录访问日志

    location ^~ /html/scripts/loadhead_1.js {
                     access_log   off;
                     root /opt/lampp/htdocs/web;
    expires 600;
    break;
           }

文件反盗链并设置过期时间
这里的return 412 为自定义的http状态码，默认为403，方便找出正确的盗链的请求
“rewrite ^/ http://leech.c1gstudio.com/leech.gif;”显示一张防盗链图片
“access_log off;”不记录访问日志，减轻压力
“expires 3d”所有文件3天的浏览器缓存

    location ~* ^.+/.(jpg|jpeg|gif|png|swf|rar|zip|css|js)$ {
    valid_referers none blocked *.c1gstudio.com *.c1gstudio.net localhost 208.97.167.194;
    if ($invalid_referer) {
        rewrite ^/ http://leech.c1gstudio.com/leech.gif;
        return 412;
        break;
    }
                     access_log   off;
                     root /opt/lampp/htdocs/web;
    expires 3d;
    break;
         }

只充许固定ip访问网站，并加上密码

    root  /opt/htdocs/www;
    allow   208.97.167.194;
    allow   222.33.1.2;
    allow   231.152.49.4;
    deny    all;
    auth_basic "C1G_ADMIN";
    auth_basic_user_file htpasswd;

将多级目录下的文件转成一个文件，增强seo效果
/job-123-456-789.html 指向/job/123/456/789.html

    rewrite ^/job-([0-9]+)-([0-9]+)-([0-9]+)/.html$ /job/$1/$2/jobshow_$3.html last;

将根目录下某个文件夹指向2级目录
如/shanghaijob/ 指向 /area/shanghai/
如果你将last改成permanent，那么浏览器地址栏显是/location/shanghai/

    rewrite ^/([0-9a-z]+)job/(.*)$ /area/$1/$2 last;

上面例子有个问题是访问/shanghai 时将不会匹配

    rewrite ^/([0-9a-z]+)job$ /area/$1/ last;
    rewrite ^/([0-9a-z]+)job/(.*)$ /area/$1/$2 last;

这样/shanghai 也可以访问了，但页面中的相对链接无法使用，
如./list_1.html真实地址是/area/shanghia/list_1.html会变成/list_1.html,导至无法访问。

那我加上自动跳转也是不行咯
(-d $request_filename)它有个条件是必需为真实目录，而我的rewrite不是的，所以没有效果

    if (-d $request_filename){
    rewrite ^/(.*)([^/])$ http://$host/$1$2/ permanent;
    }

知道原因后就好办了，让我手动跳转吧

    rewrite ^/([0-9a-z]+)job$ /$1job/ permanent;
    rewrite ^/([0-9a-z]+)job/(.*)$ /area/$1/$2 last;

文件和目录不存在的时候重定向：

    if (!-e $request_filename) {
    proxy_pass http://127.0.0.1;
    }

域名跳转

    server
         {
                 listen       80;
                 server_name  jump.c1gstudio.com;
                 index index.html index.htm index.php;
                 root  /opt/lampp/htdocs/www;
                 rewrite ^/ http://www.c1gstudio.com/;
                 access_log  off;
         }

多域名转向

    server_name  www.c1gstudio.com www.c1gstudio.net;
                 index index.html index.htm index.php;
                 root  /opt/lampp/htdocs;
    if ($host ~ "c1gstudio/.net") {
    rewrite ^(.*) http://www.c1gstudio.com$1 permanent;
    }

三级域名跳转

    if ($http_host ~* "^(.*)/.i/.c1gstudio/.com$") {
    rewrite ^(.*) http://top.yingjiesheng.com$1;
    break;
    }

域名镜向

    server
         {
                 listen       80;
                 server_name  mirror.c1gstudio.com;
                 index index.html index.htm index.php;
                 root  /opt/lampp/htdocs/www;
                 rewrite ^/(.*) http://www.c1gstudio.com/$1 last;
                 access_log  off;
         }
		 
更换域名 跳转新域名
    location ~ ^/api/live/.*$ {
            rewrite "^/(.*)$" http://k.baidu.com/$1 last;
    }
		 
某个子目录作镜向

    location ^~ /zhaopinhui {
      rewrite ^.+ http://zph.c1gstudio.com/ last;
      break;
         }

discuz ucenter home (uchome) rewrite

    rewrite ^/(space|network)-(.+)/.html$ /$1.php?rewrite=$2 last;
    rewrite ^/(space|network)/.html$ /$1.php last;
    rewrite ^/([0-9]+)$ /space.php?uid=$1 last;

discuz 7 rewrite

    rewrite ^(.*)/archiver/((fid|tid)-[/w/-]+/.html)$ $1/archiver/index.php?$2 last;
    rewrite ^(.*)/forum-([0-9]+)-([0-9]+)/.html$ $1/forumdisplay.php?fid=$2&page=$3 last;
    rewrite ^(.*)/thread-([0-9]+)-([0-9]+)-([0-9]+)/.html$ $1/viewthread.php?tid=$2&extra=page/%3D$4&page=$3 last;
    rewrite ^(.*)/profile-(username|uid)-(.+)/.html$ $1/viewpro.php?$2=$3 last;
    rewrite ^(.*)/space-(username|uid)-(.+)/.html$ $1/space.php?$2=$3 last;
    rewrite ^(.*)/tag-(.+)/.html$ $1/tag.php?name=$2 last;

给discuz某版块单独配置域名

    server_name  bbs.c1gstudio.com news.c1gstudio.com;
     
         location = / {
            if ($http_host ~ news/.c1gstudio.com$) {
      rewrite ^.+ http://news.c1gstudio.com/forum-831-1.html last;
      break;
    }
         }

discuz ucenter 头像 rewrite 优化

    location ^~ /ucenter {
         location ~ .*/.php?$
         {
      #fastcgi_pass  unix:/tmp/php-cgi.sock;
      fastcgi_pass  127.0.0.1:9000;
      fastcgi_index index.php;
      include fcgi.conf;     
         }
     
         location /ucenter/data/avatar {
    log_not_found off;
    access_log   off;
    location ~ /(.*)_big/.jpg$ {
        error_page 404 /ucenter/images/noavatar_big.gif;
    }
    location ~ /(.*)_middle/.jpg$ {
        error_page 404 /ucenter/images/noavatar_middle.gif;
    }
    location ~ /(.*)_small/.jpg$ {
        error_page 404 /ucenter/images/noavatar_small.gif;
    }
    expires 300;
    break;
         }
                           }

jspace rewrite

    location ~ .*/.php?$
                 {
                      #fastcgi_pass  unix:/tmp/php-cgi.sock;
                      fastcgi_pass  127.0.0.1:9000;
                      fastcgi_index index.php;
                      include fcgi.conf;     
                 }
     
                 location ~* ^/index.php/
                 {
        rewrite ^/index.php/(.*) /index.php?$1 break;
                      fastcgi_pass  127.0.0.1:9000;
                      fastcgi_index index.php;
                      include fcgi.conf;
                 }

反向代理代理到新地址，浏览器地址栏显示原始地址
    location ~ ^/api/live/.*$ {
		proxy_next_upstream error timeout http_500 http_502 http_503 http_504;
		proxy_set_header Host  $host;
		proxy_set_header X-Forwarded-For  $http_x_forwarded_for;
		proxy_set_header cmccip $cmccip;
		proxy_pass http://new_pool;
		proxy_http_version 1.1;
		proxy_set_header Connection "";
		proxy_connect_timeout 10;
		proxy_read_timeout 15;
    }
	
	
Nginx: rewrite重定向的参数处理问题


【转载】今天在给某网站写rewrite重定向规则时，碰到了这个关于重定向的参数处理问题。默认的情况下，Nginx在进行rewrite后都会自动添加上旧地址中的参数部分，而这对于重定向到的新地址来说可能是多余。虽然这也不会对重定向的结果造成多少影响，但当你注意到新地址中包含有多余的“?xxx=xxx”时，心里总还是会觉得不爽。那么该如何来处理这部分的内容呢？看了下面两个简单的例子你就会明白了。
例如：
把http://example.com/test.php?para=xxx 重定向到 http://example.com/new
若按照默认的写法：rewrite ^/test.php(.*) /new permanent;
重定向后的结果是：http://example.com/new?para=xxx
如果改写成：rewrite ^/test.php(.*) /new? permanent;
那结果就是：http://example.com/new
所以，关键点就在于“？”这个尾缀。假如又想保留某个特定的参数，那又该如何呢？可以利用Nginx本身就带有的$arg_PARAMETER参数来实现。
例如：
把http://example.com/test.php?para=xxx&p=xx 重写向到 http://example.com/new?p=xx
可以写成：rewrite ^/test.php /new?p=$arg_p? permanent;
只求结果的朋友可以直接忽略前面的内容，看这里：
rewrite ^/test.php /new permanent; //重写向带参数的地址  last不跳转地址
rewrite ^/test.php /new? permanent; //重定向后不带参数
rewrite ^/test.php /new?id=$arg_id? permanent; //重定向后带指定的参数




