lnmp/nginx系统真正有效防盗链完整设置方法


2013-03-25 10:34:13
标签：nginx lnmp 设置方法 有效防盗链

Ps：防盗链的意义就是保证自己的版权，不免网站的流量流失，为他人做嫁衣。下面是网上看到的三种方法：

######################################

修改 /usr/local/nginx/conf/nginx.conf 这个配置文件。

找到

location ~ .*.(gif|jpg|jpeg|png|bmp|swf)$
{
expires      30d;
}

修改成：
location ~ .*.(gif|jpg|jpeg|png|bmp|swf)$
{
valid_referers none blocked *.jannn.com jannn.com;
if($invalid_referer) {
rewrite ^/ http://www.jannn.com/404.jpg;
#return404;
}
expires      30d;
}

第一行： location ~ .*.(gif|jpg|jpeg|png|bmp|swf)$

其中“gif|jpg|jpeg|png|bmp|swf”设置防盗链文件类型，自行修改，每个后缀用“|”符号分开！

第三行：valid_referers none blocked *.jannn.com jannn.com;

就是白名单，允许文件链出的域名白名单，自行修改成您的域名！*.jannn.com这个指的是子域名，域名与域名之间使用空格隔开！

第五行：rewrite ^/ http://www.jannn.com/404.jpg;

这个图片是盗链返回的图片，也就是替换盗链网站所有盗链的图片。这个图片要放在没有设置防盗链的网站上，因为防盗链的作用，这个图片如果也放在防盗链网站上就会被当作防盗链显示不出来了，盗链者的网站所盗链图片会显示X符号。

这样设置差不多就可以起到防盗链作用了，上面说了，这样并不是彻底地实现真正意义上的防盗链！

我们来看第三行：valid_referers none blocked *.jannn.com jannn.com;

valid_referers 里多了“none blocked”

我们把“none blocked”删掉，改成

valid_referers  *.jannn.com jannn.com;

nginx彻底地实现真正意义上的防盗链完整的代码应该是这样的：
location ~ .*.(gif|jpg|jpeg|png|bmp|swf)$
{
valid_referers *.jannn.com jannn.com;

if($invalid_referer) {
rewrite ^/ http://www.jannn.com/404.jpg;
#return404;
}
expires      30d;
}

这样您在浏览器直接输入图片地址就不会再显示图片出来了，也不可能会再右键另存什么的。

第五行：rewrite ^/ http://www.jannn.com/404.jpg;

这个是给图片防盗链设置的防盗链返回图片，如果我们是文件需要防盗链下载，把第五行：

rewrite ^/ http://www.jannn.com/404.jpg;

改成一个链接，可以是您主站的链接，比如把第五行改成小简博客主页：

rewrite ^/ http://www.jannn.com;

这样，当别人输入文件下载地址，由于防盗链下载的作用就会跳转到您设置的这个链接！

最后，配置文件设置完成别忘记重启nginx生效！

平滑重启nginx：
1    /etc/init.d/nginx reload

后面几种方法：

原文：Nginx防盗链详细解说

一般常用的方法是在server或者location段中加入!
valid_referers   none  blocked  www.yiibase.com yiibase.com;

详见下面的例子

一、针对不同的文件类型
上面那篇文章详细且经过本人的实践，却是可行，网上大都说是

location ~* .(gif|jpg|jpeg|png|bmp|txt|zip|jar|swf)$ {
valid_referers none blocked *.mynginx.com;
if ($invalid_referer) {
rewrite ^/  http://www.mynginx.com/daolian.gif;
#return 403;
}
}

将这段代码添加到server段，但是其实后面还有

location ~ .*.(gif|jpg|jpeg|png|bmp|swf)$
{
expires      30d;
}

必须将这两段代码合成为一段，否则，防盗链并不会生效。有点奇怪的是，我开放到防盗链开始几天都是没出现资金的防盗链图片，过了几天后才出现的，不知道为什么，知道的也可以告诉我。
二、针对不同的目录

location /img/ {
root /data/img/;
valid_referers none blocked *.yiibase.com yiibase.com;
if($invalid_referer) {
rewrite  ^/  http://www.yiibase.com/images/error.gif;
#return403;
}
}

以上是nginx自带的防盗链功能。

三、nginx 的第三方模块ngx_http_accesskey_module 来实现下载文件的防盗链

安装Nginx和nginx-http-access模块

#tar zxvf nginx-0.7.61.tar.gz
#cd nginx-0.7.61/
#tar xvfz nginx-accesskey-2.0.3.tar.gz
#cd nginx-accesskey-2.0.3
#vi config
#把HTTP_MODULES=”$HTTP_MODULES $HTTP_ACCESSKEY_MODULE”
#修改成HTTP_MODULES=”$HTTP_MODULESngx_http_accesskey_module
#(这是此模块的一个bug)
#./configure –user=www –group=www
–prefix=/usr/local/nginx –with-http_stub_status_module
–with-http_ssl_module –add-module=/root/nginx-accesskey-2.0.3
server{
…..
location /download {
accesskey             on;
accesskey_hashmethod  md5;
accesskey_arg         “key”;
accesskey_signature   “mypass$remote_addr”;
}
}

/download 为你下载的目录。

前台php产生的下载路径格式是：

1.http://*****.com/download/1.zip?key=<?php echo md5(‘mypass’.$_SERVER["REMOTE_ADDR"]);?>
这样，当访问没有跟参数一样时，其他用户打开时，就出现：403

NginxHttpAccessKeyModule第三方模块，实现方法如下：

1.下载Nginx HttpAccessKeyModule模块文件：Nginx-accesskey-2.0.3.tar.gz；

2.解压此文件后，找到nginx-accesskey-2.0.3下的config文件。编辑此文件：替换其中的”$HTTP_ACCESSKEY_MODULE”为”ngx_http_accesskey_module”；

3.用一下参数重新编译nginx：

./configure –add-module=path/to/nginx-accesskey

4.修改nginx的conf文件，添加以下几行：

location /download {
accesskey             on;
accesskey_hashmethod  md5;
accesskey_arg         “key”;
accesskey_signature   “mypass$remote_addr”;
}

其中：
accesskey为模块开关；
accesskey_hashmethod为加密方式MD5或者SHA-1；
accesskey_arg为url中的关键字参数；
accesskey_signature为加密值，此处为mypass和访问IP构成的字符串。
访问测试脚本download.php：

<?php
$ipkey= md5(“mypass”.$_SERVER['REMOTE_ADDR']);
$output_add_key=”<a href=http://www.example.cn/download/G3200507120520LM.rar?key=”.$ipkey.”>
download_add_key</a>”;
$output_org_url=”<a href=http://www.example.cn/download
/G3200507120520LM.rar>download_org_path</a>”;

echo$output_add_key;
echo$output_org_url;
?>

访问第一个download_add_key链接可以正常下载，第二个链接download_org_path会返回403 Forbidden错误。

如果不怕麻烦，有条件实现的话，推荐使用Nginx HttpAccessKeyModule这个东西。

他的运行方式是：如我的download 目录下有一个 file.zip 的文件。对应的URI 是http://www.yiibase.com/download/file.zip
使用ngx_http_accesskey_module 模块后http://www.yiibase.com/download/file.zip?key=09093abeac094. 只有给定的key值正确了，才能够下载download目录下的file.zip。而且 key 值是根据用户的IP有关的，这样就可以避免被盗链了。

据说Nginx HttpAccessKeyModule现在连迅雷都可以防了，可以尝试一下。

下载：
Nginx 0.8.51 稳定版下载：nginx-0.8.51，nginx/Windows-0.8.51
HttpAccessKeyModule第三方模块下载：http://wiki.nginx.org/images/5/51/Nginx-accesskey-2.0.3.tar.gz

http://shitouququ.blog.51cto.com/24569/1161880