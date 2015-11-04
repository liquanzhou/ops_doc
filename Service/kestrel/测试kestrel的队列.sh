 测试kestrel的队列（一）

一、依赖环境的安装 
1、sbt 
wget http://typesafe.artifactoryonline.com/typesafe/ivy-releases/org.scala-tools.sbt/sbt-launch/0.11.2/sbt-launch.jar  
mv sbt-launch.jar /usr/local/bin/  
echo 'java -Xmx512M -jar `dirname $0`/sbt-launch.jar "$@"' >> /usr/local/bin/sbt  
chmod 777 /usr/local/bin/sbt 
2、daemon 
wget http://libslack.org/daemon/download/daemon-0.6.4.tar.gz  
tar xzvf daemon-0.6.4.tar.gz  
./configure  
make & make install  
二、安装kestrel 
wget http://robey.github.com/kestrel/download/kestrel-2.2.0.zip
unzip kestrel-2.2.0.zip
mv kestrel-2.2.0 /usr/local/kestrel
mkdir /usr/local/kestrel/current
cp /usr/local/kestrel/*.jar /usr/local/kestrel/current 


三 启动 kestrel
nohup java -jar /usr/local/kestrel/kestrel_2.9.1-2.2.0.jar &




四 通过telnet命令的基本使用
Kestrel有三种协议：memcached、thrift、text。分别在独立的端口提供服务，默认如下：
memcached  => 22133，thrift => 2229 ,text => 2222
text相对简单，模拟消息生产和消费：telnet到Kestrel server上，使用"put <queue_name>:\nmessage\n\n"进行生产和"get <queue_name>\n"进行消费，"\n"看作回车键即可。


我们只测试memcached协议


[root@xen189v-t ~]# telnet 127.0.0.1 22133
Trying 127.0.0.1...
Connected to xen189v.ops.corp.qihoo.net (127.0.0.1).
Escape character is '^]'.
reload
Reloaded config.
DUMP_STATS
queue 'uptime' {
 items=0
 bytes=0
 total_items=0
 logsize=0
 expired_items=0
 mem_items=0
 mem_bytes=0
 age=0
 discarded=0
 waiters=0
 open_transactions=0
 total_flushes=0
}
END
stats
STAT uptime 507
STAT time 1378360712
STAT version 2.2.0
STAT curr_items 0
STAT total_items 0
STAT bytes 0
STAT reserved_memory_ratio 0.070
STAT curr_connections 1
STAT total_connections 9
STAT cmd_get 1
STAT cmd_set 0
STAT cmd_peek 0
STAT get_hits 0
STAT get_misses 1
STAT bytes_read 255
STAT bytes_written 2015
STAT queue_creates 1
STAT queue_deletes 0
STAT queue_expires 0
STAT queue_uptime_items 0
STAT queue_uptime_bytes 0
STAT queue_uptime_total_items 0
STAT queue_uptime_logsize 0
STAT queue_uptime_expired_items 0
STAT queue_uptime_mem_items 0
STAT queue_uptime_mem_bytes 0
STAT queue_uptime_age 0
STAT queue_uptime_discarded 0
STAT queue_uptime_waiters 0
STAT queue_uptime_open_transactions 0
STAT queue_uptime_total_flushes 0
END
 ######################################################################
 测试队列的先进先出


 [root@xen189v-t ~]# telnet 127.0.0.1 22133
Trying 127.0.0.1...
Connected to xen189v.ops.corp.qihoo.net (127.0.0.1).
Escape character is '^]'.
set fuck 0 0 2
d1
STORED
set fuck 0 0 3
kkk
STORED
set fuck 0 0 8
xxxdddkk
STORED
get fuck
VALUE fuck 0 2
d1
END
get fuck
VALUE fuck 0 3
kkk
END
get fuck
VALUE fuck 0 8
xxxdddkk
END
stats
STAT uptime 1307
STAT time 1378361512
STAT version 2.2.0
STAT curr_items 0
STAT total_items 9
STAT bytes 0
STAT reserved_memory_ratio 0.211
STAT curr_connections 1
STAT total_connections 20
STAT cmd_get 12
STAT cmd_set 9
STAT cmd_peek 0
STAT get_hits 9
STAT get_misses 3
STAT bytes_read 677
STAT bytes_written 9093
STAT queue_creates 3
STAT queue_deletes 0
STAT queue_expires 0
STAT queue_fuck_items 0
STAT queue_fuck_bytes 0
STAT queue_fuck_total_items 9
STAT queue_fuck_logsize 252
STAT queue_fuck_expired_items 0
STAT queue_fuck_mem_items 0
STAT queue_fuck_mem_bytes 0
STAT queue_fuck_age 0
STAT queue_fuck_discarded 0
STAT queue_fuck_waiters 0
STAT queue_fuck_open_transactions 0
STAT queue_fuck_total_flushes 0
STAT queue_uptime_items 0
STAT queue_uptime_bytes 0
STAT queue_uptime_total_items 0
STAT queue_uptime_logsize 0
STAT queue_uptime_expired_items 0
STAT queue_uptime_mem_items 0
STAT queue_uptime_mem_bytes 0
STAT queue_uptime_age 0
STAT queue_uptime_discarded 0
STAT queue_uptime_waiters 0
STAT queue_uptime_open_transactions 0
STAT queue_uptime_total_flushes 0
STAT queue_aaa_items 0
STAT queue_aaa_bytes 0
STAT queue_aaa_total_items 0
STAT queue_aaa_logsize 0
STAT queue_aaa_expired_items 0
STAT queue_aaa_mem_items 0
STAT queue_aaa_mem_bytes 0
STAT queue_aaa_age 0
STAT queue_aaa_discarded 0
STAT queue_aaa_waiters 0
STAT queue_aaa_open_transactions 0
STAT queue_aaa_total_flushes 0
END
 

继续

get fuck
END

因为队列加的3个数据，统统被取出来了。

五 kestrel认知
1）Kestrel是twitter开源的一个scala写的简单高效MQ,采用的协议是memcached的文本协议，但是并不完全支持所有memcached协议，也不是完全兼容现有协议。
2）标准的协议它仅支持GET、SET、FLUSH_ALL、STATS，
3）Kestrel是一个队列服务器


六 kestrel实现memcache协议的命令如下：  
The kestrel implementation of the memcache protocol commands is described below.  
 
SET <queue-name> <flags (ignored)> <expiration> <# bytes>  
Add an item to a queue. It may fail if the queue has a size or item limit and it's full.  
 
GET <queue-name>[options]  
Remove an item from a queue. It will return an empty response immediately if the queue is empty. 


DELETE <queue-name>   删除某个队列同时删除所有条目,也会删除有关联的日志文件  
Drop a queue, discarding any items in it, and deleting any associated journal files.  
 
FLUSH <queue-name>   删除某个队列中的所有条目  
Discard all items remaining in this queue. The queue remains live and new items can be added. The time it takes to flush will be linear to the current queue size, and any other activity on this queue will block while it's being flushed.  
 
FLUSH_ALL  删除所有队列中的所有条目，就好像是每个队列都接受到了FLUSH命令一样  
Discard all items remaining in all queues. The queues are flushed one at a time, as if kestrel received a FLUSH command for each queue.  
 
VERSION   查询KESTREL的版本号  
Display the kestrel version in a way compatible with memcache.  
 
SHUTDOWN  关闭KESTREL服务器然后退出  
Cleanly shutdown the server and exit.  
 
RELOAD   重新加载配置文件  
Reload the config file and reconfigure all queues. This should have no noticable effect on the server is responsiveness.  
 
STATS  跟MEMCACHE显示的格式一样显示  
Display server stats in memcache style. Theyre described below.  
 
DUMP_STATS  按照队列名分组来显示  
Display server stats in a more readable style, grouped by queue. Theyre described below.   


 测试kestrel的队列（二）

 
1.安装kestrel队列服务，见（一）
2.php的扩展memcached的安装
wget http://pecl.php.net/get/memcached-1.0.2.tgz
tar zxvf  memcached-1.0.2.tgz
cd memcached-1.0.2
/usr/local/php/bin/phpize
./configure -enable-memcached -with-php-config=/usr/local/php/bin/php-config -with-libmemcached-dir=/usr/local/libmemcached
./configure -prefix=/usr/local/phpmemcached -with-memcached
make && make install 
vi /usr/local/php/lib/php.ini
extension=memcache.so
3.通过php memcached 扩展链接添加和取kestrel队列
<?php 
$mem = new Memcache; 
$mem->addServer("127.0.0.1", '22133');  
$mem->set('queueTest','aaaa'); 
$mem->set('queueTest','xxxx');  
$mem->set('queueTest','xxxx333'); 
print $mem->get('queueTest' )."=get\n"; 
print $mem->get('queueTest' )."=get\n"; 
print $mem->get('queueTest' )."=get\n"; 
$mem->close();
?>
测试队列结果
# php testQueue.php 
aaaa=get
xxxx=get
xxxx333=get


4.测试其他：
<?php 
$mem = new Memcache; 
$mem->addServer("127.0.0.1", '22133');  
 
$stats = $mem->getStats ( );   
print_r($stats);
$mem->close();
?>


# php testOther.php 
Array
(
    [uptime] => 102079
    [time] => 1378462285
    [version] => 2.2.0
    [curr_items] => 0
    [total_items] => 41
    [bytes] => 0
    [reserved_memory_ratio] => 0.352
    [curr_connections] => 1
    [total_connections] => 133
    [cmd_get] => 47
    [cmd_set] => 41
    [cmd_peek] => 0
    [get_hits] => 39
    [get_misses] => 8
    [bytes_read] => 3199
    [bytes_written] => 14377
    [queue_creates] => 7
    [queue_deletes] => 2
    [queue_expires] => 0
    [queue_fuck_items] => 0
    [queue_fuck_bytes] => 0
    [queue_fuck_total_items] => 9
    [queue_fuck_logsize] => 252
    [queue_fuck_expired_items] => 0
    [queue_fuck_mem_items] => 0
    [queue_fuck_mem_bytes] => 0
    [queue_fuck_age] => 0
    [queue_fuck_discarded] => 0
    [queue_fuck_waiters] => 0
    [queue_fuck_open_transactions] => 0
    [queue_fuck_total_flushes] => 0
    [queue_uptime_items] => 0
    [queue_uptime_bytes] => 0
    [queue_uptime_total_items] => 0
    [queue_uptime_logsize] => 0
    [queue_uptime_expired_items] => 0
    [queue_uptime_mem_items] => 0
    [queue_uptime_mem_bytes] => 0
    [queue_uptime_age] => 0
    [queue_uptime_discarded] => 0
    [queue_uptime_waiters] => 0
    [queue_uptime_open_transactions] => 0
    [queue_uptime_total_flushes] => 0
    [queue_queueTest_items] => 0
    [queue_queueTest_bytes] => 0
    [queue_queueTest_total_items] => 5
    [queue_queueTest_logsize] => 136
    [queue_queueTest_expired_items] => 0
    [queue_queueTest_mem_items] => 0
    [queue_queueTest_mem_bytes] => 0
    [queue_queueTest_age] => 0
    [queue_queueTest_discarded] => 0
    [queue_queueTest_waiters] => 0
    [queue_queueTest_open_transactions] => 0
    [queue_queueTest_total_flushes] => 0
    [queue_hx_items] => 0
    [queue_hx_bytes] => 0
    [queue_hx_total_items] => 3
    [queue_hx_logsize] => 83
    [queue_hx_expired_items] => 0
    [queue_hx_mem_items] => 0
    [queue_hx_mem_bytes] => 0
    [queue_hx_age] => 0
    [queue_hx_discarded] => 0
    [queue_hx_waiters] => 0
    [queue_hx_open_transactions] => 0
    [queue_hx_total_flushes] => 0
    [queue_aaa_items] => 0
    [queue_aaa_bytes] => 0
    [queue_aaa_total_items] => 0
    [queue_aaa_logsize] => 0
    [queue_aaa_expired_items] => 0
    [queue_aaa_mem_items] => 0
    [queue_aaa_mem_bytes] => 0
    [queue_aaa_age] => 0
    [queue_aaa_discarded] => 0
    [queue_aaa_waiters] => 0
    [queue_aaa_open_transactions] => 0
    [queue_aaa_total_flushes] => 0
) 