mongodb复制集

复制集：有自动故障恢复功能的主从集群。没有固定的主节点，通过集群选举一个主节点。当主节点工作不正常时，会选举出另一个节点为主节点。
#实际生产中程序应使用mongos

安装{

#一个mongodb可启动多个实例,测试无需安装多个mongo

mkdir -p /opt/mongodb/data{1..4}/

#启动

/opt/mongodb/bin/mongod --port 10001 --fork --logpath=/opt/mongodb/mongodb1.log --logappend --dbpath=/opt/mongodb/data1/  --replSet replcopy/10.152.14.85:10002,10.152.14.85:10003

/opt/mongodb/bin/mongod --port 10002 --fork --logpath=/opt/mongodb/mongodb2.log --logappend --dbpath=/opt/mongodb/data2/  --replSet replcopy/10.152.14.85:10001,10.152.14.85:10003

/opt/mongodb/bin/mongod --port 10003 --fork --logpath=/opt/mongodb/mongodb3.log --logappend --dbpath=/opt/mongodb/data3/  --replSet replcopy/10.152.14.85:10001,10.152.14.85:10002

#登录主节点admin库
./mongo 10.152.14.85:10001/admin

#初始化
db.runCommand({"replSetInitiate":{"_id":"replcopy","members":[{"_id":1,"host":"10.152.14.85:10001"},{"_id":2,"host":"10.152.14.85:10002"},{"_id":3,"host":"10.152.14.85:10003"}]}})
#查看状态
db._adminCommand("replSetGetStatus");

#查看主从复制关系
rs.isMaster()
"ismaster" : false,                 # 当前是否为主
"primary" : "10.152.14.85:10004",   # 主库IP

replcopy:PRIMARY>   # 有PRIMARY即为主节点

#查看复制集状态
rs.status()
rs.conf()
#查看从库状态
db.printSlaveReplicationInfo()
#默认从库不可查询，执行如下语句使得当前从库可以查询，分担主库查询负载
db.getMongo().setSlaveOk()
rs.setSlaveOk()

}

新增节点{

#启动新加节点
/opt/mongodb/bin/mongod --port 10004 --fork --logpath=/opt/mongodb/mongodb4.log --logappend --dbpath=/opt/mongodb/data4/  --replSet replcopy/10.152.14.85:10001,10.152.14.85:10002,10.152.14.85:10003

#登录主节点增加节点
./mongo 10.152.14.85:10001/admin
rs.add("10.152.14.85:10004");

}

节点接管测试{

#把主节点kill掉，集群中查看节点1状态health为0既节点失败
db._adminCommand("replSetGetStatus");
"health" : 0,    # 节点1显示
#查看主节点ip,id为4的节点接管了主节点
rs.isMaster()
"ismaster" : false,
"primary" : "10.152.14.85:10004",

}

删除节点{

#登录主节点4
./mongo 10.152.14.85:10004/admin
#删除节点1
rs.remove("10.152.14.85:10001");

}




