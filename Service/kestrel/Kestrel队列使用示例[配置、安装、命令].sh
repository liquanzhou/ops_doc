Kestrel队列使用示例[配置、安装、命令]

kestrel认知

1）Kestrel是twitter开源的一个scala写的简单高效MQ,采用的协议是memcached的文本协议，但是并不完全支持所有memcached协议，也不是完全兼容现有协议。

2）标准的协议它仅支持GET、SET、FLUSH_ALL、STATS，

3）Kestrel是一个队列服务器

kestrel的项目主页   http://github.com/robey/kestrel  
Kestrel的安装配置   http://robey.github.io/kestrel/readme.html  
                    https://github.com/robey/kestrel/blob/master/docs/guide.md  
                    http://dmouse.iteye.com/blog/1746171  
kestrel的wiki页     http://wiki.github.com/robey/kestrel  
memcache官网        http://www.memcached.org/  
xmemcached项目主页  http://code.google.com/p/xmemcached/  


--------------------有关kestrel定义，官方如下很多描述  
Kestrel  
Kestrel is a simple, distributed message queue written on the JVM, based on Blaine Cook's "starling".  
Each server handles a set of reliable, ordered message queues, with no cross communication, resulting in a cluster of k-ordered ("loosely ordered") queues. Kestrel is fast, small, and reliable.  
  
Kestrel is:  
1)fast  
It runs on the JVM so it can take advantage of the hard work people have put into java performance.  
  
2)small  
Currently about 2500 lines of scala, because it relies on Netty (a rough equivalent of Danger's ziggurat or Ruby's EventMachine) -- and because Scala is extremely expressive.  
  
3)durable  
Queues are stored in memory for speed, but logged into a journal on disk so that servers can be shutdown or moved without losing any data.  
  
4)reliable  
A client can ask to "tentatively" fetch an item from a queue, and if that client disconnects from kestrel before confirming ownership of the item, the item is handed to another client. In this way, crashing clients don't cause lost messages.  
  
  
Kestrel is based on Blaine Cook's "starling" simple, distributed message queue, with added features and bulletproofing, as well as the scalability offered by actors and the JVM.  
  
Each server handles a set of reliable, ordered message queues. When you put a cluster of these servers together, with no cross communication, and pick a server at random whenever you do a set or get, you end up with a reliable, loosely ordered message queue.  
  
In many situations, loose ordering is sufficient. Dropping the requirement on cross communication makes it horizontally scale to infinity and beyond: no multicast, no clustering, no "elections", no coordination at all. No talking! Shhh!  
  
Kestrel is a very simple message queue that runs on the JVM. It supports multiple protocols:  
memcache: the memcache protocol, with some extensions  
thrift: Apache Thrift-based RPC  
text: a simple text-based protocol  
  
  
Features  
memcache protocol  
thrift protocol  
journaled (durable) queues  
fanout queues (one writer, many readers)  
item expiration  
transactional reads  
----------------------------有关kestrel定义，官方如上很多描述  
  
telnet 202.108.1.121 22133  
命令：  
stats  
  
Server stats  
Global stats reported by kestrel are:  
执行完stats命令，命令行上最上面的是返回值如下：  
  
uptime - seconds the server has been online   kestrel服务已经启动多少秒  
time - current time in unix epoch     当前kestrel服务器的时间  
version - version string, like "1.2"   kestrel的版本号  
curr_items - total of items waiting in all queues  所有队列的ITEM条目数的总和  
total_itmes - total of items that have ever been added in this server's lifetime  曾经被添加到队列的所有条目的生存时间总和  
bytes - total byte size of items waiting in all queues  被写入队列的所有条目的字节数总和  
curr_connections - current open connections from clients  当前客户端打开有多少个连接  
total_connections - total connections that have been opened in this server's lifetime  在服务器打开的这段时间类总共的连接数  
cmd_get - total GET requests    get请求的总次数  
cmd_set - total SET requests    set请求的总次数  
cmd_peek - total GET/peek requests peek请求总次数  
get_hits - total GET requests that received an item  get请求命令次数  
get_misses - total GET requests on an empty queue  get请求无效的次数,也就是请求在了空的队列上  
bytes_read - total bytes read from clients    客户端总共读取字节总数  
bytes_written - total bytes written to clients  写往客户端的总字节数  
queue_creates - total number of queues created  当前kestrel上已经创建的队列总数  
queue_deletes - total number of queues deleted (includes expires) 已经删除的队列总数  
queue_expires - total number of queues expires  已经过期的队列总数  
  
------例如：  
STAT uptime 26327844  
STAT time 1375153623  
STAT version 2.1.3  
STAT curr_items 7727349  
STAT total_items 460922839  
STAT bytes 2552974113  
STAT curr_connections 146  
STAT total_connections 25500291  
STAT cmd_get 10776718344  
STAT cmd_set 460922839  
STAT cmd_peek 0  
STAT get_hits 383861308  
STAT get_misses 10392857037  
STAT bytes_read 1957725152259  
STAT bytes_written 1777370590356   
------  
  
紧接着上面那几条返回值，是许多类似下面的条目：  
For each queue, the following stats are also reported:  
  
items - items waiting in this queue    队列中当前存在的条目数  
bytes - total byte size of items waiting in this queue   队列中当前条目的总字节数  
total_items - total items that have been added to this queue in this server's lifetime  总共向队列中添加的条目总个数  
logsize - byte size of the queue's journal file   当前队列日志的大小  
expired_items - total items that have been expired from this queue in this server's lifetime 当前队列失效的条目总数  
mem_items - items in this queue that are currently in memory    当前队列中存在于内存中的条目数  
mem_bytes - total byte size of items in this queue that are currently in memory (will always be less than or equal to max_memory_size config for the queue)  
age - time, in milliseconds, that the last item to be fetched from this queue had been waiting; that is, the time between SET and GET; if the queue is empty, this will always be zero  
discarded - number of items discarded because the queue was too full  
waiters - number of clients waiting for an item from this queue (using GET/t)  
open_transactions - items read with /open but not yet confirmed  
transactions - number of transactional get requests (irrespective of whether an item was read or not)  
canceled_transactions - number of transactional get requests canceled (for any reason)  
total_flushes - total number of times this queue has been flushed  
age_msec - age of the last item read from the queue  
create_time - the time that the queue was created (in milliseconds since epoch)  
  
-----例如：  
STAT queue_hems_ds_news_items 0  
STAT queue_hems_ds_news_bytes 0  
STAT queue_hems_ds_news_total_items 27231842  
STAT queue_hems_ds_news_logsize 15425969  
STAT queue_hems_ds_news_expired_items 0  
STAT queue_hems_ds_news_mem_items 0  
STAT queue_hems_ds_news_mem_bytes 0  
STAT queue_hems_ds_news_age 0  
STAT queue_hems_ds_news_discarded 0  
STAT queue_hems_ds_news_waiters 0  
STAT queue_hems_ds_news_open_transactions 0  
  
  
DUMP_STATS  命令会以队列分组的格式显示出来  
===========================  
  
关于三种协议：  
Protocols  
Kestrel supports three protocols: memcache, thrift and text.   
The Finagle project can be used to connect clients to a Kestrel server via the memcache or thrift protocols.  
Finagle项目可以通过thrift协议或者memcache协议使客户端连接到kestrel服务器  
  
Thrift  
The thrift protocol is documented in the thrift IDL: kestrel.thrift  
Reliable reads via the thrift protocol are specified by indicating how long the server should wait before aborting the unacknowledged read.  
  
Memcache  
kestrel遵守memcache官方标准协议，如下这个文件有描述：  
The official memcache protocol is described here: protocol.txt  
https://github.com/memcached/memcached/blob/master/doc/protocol.txt  
  
  
Text protocol  
kestrel支持受限制的，只是文本的协议。不过还是推荐你用memcache协议替代文本协议。因为文本协议不支持可靠的读操作。  
Kestrel supports a limited, text-only protocol. You are encouraged to use the memcache protocol instead.  
The text protocol does not support reliable reads.  
  
  
  
  
  
kestrel实现memcache协议的命令如下：  
The kestrel implementation of the memcache protocol commands is described below.  
  
SET <queue-name> <flags (ignored)> <expiration> <# bytes>  
Add an item to a queue. It may fail if the queue has a size or item limit and it's full.  
  
GET <queue-name>[options]  
Remove an item from a queue. It will return an empty response immediately if the queue is empty. The queue name may be followed by options separated by /:  
  
/t=<milliseconds>  
Wait up to a given time limit for a new item to arrive. If an item arrives on the queue within this timeout, it's returned as normal. Otherwise, after that timeout, an empty response is returned.  
  
/open  
Tentatively remove an item from the queue. The item is returned as usual but is also set aside in case the client disappears before sending a "close" request. (See "Reliable Reads" below.)  
  
/close  
Close any existing open read. (See "Reliable Reads" below.)  
  
/abort  
Cancel any existing open read, returing that item to the head of the queue. It will be the next item fetched. (See "Reliable Reads" below.)  
  
/peek  
Return the first available item from the queue, if there is one, but don't remove it. You can't combine this with any of the reliable read options.  
  
For example, to open a new read, waiting up to 500msec for an item:  
    GET work/t=500/open  
Or to close an existing read and open a new one:  
    GET work/close/open  
  
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
Reload the config file and reconfigure all queues. This should have no noticable effect on the server's responsiveness.  
  
STATS  跟MEMCACHE显示的格式一样显示  
Display server stats in memcache style. They're described below.  
  
DUMP_STATS  按照队列名分组来显示  
Display server stats in a more readable style, grouped by queue. They're described below.  
  
MONITOR <queue-name> <seconds> [max-items]  
Monitor a queue for a time, fetching any new items that arrive, up to an optional maximum number of items. Clients are queued in a fair fashion, per-item, so many clients may monitor a queue at once. After the given timeout, a separate END response will signal the end of the monitor period. Any fetched items are open transactions (see "Reliable Reads" below), and should be closed with CONFIRM.  
  
CONFIRM <queue-name> <count>  
Confirm receipt of count items from a queue. Usually this is the response to a MONITOR command, to confirm the items that arrived during the monitor period.  
  
STATUS  
Displays the kestrel server's current status (see section on Server Status, below).  
  
STATUS <new-status>  
Switches the kestrel server's current status to the given status (see section on Server Status, below).  
  
------------------  
另附其他参考：http://www.blogjava.net/killme2008/archive/2009/09/15/295119.html 