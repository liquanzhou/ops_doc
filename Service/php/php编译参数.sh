./configure \
--prefix=/usr/local/php \
--with-apxs2=/usr/sbin/apxs \
--with-mysql=/usr/local/mysql \
--with-xmlrpc \
--with-openssl \
--with-zlib-dir=/usr/include \
--with-freetype-dir \
--with-gd \
--with-png-dir \
--with-iconv \
--enable-short-tags \
--enable-sockets \
--enable-zend-multibyte \
--enable-soap \
--enable-mbstring \
--enable-static \
--enable-gd-native-ttf \
--with-curl \
--with-xsl \
--with-libxml-dir \
--enable-sigchild \
--enable-pcntl \
--enable-bcmath

make 
make install



vim conf/httpd.conf
# 添加
LoadModule php5_module        /usr/lib64/httpd/modules/libphp5.so


vim conf.d/php.conf

<IfModule worker.c>
  LoadModule php5_module modules/libphp5.so
</IfModule>

AddHandler php5-script .php
AddType text/html .php

DirectoryIndex index.php