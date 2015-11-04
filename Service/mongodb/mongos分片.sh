
mongos 集群安装部署文档


官方文档 Sharding Introduction： 
http://www.mongodb.org/display/DOCS/Sharding+Introduction
      
分担读写负载
三台服务器，如果将所有数据分为三片，每一台作为其中一片数据的写入点，其他两个节点进行拷贝，使读写压力在'一定条件'下分布在三台机器。
      
自动故障转移
在单点损坏条件下，可以立刻将主服务器转换到随机另外一台从属服务器的分片上。不过之前未处理的请求将会被全部抛弃。
      
灵活配置分片 
不设置表分片，表就不会进行分片，会完整保存在该库所在的主Shard中。可以在配置某数据库信息启用分片之后，单独设定某个表的信息在其他分片中分散存储。并设定尽量有规律的分片条件。

      
动态添加删除
可以在压力接近瓶颈的时候动态的进行分片添加，并设置该服务器为某分片写入点，分散IO压力，也可以在服务器出现异常时，进行分片数据的迁移和分片卸载。在数据库集群运作中时，添加分片，数据自动流入此分片。
在数据库集群运作中时，删除分片，系统立即设置此分片状态 "draining" : true ，之后慢慢将此分片数据转移到其他分片。
      
实时查看状态
可以在数据库信息设置和信息的CRUD操作时，实时进行数据库状态、数据分片信息、数据状态的监控。

 

 

mongos 集群安装部署文档

 

 

启动分片数据库
————————————————————
分别在3台机器，启动3个分片。
./mongod --shardsvr --replSet shard1 --port 30001 --dbpath /home/data/mongodata/shard01 --oplogSize 100 --logpath /home/data/mongodata/mongoshard1.log --rest --fork
./mongod --shardsvr --replSet shard2 --port 30002 --dbpath /home/data/mongodata/shard02 --oplogSize 100 --logpath /home/data/mongodata/mongoshard2.log --rest --fork
./mongod --shardsvr --replSet shard3 --port 30003 --dbpath /home/data/mongodata/shard03 --oplogSize 100 --logpath /home/data/mongodata/mongoshard3.log --rest --fork

 

 

配置副本集并加载
————————————————————
任意服务器连入30001
config = {_id: 'shard1', members: [
 {_id: 0, host: '192.168.1.123:30001'},
 {_id: 1, host: '192.168.1.124:30001'},
 {_id: 2, host: '192.168.1.125:30001'}]
}
rs.initiate(config);

任意服务器连入30002
config = {_id: 'shard2', members: [
 {_id: 0, host: '192.168.1.123:30002'},
 {_id: 1, host: '192.168.1.124:30002'},
 {_id: 2, host: '192.168.1.125:30002'}]
}
rs.initiate(config);

任意服务器连入30003
config = {_id: 'shard3', members: [
 {_id: 0, host: '192.168.1.123:30003'},
 {_id: 1, host: '192.168.1.124:30003'},
 {_id: 2, host: '192.168.1.125:30003'}]
}
rs.initiate(config);

查看状态
rs.status()

启动配置服务器
————————————————————
分别在三台机器，都启动3个配置服务。
./mongod --configsvr --port 20000 --dbpath /home/data/mongodata/config --logpath /home/data/mongodata/configconfig.log --logappend --pidfilepath /home/data/mongodata/config/config.pid --rest --fork

启动路由
————————————————————
在其中一台或者多台机器，启动mongos路由，作为集群访问点。
./mongos --configdb 192.168.1.123:20000,192.168.1.124:20000,192.168.1.125:20000 --port 30000 --chunkSize 100 --logpath /data/mongodata/mongos.log --logappend --pidfilepath /data/mongodata/mongos.pid --fork

添加分片
————————————————————
3个分片已经设置好，在mongos控制台的admin数据库下，执行下面的代码，添加分片。
db.runCommand({addshard:"shard1/192.168.1.123:30001,192.168.1.124:30001,192.168.1.125:30001",name:"s1",maxsize:20480});
db.runCommand({addshard:"shard2/192.168.1.123:30002,192.168.1.124:30002,192.168.1.125:30002",name:"s2",maxsize:20480});
db.runCommand({addshard:"shard3/192.168.1.123:30003,192.168.1.124:30003,192.168.1.125:30003",name:"s3",maxsize:20480});

查看列表，如果是3个分片。就OK了。
db.runCommand({listshards:1})

以上mongos部署成功。

 

 

其他命令
————————————————————

允许数据库中的内容被分片
db.runCommand({enablesharding:"test"})

设定表分片与分片规则，作为分片规则的key，必须为该表索引。
db.runCommand({shardcollection:"teset.user",key:{id:1, email:1, regtime:1}})

查看数据库状态
db.stats()

查看表状态
db.tableName.stats()
 
查看所有分片信息状态
db.printShardingStatus();

删除分片，删除分片命令执行后，mongos将不再写入该分片数据，同时会将数据迁移到其他分片，这个过程需要一段时间，此时查看db.printShardingStatus();，该分片状态为"draining" : true。
但是由于bug，会一直处于此状态下。需要在人工确定已无数据在此分片后，在mongos中进入config数据库执行db.shards.remove({draining:true})，删除掉该分片。
db.runCommand({removeshard : "shard1/192.168.1.123:30001,192.168.1.124:30001,192.168.1.125:30001"});

使Primary降为Secondary，每一个分片，都是一组副本集，1主2从，设置时自动选举，如果不符合写入压力分散的需求，可以将该主库降级，2个从属会随机选择一个重新为主。
rs.stepDown()

手动移动碎片
http://www.mongodb.org/display/DOCS/Moving+Chunks
