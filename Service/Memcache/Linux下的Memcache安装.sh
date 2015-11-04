
Linux下的Memcache安装



最近在研究怎么让Discuz!去应用Memcache去做一些事情，记录下Memcache安装的过程。

Linux下Memcache服务器端的安装
服务器端主要是安装memcache服务器端，目前的最新版本是 memcached-1.3.0 。
下载：http://www.danga.com/memcached/dist/memcached-1.2.2.tar.gz
另外，Memcache用到了libevent这个库用于Socket的处理，所以还需要安装libevent，libevent的最新版本是libevent-1.3。（如果你的系统已经安装了libevent，可以不用安装）
官网：http://www.monkey.org/~provos/libevent/
下载：http://www.monkey.org/~provos/libevent-1.3.tar.gz

用wget指令直接下载这两个东西.下载回源文件后。
1.先安装libevent。这个东西在配置时需要指定一个安装路径，即./configure --prefix=/usr；然后make；然后make install；
# yum install libevent-devel

2.再安装memcached，只是需要在配置时需要指定libevent的安装路径即./configure --with-libevent=/usr；然后make；然后make install；
这样就完成了Linux下Memcache服务器端的安装。详细的方法如下：

    1.分别把memcached和libevent下载回来，放到 /tmp 目录下：
    # cd /tmp
    # wget http://www.danga.com/memcached/dist/memcached-1.2.0.tar.gz
    # wget http://www.monkey.org/~provos/libevent-1.2.tar.gz

    2.先安装libevent：
    # tar zxvf libevent-1.2.tar.gz
    # cd libevent-1.2
    # ./configure --prefix=/usr
    # make
    # make install

    3.测试libevent是否安装成功：
    # ls -al /usr/lib | grep libevent
    lrwxrwxrwx 1 root root 21 11?? 12 17:38 libevent-1.2.so.1 -> libevent-1.2.so.1.0.3
    -rwxr-xr-x 1 root root 263546 11?? 12 17:38 libevent-1.2.so.1.0.3
    -rw-r--r-- 1 root root 454156 11?? 12 17:38 libevent.a
    -rwxr-xr-x 1 root root 811 11?? 12 17:38 libevent.la
    lrwxrwxrwx 1 root root 21 11?? 12 17:38 libevent.so -> libevent-1.2.so.1.0.3
    还不错，都安装上了。

    4.安装memcached，同时需要安装中指定libevent的安装位置：
    # cd /tmp
    # tar zxvf memcached-1.2.0.tar.gz
    # cd memcached-1.2.0
    # ./configure --with-libevent=/usr
    # make
    # make install
    如果中间出现报错，请仔细检查错误信息，按照错误信息来配置或者增加相应的库或者路径。
    安装完成后会把memcached放到 /usr/local/bin/memcached ，

    5.测试是否成功安装memcached：
    # ls -al /usr/local/bin/mem*
    -rwxr-xr-x 1 root root 137986 11?? 12 17:39 /usr/local/bin/memcached
    -rwxr-xr-x 1 root root 140179 11?? 12 17:39 /usr/local/bin/memcached-debug

安装Memcache的PHP扩展
1.在http://pecl.php.net/package/memcache 选择相应想要下载的memcache版本。
2.安装PHP的memcache扩展

    tar vxzf memcache-2.2.1.tgz
    cd memcache-2.2.1
	
	# yum install php-devel
	
    /usr/local/php/bin/phpize
    ./configure --enable-memcache --with-php-config=/usr/bin/php-config --with-zlib-dir
    make
    make install


3.上述安装完后会有类似这样的提示：

    Installing shared extensions: /usr/local/php/lib/php/extensions/no-debug-non-zts-2007xxxx/


4.把php.ini中的extension_dir = "./"修改为

    extension_dir = "/usr/local/php/lib/php/extensions/no-debug-non-zts-2007xxxx/"


5.添加一行来载入memcache扩展： extension=memcache.so

memcached的基本设置：
1.启动Memcache的服务器端：
# /usr/local/bin/memcached -d -m 10 -u root -l 192.168.0.200 -p 12000 -c 256 -P /tmp/memcached.pid

    -d选项是启动一个守护进程，
    -m是分配给Memcache使用的内存数量，单位是MB，我这里是10MB，
    -u是运行Memcache的用户，我这里是root，
    -l是监听的服务器IP地址，如果有多个地址的话，我这里指定了服务器的IP地址192.168.0.200，
    -p是设置Memcache监听的端口，我这里设置了12000，最好是1024以上的端口，
    -c选项是最大运行的并发连接数，默认是1024，我这里设置了256，按照你服务器的负载量来设定，
    -P是设置保存Memcache的pid文件，我这里是保存在 /tmp/memcached.pid，

2.如果要结束Memcache进程，执行：

    # kill `cat /tmp/memcached.pid`


也可以启动多个守护进程，不过端口不能重复。

3.重启apache，service httpd restart

Memcache环境测试：
运行下面的php文件，如果有输出This is a test!，就表示环境搭建成功。开始领略Memcache的魅力把！
< ?php
$mem = new Memcache;
$mem->connect("127.0.0.1", 11211);
$mem->set('key', 'This is a test!', 0, 60);
$val = $mem->get('key');
echo $val;
?>



/usr/local/bin/memcached -d -m 100 -u root -l 192.168.1.107 -p 12000 -c 256 -P /tmp/memcache.pid

telnet localhost 11211
#直接回城出现错误
ERROR

#查看当前状态命令
stats

STAT pid 22459                             进程ID
STAT uptime 1027046                        服务器运行秒数
STAT time 1273043062                       服务器当前unix时间戳
STAT version 1.4.4                         服务器版本
STAT pointer_size 64                       操作系统字大小(这台服务器是64位的)
STAT rusage_user 0.040000                  进程累计用户时间
STAT rusage_system 0.260000                进程累计系统时间
STAT curr_connections 10                   当前打开连接数
STAT total_connections 82                  曾打开的连接总数
STAT connection_structures 13              服务器分配的连接结构数
STAT cmd_get 54                            执行get命令总数
STAT cmd_set 34                            执行set命令总数
STAT cmd_flush 3                           指向flush_all命令总数
STAT get_hits 9                            get命中次数
STAT get_misses 45                         get未命中次数
STAT delete_misses 5                       delete未命中次数
STAT delete_hits 1                         delete命中次数
STAT incr_misses 0                         incr未命中次数
STAT incr_hits 0                           incr命中次数
STAT decr_misses 0                         decr未命中次数
STAT decr_hits 0                           decr命中次数
STAT cas_misses 0                          cas未命中次数
STAT cas_hits 0                            cas命中次数
STAT cas_badval 0                          使用擦拭次数
STAT auth_cmds 0
STAT auth_errors 0
STAT bytes_read 15785                      读取字节总数
STAT bytes_written 15222                   写入字节总数
STAT limit_maxbytes 1048576                分配的内存数（字节）
STAT accepting_conns 1                     目前接受的链接数
STAT listen_disabled_num 0                 
STAT threads 4                             线程数
STAT conn_yields 0
STAT bytes 0                               存储item字节数
STAT curr_items 0                          item个数
STAT total_items 34                        item总数
STAT evictions 0                           为获取空间删除item的总数



memcached数据存储和取回相关的基本命令只有4条。下面将采用telnet与memcached进行交互，并介绍这4条基本命令。假设memcached服务器在本机上，并监听在默认端口11211上。

telnet连接到memcached：telnet 127.0.0.1 11211

SET：添加一个新的条目到memcached，或是用新的数据替换掉已存在的条目

set test1 0 0 10
testing001
STORED

ADD：仅当key不存在的情况下存储数据。如果一个key已经存在，将得到NOT_STORED的响应

add test1 0 0 10
testing002
NOT_STORED
add test2 0 0 10
testing002
STORED

REPLACE：仅当key已经存在的情况下存储数据。如果一个key不存在，将得到NOT_STORED的响应

replace test1 0 0 10
testing003
STORED
replace test3 0 0 10
testing003
NOT_STORED

GET：从memcached中返回数据。从缓存中返回数据时，将在第一行得到key的名字，flag的值和返回的value的长度。真正的数据在第二行，最后返回END。如果key并不存在，那么在第一行就直接返回END。

get test1
VALUE test1 0 10
testing003
END
get test4
END
get test1 test2
VALUE test1 0 10
testing003
END

注：像上面那样你可以在一个请求中包含多个由空格分开的key。当请求多个key时，将只会得到那些有存储数据的key的响应。memcached将不会响应没有存储Data的key。 



参考资料：
对Memcached有疑问的朋友可以参考下列文章：
Linux下的Memcache安装：http://www.ccvita.com/257.html
Windows下的Memcache安装：http://www.ccvita.com/258.html
Memcache基础教程：http://www.ccvita.com/259.html
Discuz!的Memcache缓存实现：http://www.ccvita.com/261.html
Memcache协议中文版：http://www.ccvita.com/306.html
Memcache分布式部署方案：http://www.ccvita.com/395.html