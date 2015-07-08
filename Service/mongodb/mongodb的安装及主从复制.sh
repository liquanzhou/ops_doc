mongodb的安装及主从复制

一、mongodb安装
1.下载mongodblinux版本（注意32位和64位的区别）
wget http://downloads.mongodb.org/linux/mongodb-linux-x86_64-2.0.7.tgz
 
2.解压
tar xvf mongodb-linux-x86_64-2.0.7.tgz
mkdir /usr/local/mongodb
mv mongodb-linux-x86_64-2.0.7/* /usr/local/mongodb
 
3.创建数据库文件目录
如果有单独的分区，把mongodb数据库文件目录挂载到单独分区更好
mkdir -p /mongo/data
创建mongodb日志文件
mkdir /var/log/mongodb
touch /var/log/mongodb/mongodb.log
 
4.创建mongo命令的软连接
mongo bin目录下的脚本文件可以直接用了
ln -s /usr/local/mongodb/bin/* /usr/sbin
 
mongodb的bin下各工具的用途：
mongod：数据库服务端，类似mysqld，每个实例启动一个进程，可以fork为Daemon运行
mongo：客户端命令行工具，类似sqlplus/mysql，其实也是一个js解释器，支持js语法
mongodump/mongorestore：将数据导入为bson格式的文件/将bson文件恢复为数据库，类似xtracbackup
mongoexport/mongoimport：将collection导出为json/csv格式数据/将数据导入数据库，类似mysqldump/mysqlimport
bsondump：将bson格式的文件转储为json格式的数据
mongos：分片路由，如果使用了sharding功能，则应用程序连接的是mongos而不是mongod
mongofiles：GridFS管理工具
mongostat：实时监控工具
 
5启动mongodb （两种方法）
方法一：直接命令行启动
mongod –-port 27017 --fork --logpath=/var/log/mongodb/mongodb.log --logappend --dbpath=/mongo/db
 
方法二：（配置文件启动:推荐）
mkdir /usr/local/mongodb/conf
cd /usr/local/mongodb/conf
vim mongod.conf
  port=27017 #端口号
  fork=true #以守护进程的方式运行，创建服务器进程
  logpath=/var/log/mongodb/mongodb.log #日志输出文件路径
  logappend=true #日志输出方式
  dbpath=/mongo/db #数据库路径
  shardsvr=true #设置是否分片
  maxConns=600 #数据库的最大连接数
 
启动： mongod -f /usr/local/mongodb/conf/mongod.conf
 
6.验证
端口27017和28017是否打开
netstat -nultp
 
mongo命令进入mongo shell
 
二、mongodb主从复制配置
主从复制是mongodb最常用的复制方式,这种方式很灵活.可用于备份,故障恢复,读扩展等.
最基本的设置方式就是建立一个主节点和一个或多个从节点,每个从节点要知道主节点的地址.
这里我们用一主一从实现mongodb的复制
1.主机
mongodb-master  10.48.255.244   master
mongodb-slave   10.48.255.243   slave
 
2.把以上安装过程应用于mongodb这两个主机，配置文件稍加改动
在mongodb-master上，配置文件增加
master=true
oplogSize=2048 #类似于mysql的日志滚动，单位m
 
在mongodb-slave上，配置文件增加：
slave=true
source=10.48.100.1:27017   #指定主mongodb server
slavedelay=10               #延迟复制，单位为秒
autoresync=true             #当发现从服务器的数据不是最新时，向主服务器请求同步数据
 
三、测试主从可用性
在两主机上启动mongodb： mongod -f /usr/local/mongodb/conf/mongod.conf
1.看日志信息
主上日志：
# tail /var/log/mongodb/mongodb.log 
Thu Aug 16 17:59:44 [initandlisten] connection accepted from 10.48.255.243:38034 #1
Thu Aug 16 17:59:57 [conn1] end connection 10.48.255.243:38034
Thu Aug 16 18:00:08 [initandlisten] connection accepted from 10.48.255.243:38035 #2
Thu Aug 16 18:00:43 [clientcursormon] mem (MB) res:30 virt:8749 mapped:4302
 
从上日志
# tail /var/log/mongodb/mongodb.log 
Thu Aug 16 18:00:28 [replslave] repl: from host:10.48.255.244:27017
Thu Aug 16 18:00:28 [replslave] repl:   applied 1 operations
Thu Aug 16 18:00:28 [replslave] repl:   syncedTo: Aug 16 18:00:17 502d3531:1
Thu Aug 16 18:00:28 [replslave] waiting until: 1345140038 to continue
Thu Aug 16 18:00:28 [replslave] repl: sleep 10 sec before next pass
Thu Aug 16 18:00:38 [replslave] repl: from host:10.48.255.244:27017
Thu Aug 16 18:00:38 [replslave] repl:   applied 1 operations
Thu Aug 16 18:00:38 [replslave] repl:   syncedTo: Aug 16 18:00:27 502d353b:1
Thu Aug 16 18:00:38 [replslave] waiting until: 1345140048 to continue
Thu Aug 16 18:00:38 [replslave] repl: sleep 10 sec before next pass
 
由上述信息知道主从可以建立通信了
 
2.下面我们在主上创建数据库，并插入集合文档，看其是否同步
在主服务器上：
# mongo
MongoDB shell version: 2.0.7
connecting to: test
> show dbs
local	4.201171875GB
> use xin
switched to db xin
> db.test.save({title:"just test"})
> db.test.find()
{ "_id" : ObjectId("502d3643c5664ca66103a7cf"), "title" : "just test" }
> show dbs
local	4.201171875GB
xin	0.203125GB
> 
注：xin是数据库名，test是集合名，{title:"just test"}是文档
mongodb中使用use即可创建一个数据库当然也可以切换数据库，和mysql有很大区别吧
 
让我们来看看日志吧
主 server上的日志：
Thu Aug 16 18:04:51 [FileAllocator] creating directory /mongo/db/_tmp
Thu Aug 16 18:04:51 [FileAllocator] done allocating datafile /mongo/db/xin.ns, size: 16MB,  took 0.001 secs
Thu Aug 16 18:04:53 [FileAllocator] allocating new datafile /mongo/db/xin.0, filling with zeroes...
Thu Aug 16 18:04:53 [FileAllocator] done allocating datafile /mongo/db/xin.0, size: 64MB,  took 0.034 secs
Thu Aug 16 18:04:53 [FileAllocator] allocating new datafile /mongo/db/xin.1, filling with zeroes...
Thu Aug 16 18:04:53 [FileAllocator] done allocating datafile /mongo/db/xin.1, size: 128MB,  took 0.04 secs
Thu Aug 16 18:04:53 [conn3] build index xin.test { _id: 1 }
Thu Aug 16 18:04:53 [conn3] build index done 0 records 0.012 secs
Thu Aug 16 18:04:53 [conn3] insert xin.test 2892ms
Thu Aug 16 18:05:07 [initandlisten] connection accepted from 10.48.255.243:60173 #4
Thu Aug 16 18:05:08 [conn4] end connection 10.48.255.243:60173
 
从 server上的日志：
Thu Aug 16 18:05:04 [replslave] repl: from host:10.48.255.244:27017
Thu Aug 16 18:05:04 [replslave] resync: dropping database xin
Thu Aug 16 18:05:04 [replslave] removeJournalFiles
Thu Aug 16 18:05:04 [replslave] resync: cloning database xin to get an initial copy
Thu Aug 16 18:05:04 [FileAllocator] allocating new datafile /mongo/db/xin.ns, filling with zeroes...
Thu Aug 16 18:05:04 [FileAllocator] creating directory /mongo/db/_tmp
Thu Aug 16 18:05:04 [FileAllocator] done allocating datafile /mongo/db/xin.ns, size: 16MB,  took 0 secs
Thu Aug 16 18:05:04 [FileAllocator] allocating new datafile /mongo/db/xin.0, filling with zeroes...
Thu Aug 16 18:05:04 [FileAllocator] done allocating datafile /mongo/db/xin.0, size: 64MB,  took 0 secs
Thu Aug 16 18:05:04 [FileAllocator] allocating new datafile /mongo/db/xin.1, filling with zeroes...
Thu Aug 16 18:05:04 [FileAllocator] done allocating datafile /mongo/db/xin.1, size: 128MB,  took 0.001 secs
Thu Aug 16 18:05:04 [replslave] build index xin.test { _id: 1 }
Thu Aug 16 18:05:04 [replslave] build index done 1 records 0 secs
Thu Aug 16 18:05:04 [replslave] resync: done with initial clone for db: xin
Thu Aug 16 18:05:04 [replslave] repl:   applied 1 operations
 
由上述日志可以看出xin数据库已经同步到从 server上了
 
3.我们进入从 server 的mongodb shell,确认一下
# mongo
MongoDB shell version: 2.0.7
connecting to: test
> show dbs
local	0.203125GB
xin	0.203125GB
>
> use xin
switched to db xin
> db.test.find()
{ "_id" : ObjectId("502d3643c5664ca66103a7cf"), "title" : "just test" }
 
 
我们创建的数据库数据并不多，为什么会有0.2G呢，这是因为mongodb预分配数据库的空间，这使下次向数据库中插入数据更快了
 
4.在 从server 上查看Collection(集合)状态
> db.printCollectionStats()
system.indexes
{
"ns" : "xin.system.indexes",
"count" : 1,
"size" : 64,
"avgObjSize" : 64,
"storageSize" : 4096,
"numExtents" : 1,
"nindexes" : 0,
"lastExtentSize" : 4096,
"paddingFactor" : 1,
"flags" : 0,
"totalIndexSize" : 0,
"indexSizes" : {
},
"ok" : 1
}
---
test
{
"ns" : "xin.test",
"count" : 1,
"size" : 44,
"avgObjSize" : 44,
"storageSize" : 8192,
"numExtents" : 1,
"nindexes" : 1,
"lastExtentSize" : 8192,
"paddingFactor" : 1,
"flags" : 1,
"totalIndexSize" : 8176,
"indexSizes" : {
"_id_" : 8176
},
"ok" : 1
}
---
 
在 从server 上查看主从复制的状态
> db.printReplicationInfo()
this is a slave, printing slave replication info.
source:   10.48.255.244:27017
syncedTo: Thu Aug 16 2012 18:33:27 GMT+0000 (UTC)
= 18 secs ago (0.01hrs)
> 
> db.printSlaveReplicationInfo()
source:   10.48.255.244:27017
syncedTo: Thu Aug 16 2012 18:34:37 GMT+0000 (UTC)
= 20 secs ago (0.01hrs)
 
 
ok,mongodb的主从复制搞定了!