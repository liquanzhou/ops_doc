
MongoDB用户认证  

       MongoDB 安装后默认不启用认证，也就是说在本地可以通过 mongo 命令不输入用户名密码，
直接登陆到数据库，下面介绍下启用 mongodb 用户认证，详细如下：

      启用 mongodb 认证只需要在启动 mongod 服务时配置 auth 参数成 'true'即可可 ，在配置
参数前先添加超级用户。


一 启用认证
--1.1 增加管理用户

 > use admin;
switched to db admin

> db.addUser('root','123456');
{
        "user" : "root",
        "readOnly" : false,
        "pwd" : "34e5772aa66b703a319641d42a47d696",
        "_id" : ObjectId("50ad456a0b12589bdc45cf92")
}

> db.system.users.find();
{ "_id" : ObjectId("50ad6ecda579c47efacf811b"), "user" : "root", "readOnly" : false, "pwd" : "34e5772aa66b703a319641d42a47d696" }

   备注：在 admin 库中增加的用户为超级用户，权限最大，可以访问所有库。


--1.2 增加普通用户

 > use skytf;
switched to db skytf

> db.addUser('skytf','skytf');
{
        "user" : "skytf",
        "readOnly" : false,
        "pwd" : "8c438fc9e2031577cea03806db0ee137",
        "_id" : ObjectId("50ad45dd0b12589bdc45cf93")
}

> db.system.users.find();
{ "_id" : ObjectId("50ad6ef3a579c47efacf811c"), "user" : "skytf", "readOnly" : false, "pwd" : "8c438fc9e2031577cea03806db0ee137" }
   

--1.3 配置 auth 参数
vim /database/mongodb/data/mongodb_27017.conf，增加 " auth = true " 参数

 fork = true
bind_ip = 127.0.0.1
port = 27017
quiet = true
dbpath = /database/mongodb/data/
logpath = /var/applog/mongo_log/mongo.log
logappend = true
journal = true
auth = true

    备注：增加 “auth = true” 配置。


--1.4 重启 mongodb

 [mongo@redhatB data]$ ps -ef | grep mongo
root     10887 10859  0 04:47 pts/0    00:00:00 su - mongo
mongo    10889 10887  0 04:47 pts/0    00:00:00 -bash
root     10984 10964  0 04:53 pts/1    00:00:00 su - mongo
mongo    10986 10984  0 04:53 pts/1    00:00:00 -bash
mongo    12749     1  0 07:54 ?        00:00:01 mongod -f /database/mongodb/data/mongodb_27017.conf
mongo    13035 10986 13 08:21 pts/1    00:00:00 ps -ef
mongo    13036 10986  0 08:21 pts/1    00:00:00 grep mongo

[mongo@redhatB data]$ kill 12749

[mongo@redhatB data]$ mongod -f /database/mongodb/data/mongodb_27017.conf
forked process: 13042
all output going to: /var/applog/mongo_log/mongo.log

   


--1.5 测试 skytf 帐号

 [mongo@redhatB data]$ mongo 127.0.0.1/skytf -u skytf -p
MongoDB shell version: 2.2.1
Enter password:
connecting to: 127.0.0.1/skytf
Error: { errmsg: "auth fails", ok: 0.0 }
Thu Nov 22 08:23:11 uncaught exception: login failed
exception: login failed

[mongo@redhatB data]$ mongo 127.0.0.1/skytf -u skytf -p
MongoDB shell version: 2.2.1
Enter password:
connecting to: 127.0.0.1/skytf

> show collections;
system.indexes
system.users
test_1
test_2
test_3
test_4
things
things_1

> db.test_5.find();
{ "_id" : ObjectId("50ad7177d114dcf18a8bb220"), "id" : 1 }

> show dbs;
Thu Nov 22 08:24:03 uncaught exception: listDatabases failed:{ "errmsg" : "need to login", "ok" : 0 }

> use test;
switched to db test

> show collections;
Thu Nov 22 09:01:32 uncaught exception: error: {
        "$err" : "unauthorized db:test ns:test.system.namespaces lock type:0 client:127.0.0.1",
        "code" : 10057
   
    备注：从上看出， skytf 用户的认证已生效，并且能查看数据库 skytf 里的集合，但不能执行 “show dbs”
              命令；并且能连接数据库 test ，但没有权限执行“show collections” 命令。

 

二 切换用户
--2.1 在普通库中切换成 root 用户

 > use test;
switched to db test

> db.auth('root','123456');db.auth('root','123456');
Error: { errmsg: "auth fails", ok: 0.0 }
0

      备注：在普通库中切换成超级用户失败，超级用户需要在 admin 库中切换才能生效。
   

--2.2 在 admin 库中切换成 root 用户

 > use admin;
switched to db admin


> db.auth('root','123456');
1

      备注：在 admin 库中切换成超级用户成功。
  


三 新增只读帐号
--3.1 增加只读帐号

 > db.addUser('skytf_select','skytf_select',true);
{
        "user" : "skytf_select",
        "readOnly" : true,
        "pwd" : "e344f93a69f20ca9f3dfbc40da4a3082",
        "_id" : ObjectId("50ad71c7d114dcf18a8bb221")
}

> db.system.users.find();db.system.users.find();
{ "_id" : ObjectId("50ad6ef3a579c47efacf811c"), "user" : "skytf", "readOnly" : false, "pwd" : "8c438fc9e2031577cea03806db0ee137" }
{ "_id" : ObjectId("50ad71c7d114dcf18a8bb221"), "user" : "skytf_select", "readOnly" : true, "pwd" : "e344f93a69f20ca9f3dfbc40da4a3082" }

    备注：只需在 addUser 命令中增加第三个参数，并指定为“true” ，即可创建只读帐号。   


--3.2 测试

 [mongo@redhatB data]$ mongo 127.0.0.1/skytf -u skytf_select -p
MongoDB shell version: 2.2.1
Enter password:
connecting to: 127.0.0.1/skytf

> show collections;
system.indexes
system.users
test_1
test_2
test_3
test_4
test_5
things
things_1

> db.test_5.find();
{ "_id" : ObjectId("50ad7177d114dcf18a8bb220"), "id" : 1 }
{ "_id" : ObjectId("50ad724ed114dcf18a8bb222"), "id" : 2 }

> db.test_5.save({id:3});
unauthorized
   

    备注：以只读帐号 skytf_select 登陆库 skytf，有权限执行查询操作，没有权限执行插入操作；

 

四 附 命令参考
--4.1 db.addUser

Parameters: 	


username (string) – Specifies a new username.
password (string) – Specifies the corresponding password.
readOnly (boolean) – Optional. Restrict a user to read-privileges only. Defaults to false.

Use this function to create new database users, by specifying a username and password as arguments
to the command. If you want to restrict the user to have only read-only privileges, supply a true third
argument; however, this defaults to false。

 

--4.2 db.auth
    Parameters: 	


    username (string) – Specifies an existing username with access privileges for this database.
    password (string) – Specifies the corresponding password.

 Allows a user to authenticate to the database from within the shell. Alternatively use mongo
 --username and --password to specify authentication credentials.


五 参考
http://docs.mongodb.org/manual/tutorial/control-access-to-mongodb-with-authentication/
http://docs.mongodb.org/manual/administration/security/
http://blog.163.com/dazuiba_008/blog/static/36334981201110311534143/