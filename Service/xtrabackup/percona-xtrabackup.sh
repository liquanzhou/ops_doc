一、安装percona-xtrabackup软件

该软件分为32位和64位系统安装包，安装包位置如下：
32位 ： \\192.168.0.9\software\jcui临时备份文件夹\packets\percona-xtrabackup\percona-xtrabackup-i686-2.0.3-470.tar.gz
64位 ： \\192.168.0.9\software\jcui临时备份文件夹\packets\percona-xtrabackup\percona-xtrabackup-x64-2.0.3-470.tar.gz

以下以讲解32位安装包为例：
1.解包
tar xzvfp percona-xtrabackup-i686-2.0.3-470.tar.gz
mv percona-xtrabackup-i686-2.0.3 /usr/local/percona

做如下软链接
ln -s -f /usr/local/percona/bin/innobackupex  /usr/bin/
ln -s -f /usr/local/percona/bin/xbstream  /usr/bin/
ln -s -f /usr/local/percona/bin/xtrabackup  /usr/bin/
ln -s -f /usr/local/percona/bin/xtrabackup_51  /usr/bin/
ln -s -f /usr/local/percona/bin/xtrabackup_55  /usr/bin/

二、使用innobackupex命令执行备份
1.首先需要保证写入my.cnf配置文件，如下分别为Myisam引擎和Innodb引擎的配置文件，要注意的是my.cnf里datadir这个参数是必须要指定的，xtrabackup_55是根据它去定位innodb数据文件的位置。
#aa.cnf-----Myisam-------------------------------------------
[mysqld]
datadir=/data/mysql5/data
#aa.cnf-----Innodb-------------------------------------------
[mysqld]
datadir=/data/mysql5/data
innodb_log_file_size=128M
#------------------------------------------------------------
#innodb引擎的共享表空间数据文件根目录
innodb_data_file_path=ibdata1:10M:autoextend
#参数的名字和实际的用途有点出入，它不仅指定了所有InnoDB数据文件的路径，还指定了初始大小分配，最大分配以及超出起始分配界线时是否应当增加文件的大小。此参数的一般格式如下: path-to-datafile:size-allocation[:autoextend[:max-size-allocation]] 
innodb_log_group_home_dir=/data1/mysql5/data    
#此参数确定日志文件组中的文件的位置，日志组中文件的个数由innodb_log_files_in_group确定，此位置设置默认为MySQL的datadir 
innodb_log_files_in_group=2          
#为提高性能，MySQL可以以循环方式将日志文件写到多个文件。推荐设置为3M 
innodb_log_file_size=128M     
#此参数确定数据日志文件的大小，以M为单位，更大的设置可以提高性能，但也会增加恢复故障数据库所需的时间

2.假设如上的配置文件放在/data1/mysql5/data/my_3306.cnf  备份目录为:/data2/dbbackup   备份生产的日志目录为：/data2/dbbackup/dbbackup.log  执行如下命令操作：

innobackupex --user=root --password="" --defaults-file=/data/mysql5/data/my_3306.cnf --socket=/data/mysql5/data/mysql.sock --slave-info --stream=tar --tmpdir=/data/dbbackup/temp /data/dbbackup/ 2>/data/dbbackup/dbbackup.log | gzip 1>/data/dbbackup/db50.tar.gz


三、恢复数据库操作
#
0.将db20.tar.gz解包，使用tar ixzvfp db20.tar.gz  -C /data2/dbbackup/temp
#注意这里一定要加-i的参数
1.innobackupex --apply-log /data2/dbbackup/temp
#这步是恢复日志解析成数据库的格式
2.将需要恢复的库文件及ib*三个文件拷贝至需要回复数据库中
#主要一定要包含三个ib*开头的文件  
3.chown -R mysql.mysql *
#将权限重新赋值mysql.mysql  
#-----------------------------------至此恢复数据库已经可以了，启动数据库即可读取了，下面是重建主从时需要继续执行的步骤
4.cat xtrabackup_binlog_info
#查看xtrabackup_binlog_info记录的主库节点位置信息
5.使用从库启动脚本启动从库     
#+参数 start positon  num
6.rm -rf /data2/dbbackup/temp
#删除其他没有的文件

#-----------------------------------至此，主从数据库恢复完毕
参考网页：
0.http://www.jb51.net/article/27069.htm
1.http://www.jb51.net/article/28718.htm
2.http://willvvv.iteye.com/blog/1544043
3.http://www.cnblogs.com/cosiray/archive/2012/03/02/2376595.html


相关参数如下：------------------------------------------------------
--user
#数据库用户名
--password
#数据库密码
--defaults-file=
#读取my.cnf的配置路径
--socket
#指定mysql.sock所在位置，以便备份进程登录mysql. 
--slave-info
#加上--slave-info备份目录下会多生成一个xtrabackup_slave_info 文件, 这里会保存主日志文件以及偏移, 文件内容类似于:CHANGE MASTER TO MASTER_LOG_FILE='', MASTER_LOG_POS=0
--stream=tar
#备份文件输出格式, tar时使用tar4ibd , 该文件可在XtarBackup binary文件中获得.如果备份时有指定--stream=tar, 则tar4ibd文件所处目录一定要在$PATH中(因为使用的是tar4ibd去压缩, 在XtraBackup的binary包中可获得该文件)。 在使用参数stream=tar备份的时候，你的xtrabackup_logfile可能会临时放在/tmp目录下，如果你备份的时候并发写入较大的话xtrabackup_logfile可能会很大(5G+)，很可能会撑满你的/tmp目录，可以通过参数--tmpdir指定目录来解决这个问题。
| gzip 1>/data2/dbbackup/db50.tar.gz
#将备份出来的数据使用gzip的方式打包成*.tar.gz
--apply-log 
#对xtrabackup的--prepare参数的封装 

其他参数如下：------------------------------------------------------
--databases="sanguo_01"
#只对sanguo_01做备份，如果没有指定该参数，所有包含MyISAM和InnoDB表的database都会被备份； 
--copy-back 
#做数据恢复时将备份数据文件拷贝到MySQL服务器的datadir ； 
--remote-host=HOSTNAME 
#通过ssh将备份数据存储到进程服务器上； 
--tmpdir=DIRECTORY 
#当有指定--remote-host or --stream时, 事务日志临时存储的目录, 默认采用MySQL配置文件中所指定的临时目录tmpdir 
--redo-only --apply-log组, 
#强制备份日志时只redo ,跳过rollback。这在做增量备份时非常必要。 
--use-memory=# 
#该参数在prepare的时候使用，控制prepare时innodb实例使用的内存量 
--throttle=IOS 
#同xtrabackup的--throttle参数 
--sleep=
#是给ibbackup使用的，指定每备份1M数据，过程停止拷贝多少毫秒，也是为了在备份时尽量减小对正常业务的影响，具体可以查看ibbackup的手册 ； 
--compress[=LEVEL] 
#对备份数据迚行压缩，仅支持ibbackup，xtrabackup还没有实现； 
--include=REGEXP 
#对xtrabackup参数--tables的封装，也支持ibbackup。备份包含的库表，例如：--include="test.*"，意思是要备份test库中所有的表。如果需要全备份，则省略这个参数；如果需要备份test库下的2个表：test1和test2,则写成：--include="test.test1|test.test2"。也可以使用通配符，如：--include="test.test*"。 
--uncompress 
#解压备份的数据文件，支持ibbackup，xtrabackup还没有实现该功能； 



全备命令为：
innobackupex --defaults-file=/mysql/data1/my.cnf   --incremental-basedir=/web/mysql/  --user=root --password='123456'

增量备份的命令为：
innobackupex --defaults-file=/mysql/data1/my.cnf  --incremental  /web/mysql/ --incremental-basedir=/web/mysql/2014-01-06_23-21-41/  --user=root --password='123456'   
其中文件夹2014-01-06_23-21-41/为全备后生成的文件夹