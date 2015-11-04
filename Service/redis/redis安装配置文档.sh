redis安装配置文档

# 非常详细redis的介绍
http://blog.chinaunix.net/uid-790245-id-3766268.html

wget http://redis.googlecode.com/files/redis-2.6.10.tar.gz

tar zxvf redis-2.6.10.tar.gz -C /usr/local/

cd /usr/local/redis-2.6.10

make
make install

# make命令执行完成后，会在src目录下生成5个可执行文件：
# redis-server  Redis服务器的daemon启动程序
# redis-cli  Redis命令行操作工具。当然，你也可以用telnet根据其纯文本协议来操作
# redis-benchmark  Redis性能测试工具，测试Redis在你的系统及你的配置下的读写性能
# redis-check-aof  更新日志检查
# redis-check-dump  用于本地数据库检查 

echo "1">/proc/sys/vm/overcommit_memory
#1表示内核允许分配所有的物理内存，而不管当前的内存状态如何。

cp redis-benchmark redis-cli redis-server /usr/bin/
cp redis.conf /etc/   # redis启动配置文件
# redis.conf 配置文件详解

___________________________________________________________________________________

#是否作为守护进程运行
daemonize yes

#如以后台进程运行，则需指定一个pid，默认为/var/run/redis.pid
pidfile redis.pid

#绑定主机IP，默认值为127.0.0.1
#bind 127.0.0.1

#Redis默认监听端口
port 6379

#客户端闲置多少秒后，断开连接，默认为300（秒）
timeout 300

#日志记录等级，有4个可选值，debug，verbose（默认值），notice，warning
loglevel verbose

#指定日志输出的文件名，默认值为stdout，也可设为/dev/null屏蔽日志
logfile stdout

#可用数据库数，默认值为16，默认数据库为0
databases 16

#保存数据到disk的策略

#当有一条Keys数据被改变是，900秒刷新到disk一次
save 900 1

#当有10条Keys数据被改变时，300秒刷新到disk一次
save 300 10

#当有1w条keys数据被改变时，60秒刷新到disk一次
save 60 10000

#当dump .rdb数据库的时候是否压缩数据对象
rdbcompression yes

#存储和加载rdb文件时校验
rdbchecksum yes    

#本地数据库文件名，默认值为dump.rdb
dbfilename dump.rdb

#后台存储错误停止写。
stop-writes-on-bgsave-error yes 

#本地数据库存放路径，默认值为 ./
dir /var/lib/redis/

########### Replication #####################

#Redis的复制配置

# slaveof <masterip> <masterport> 当本机为从服务时，设置主服务的IP及端口

# masterauth <master-password> 当本机为从服务时，设置主服务的连接密码

#连接密码

# requirepass foobared

#最大客户端连接数，默认不限制

# maxclients 128

#最大内存使用设置，达到最大内存设置后，Redis会先尝试清除已到期或即将到期的Key，当此方法处理后，任到达最大内存设置，将无法再进行写入操作。

# maxmemory <bytes>

#是否在每次更新操作后进行日志记录，如果不开启，可能会在断电时导致一段时间内的数据丢失。因为redis本身同步数据文件是按上面save条件来同步的，所以有的数据会在一段时间内只存在于内存中。默认值为no

appendonly no

#更新日志文件名，默认值为appendonly.aof

#appendfilename

#更新日志条件，共有3个可选值。no表示等操作系统进行数据缓存同步到磁盘，always表示每次更新操作后手动调用fsync()将数据写到磁盘，everysec表示每秒同步一次（默认值）。

# appendfsync always

appendfsync everysec

# appendfsync no

#当slave失去与master的连接，或正在拷贝中，如果为yes，slave会响应客户端的请求，数据可能不同步甚至没有数据，如果为no，slave会返回错误"SYNC with master in progress"
slave-serve-stale-data yes

#如果为yes，slave实例只读，如果为no，slave实例可读可写。
slave-read-only yes    



# 在slave和master同步后（发送psync/sync），后续的同步是否设置成TCP_NODELAY . 假如设置成yes，则redis会合并小的TCP包从而节省带宽，但会增加同步延迟（40ms），造成master与slave数据不一致  假如设置成no，则redis master会立即发送同步数据，没有延迟
repl-disable-tcp-nodelay no

#如果master不能再正常工作，那么会在多个slave中，选择优先值最小的一个slave提升为master，优先值为0表示不能提升为master。
slave-priority 100


#### LIMITS ####
maxclients 10000    #客户端并发连接数的上限是10000，到达上限，服务器会关闭所有新连接并返回错误"max number of clients reached"

maxmemory 15G    #设置最大内存，到达上限，服务器会根据驱逐政策(eviction policy)删除某些键值，如果政策被设置为noeviction，那么redis只读，对于增加内存的操作请求返回错误。

#### APPEND ONLY MODE ####
appendonly no    #redis默认采用快照(snapshotting)异步转存到硬盘中，它是根据save指令来触发持久化的，当Redis异常中断或停电时，可能会导致最后一些写操作丢失。AOF(Append Only File，只追加文件)可以提供更好的持久性，结合apendfsync指令可以把几分钟的数据丢失降至一秒钟的数据丢失，它通过日志把所有的操作记录下来，AOF和RDB持久化可以同时启动。
appendfilename appendonly.aof    #指定aof的文件名。
apendfsync always|everysec|no    #调用fsync()写数据到硬盘中，always是每一次写操作就马上同步到日志中，everysec是每隔一秒强制fsync，no是不调用fsync()，让操作系统自己决定何时同步。
no-appendfsync-on-rewrite no    #如果为yes，当BGSAVE或BGREWRITEAOF指令运行时，即把AOF文件转写到RDB文件中时，会阻止调用fsync()。
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb    #Redis会将AOF文件最初的大小记录下来，如果当前的AOF文件的大小增加100%并且超过64mb时，就会自动触发Redis改写AOF文件到RDB文件中，如果auto-aof-rewrite-percentage为0表示取消自动rewrite功能。

#### LUA SCRIPTING ####
lua-time-limit 5000    #一个Lua脚本最长的执行时间为5000毫秒（5秒），如果为0或负数表示无限执行时间。


#### SLOW LOG ####
slowlog-log-slower-than 10000    #当某个请求执行时间（不包括IO时间）超过10000微妙（10毫秒），把请求记录在慢日志中 ，如果为负数不使用慢日志，如果为0强制记录每个指令。
slowlog-max-len 128    #慢日志的最大长度是128，当慢日志超过128时，最先进入队列的记录会被踢出来，慢日志会消耗内存，你可以使用SLOWLOG RESET清空队列回收这些内存。

#### ADVANCED CONFIG ####
hash-max-ziplist-entries 512
hash-max-ziplist-value 64    #较小的hash可以通过某种特殊的方式进行编码，以节省大量的内存空间，我们指定最大的条目数为512，每个条目的最大长度为64。
list-max-ziplist-entries 512
list-max-ziplist-value 64    #同上。
zset-max-ziplist-entries 128
zset-max-ziplist-value 64    #同上。
activerehashing yes    #重新哈希the main Redis hash table(the one mapping top-level keys to values)，这样会节省更多的空间。
client-output-buffer-limit normal 0 0 0    #对客户端输出缓冲进行限制可以强迫那些就不从服务器读取数据的客户端断开连接。对于normal client，第一个0表示取消hard limit，第二个0和第三个0表示取消soft limit，normal client默认取消限制，因为如果没有寻问，他们是不会接收数据的。
client-output-buffer-limit slave 256mb 64mb 60    #对于slave client和MONITER client，如果client-output-buffer一旦超过256mb，又或者超过64mb持续60秒，那么服务器就会立即断开客户端连接。
client-output-buffer-limit pubsub 32mb 8mb 60    #对于pubsub client，如果client-output-buffer一旦超过32mb，又或者超过8mb持续60秒，那么服务器就会立即断开客户端连接。

#### INCLUDES ####
include /path/to/conf    #包含一些可以重用的配置文件。


hz 10  #Redis 调用内部函数来执行后台task，比如关闭已经timeout连接，删除过期的keys并且永远不会被访问到的，执行频率根据 hz 后面的值来确定。在Redis 比较空闲的时候，提高这个值，能充分利用CPU，让Redis相应速度更快，可取范围是1-500 ，建议值为 1--100

aof-rewrite-incremental-fsync yes  # 当子进程重写AOF文件，以下选项开启时，AOF文件会每产生32M数据同步一次。这有助于更快写入文件到磁盘避免延迟

################ VIRTUAL MEMORY ###########

#是否开启VM功能，默认值为no

vm-enabled no

# vm-enabled yes

#虚拟内存文件路径，默认值为/tmp/redis.swap，不可多个Redis实例共享

vm-swap-file /tmp/redis.swap

#将所有大于vm-max-memory的数据存入虚拟内存,无论vm-max-memory设置多小,所有索引数据都是内存存储的 (Redis的索引数据就是keys),也就是说,当vm-max-memory设置为0的时候,其实是所有value都存在于磁盘。默认值为0。

vm-max-memory 0

vm-page-size 32

vm-pages 134217728

vm-max-threads 4

############# ADVANCED CONFIG ###############

glueoutputbuf yes

hash-max-zipmap-entries 64

hash-max-zipmap-value 512

#是否重置Hash表

activerehashing yes 
_____________________________________________________________________
注意：Redis官方文档对VM的使用提出了一些建议:

当你的key很小而value很大时,使用VM的效果会比较好.因为这样节约的内存比较大.
当你的key不小时,可以考虑使用一些非常方法将很大的key变成很大的value,比如你可以考虑将key,value组合成一个新的value.
最好使用linux ext3 等对稀疏文件支持比较好的文件系统保存你的swap文件.
vm-max-threads这个参数,可以设置访问swap文件的线程数,设置最好不要超过机器的核数.如果设置为0,那么所有对swap文件的操作都是串行的.可能会造成比较长时间的延迟,但是对数据完整性有很好的保证.


#启动服务
redis-server /etc/redis.conf

# redis-benchmark 命令测试性能

#操作窗口
redis-cli
redis-cli set foo bar
OK
redis-cli get foo
bar

#关闭redis
redis-cli shutdown 

#强制备份数据到磁盘，使用如下命令
redis-cli save 
redis-cli -p 6380 save  #指定端口

redis-cli -r 3 info    # 重复执行info命令三次
cat testStr.txt | redis-cli -x set testStr   # 读取testStr.txt文件所有内容设置为testStr的值
redis-cli keys \*   # 查看所有键值信息
redis-cli -n 1 keys "test*" | xargs redis-cli -n 1 del # 删除DBID为1的test开头的key值 
redis-cli -p 6379 info |  grep '\<used_memory\>'  # 过滤查询used_memory属性
redis-check-dump  dump.rdb    # 检查本地数据库文件
_____________________________________________________________________
	redis双机高可用的基础，是redis的主备复制机制。指定主备角色，是用slaveof命令。
	指定本机为master 
		 slaveof NO ONE 
	指定本机为192.168.1.10的slave 
		 slaveof 192.168.1.10 6379

	硬盘存储两种方式任选其一: 1、save 为快照	2、aof 为持久化  
	aof日志文件损坏，可用 Redis 随身带的 redis-check-aof 命令来修复原始文件：
	redis-check-aof --fix "filename"

_____________________________________________________________________
redis的基准信息和性能检测

	redis-benchmark -h localhost -p 6379 -c 100 -n 100000

	100个并发连接，100000个请求，检测host为localhost 端口为6379的redis服务器性能

	./redis-benchmark -n 100000 –c 50
		====== –c 50 ======
		100000 requests completed in 1.93 seconds (100000个请求完成于 1.93 秒 )
		50 parallel clients (每个请求有50个并发客户端)
		3 bytes payload (每次写入3字节)
		keep alive: 1 (保持1个连接)
		58.50% <= 0 milliseconds
		99.17% <= 1 milliseconds
		99.58% <= 2 milliseconds
		99.85% <= 3 milliseconds
		99.90% <= 6 milliseconds
		100.00% <= 9 milliseconds

	(所有请求在62毫秒内完成)
		114293.71 requests per second(每秒 114293.71 次查询)
		
		 例子：
		redis-benchmark -h 192.168.1.1 -p 6379 -n 100000 -c 20
		redis-benchmark -t set -n 1000000 -r 100000000
		redis-benchmark -t ping,set,get -n 100000 –csv
		redis-benchmark -r 10000 -n 10000 lpush mylist 

_____________________________________________________________________
Redis的query分析
	redis-faina(https://github.com/Instagram/redis-faina) 是由Instagram 开发并开源的一个Redis 查询分析小工具，需安装python环境。

	redis-faina 是通过Redis的MONITOR命令来实现的，通过对在Redis上执行的query进行监控，统计出一段时间的query特性，需root权限。

	通过管道从stdin读取N条命令，直接分析

	redis-cli -p 6439 monitor  | head -n <NUMBER OF LINES TO ANALYZE> | ./redis-faina.py 		

# python-redis官网
https://pypi.python.org/pypi/redis