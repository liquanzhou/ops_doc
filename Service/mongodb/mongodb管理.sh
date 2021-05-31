mongodb管理

说明{

	手册制作: 雪松
	更新日期: 2013-11-22
	欢迎系统运维加入Q群: 198173206   #请回答问题

	请使用"notepad++"打开此文档,"alt+0"将函数折叠后方便查阅
	请勿删除信息，转载请说明出处，抵制不道德行为。
	错误在所难免，还望指正！

	# shell实例手册最新下载地址:
	http://hi.baidu.com/quanzhou722/item/f4a4f3c9eb37f02d46d5c0d9

	# LazyManage系统批量管理软件下载(shell):
	http://hi.baidu.com/quanzhou722/item/4ccf7e88a877eaccef083d1a
	
	# python实例手册下载地址:
	http://hi.baidu.com/quanzhou722/item/cf4471f8e23d3149932af2a7

}

一、启动{

./mongod --port 27017 --fork --logpath=/opt/mongodb/mongodb.log --logappend --dbpath=/opt/mongodb/data/

#启动认证
./mongod --port 27017 --fork --logpath=/opt/mongodb/mongodb.log --logappend --dbpath=/opt/mongodb/data/ --auth


#配置文件方式启动
cat /opt/mongodb/mongodb.conf
  port=27017                       #端口号
  fork=true                        #以守护进程的方式运行，创建服务器进程
  auth=true                        #开启用户认证
  logappend=true                   #日志采用追加方式
  logpath=/opt/mongodb/mongodb.log #日志输出文件路径
  dbpath=/opt/mongodb/data/        #数据库路径
  shardsvr=true                    #设置是否分片
  maxConns=600                     #数据库的最大连接数
  
./mongod -f /opt/mongodb/mongodb.conf
  
bind_ip         #绑定IP  使用mongo登录需要指定对应IP
journal         #开启日志功能,降低单机故障的恢复时间,取代dur参数
syncdelay       #系统同步刷新磁盘的时间,默认60秒
directoryperdb  #每个db单独存放目录,建议设置.与mysql独立表空间类似
repairpath      #执行repair时的临时目录.如果没开启journal,出现异常重启,必须执行repair操作


#mongodb没有参数设置内存大小.使用os mmap机制缓存数据文件,在数据量不超过内存的情况下,效率非常高.数据量超过系统可用内存会影响写入性能

}
  
二、关闭{

#方法一:登录mongodb
./mongo
use admin
db.shutdownServer()

#方法:kill传递信号  两种皆可
kill -2 pid
kill -15 pid

}
  
三、开启认证与用户管理{

#先登录 切换到admin库
./mongo
use admin

#创建用户
db.addUser("root","123456")

#如果用户的readOnly为true那么这个用户只能读取数据，添加一个readOnly用户zhansan
db.addUser('zhansan','pass',true)

#再次登录,只能针对用户所在库登录
./mongo 127.0.0.1:27017/mydb -uroot -p123456
#虽然是超级管理员，但是admin不能直接登录其他数据库，否则报错
#Fri Nov 22 15:03:21.886 Error: 18 { code: 18, ok: 0.0, errmsg: "auth fails" } at src/mongo/shell/db.js:228

#删除用户
db.system.users.remove({user:"zhansan"})

#查看创建用户信息
db.system.users.find();

#查看链接状态 再次登录使用如下命令,显示错误未经授权
show collections

#恢复密码只需要重启mongodb 不加--auth参数

}

四、登录{

#默认登录后打开 test 库
./mongo

# 直接连接某个库 不存在则创建  启动认证需要指定对应库才可登录
./mongo 192.168.1.5:27017/databaseName

http登录
192.168.1.5:28017

}

五、查看状态{

db.runCommand({"serverStatus":1})
globalLock         #表示全局写入锁占用了服务器多少时间(微秒)
mem                #包含服务器内存映射了多少数据,服务器进程的虚拟内存和常驻内存的占用情况(MB)
indexCounters      #表示B树在磁盘检索(misses)和内存检索(hits)的次数.如果这两个比值开始上升,就要考虑添加内存了
backgroudFlushing  #表示后台做了多少次fsync以及用了多少时间
opcounters         #包含每种主要擦撞的次数
asserts            #统计了断言的次数

#状态信息从服务器启动开始计算,如果过大就会复位,发送复位，所有计数都会复位,asserts中的roolovers值增加

#mongodb自带的命令
./mongostat
insert     #每秒插入量
query      #每秒查询量
update     #每秒更新量
delete     #每秒删除量
locked     #锁定量
qr|qw      #客户端查询排队长度(读|写)
ar|aw      #活跃客户端量(读|写)
conn       #连接数
time       #当前时间

}

六、常用命令{

db.listCommands()     #当前MongoDB支持的所有命令（同样可通过运行命令db.runCommand({"listCommands" : `1})来查询所有命令）

db.runCommand({"buildInfo" : 1})                #返回MongoDB服务器的版本号和服务器OS的相关信息。
db.runCommand({"collStats" : 集合名})           #返回该集合的统计信息，包括数据大小，已分配存储空间大小，索引的大小等。
db.runCommand({"distinct" : 集合名, "key" : 键, "query" : 查询文档})     #返回特定文档所有符合查询文档指定条件的文档的指定键的所有不同的值。
db.runCommand({"dropDatabase" : 1})             #清空当前数据库的信息，包括删除所有的集合和索引。
db.runCommand({"isMaster" : 1})                 #检查本服务器是主服务器还是从服务器。
db.runCommand({"ping" : 1})                     #检查服务器链接是否正常。即便服务器上锁，该命令也会立即返回。
db.runCommand({"repaireDatabase" : 1})          #对当前数据库进行修复并压缩，如果数据库特别大，这个命令会非常耗时。
db.runCommand({"serverStatus" : 1})             #查看这台服务器的管理统计信息。

某些命令必须在admin数据库下运行，如下两个命令：
db.runCommand({"renameCollection" : 集合名, "to"：集合名})     #对集合重命名，注意两个集合名都要是完整的集合命名空间，如foo.bar, 表示数据库foo下的集合bar。
db.runCommand({"listDatabases" : 1})                           #列出服务器上所有的数据库！

}

七、进程控制{

#查看活动进程
db.currentOp()
db.$cmd.sys.inprog.findOne()

opid   # 操作进程号
op     # 操作类型(查询\更新)
ns     # 命名空间,指操作的是哪个对象
query  # 如果操作类型是查询,这里将显示具体的查询内容
lockType  # 锁的类型,指明是读锁还是写锁

#结束进程
db.killOp(opid值)
db.$cmd.sys.killop.findOne({op:opid值})

}

八、备份还原{

mongoexport备份

#导出JSON格式
./mongoexport -d test -c t1 -o t1.dat
-c #指明导出集合
-d #使用库

#导出csv格式
./mongoexport -d test -c t1 -csv -f num -o t1.dat
-csv  #指明导出csv格式
-f    #指明需要导出那些例

#登录后删除数据
db.t1.drop()

mongoimport还原
./mongoimport -d test -c t1 -file t1.dat

mongoimport还原csv格式数据
./mongoimport -d test -c t1 -type csv --headerline -file t1.dat
--headerline  #指明不导入第一行 因为第一行是列名


mongodump数据备份
./mongodump -d test -o /bak/mongodump

mongorestore恢复
./mongorestore -d test --drop /bak/mongodump/* 
--drop  #恢复前先删除

#查看
db.t1.find()


# mongodump 虽然能不停机备份,但市区了获取实时数据视图的能力,使用fsync命令能在运行时复制数据目录并且不会损坏数据
# fsync会强制服务器将所有缓冲区的数据写入磁盘.配合lock还阻止对数据库的进一步写入,知道释放锁为止
# 备份在从库上备份，不耽误读写还能保证实时快照备份

#执行强制更新与写入锁
db.runCommand({"fsync":1,"lock":1})
#解锁
db.$cmd.sys.unlock.findOne()
#查看解锁是否正常
db.currentOp()



}

九、修复{

#当停电或其他故障引起不正常关闭时,会造成部分数据损坏丢失

修复操作:启动时候加上 --repair
./mongod --repair

#修复过程:将所有文档导出,然后马上导入,忽略无效文档.完成后重建索引。时间较长,会丢弃损坏文档
#修复数据还能起到压缩数据库的作用

#运行中的mongodb可使用 repairDatabase 修复当前使用的               数据库
db.repairDatabase()

#通过驱动程序
{"repairDatabase":1}

}

十、python使用mongodb{

	原文: http://blog.nosqlfan.com/html/2989.html
	
	easy_install pymongo      # 安装(python2.7+)
	import pymongo
	connection=pymongo.Connection('localhost',27017)   # 创建连接
	db = connection.test_database                      # 切换数据库
	collection = db.test_collection                    # 获取collection
	# db和collection都是延时创建的，在添加Document时才真正创建

	文档添加, _id自动创建
		import datetime
		post = {"author": "Mike",
			"text": "My first blog post!",
			"tags": ["mongodb", "python", "pymongo"],
			"date": datetime.datetime.utcnow()}
		posts = db.posts
		posts.insert(post)
		ObjectId('...')

	批量插入
		new_posts = [{"author": "Mike",
			"text": "Another post!",
			"tags": ["bulk", "insert"],
			"date": datetime.datetime(2009, 11, 12, 11, 14)},
			{"author": "Eliot",
			"title": "MongoDB is fun",
			"text": "and pretty easy too!",
			"date": datetime.datetime(2009, 11, 10, 10, 45)}]
		posts.insert(new_posts)
		[ObjectId('...'), ObjectId('...')]
	
	获取所有collection
		db.collection_names()    # 相当于SQL的show tables
		
	获取单个文档
		posts.find_one()

	查询多个文档
		for post in posts.find():
			post

	加条件的查询
		posts.find_one({"author": "Mike"})

	高级查询
		posts.find({"date": {"$lt": "d"}}).sort("author")

	统计数量
		posts.count()

	加索引
		from pymongo import ASCENDING, DESCENDING
		posts.create_index([("date", DESCENDING), ("author", ASCENDING)])

	查看查询语句的性能
		posts.find({"date": {"$lt": "d"}}).sort("author").explain()["cursor"]
		posts.find({"date": {"$lt": "d"}}).sort("author").explain()["nscanned"]

}


请勿删除信息，植入广告，抵制不道德行为。