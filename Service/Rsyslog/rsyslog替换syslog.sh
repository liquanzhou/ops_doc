
rsyslog替换syslog


rsyslog是比syslog功能更强大的日志记录系统，可以将日志输出到文件，数据库和其它程序。可以使用rsyslog替换syslog。

目录 [显示]
1. 安装 MySQL

./configure --prefix=/usr/local/mysql  --with-charset=utf8
make && make install

2. 配置 MySQL

增加一个只写的账号和一个只读的账号，只写的账号是给rsyslog往mysql里面写日志，只读的账号是前端web页面用的
# 注意别搞错大小写

GRANT INSERT ON Syslog.* TO 'rsyslog_write'@'localhost' IDENTIFIED BY 'password_123456';
GRANT SELECT ON Syslog.* TO 'rsyslog_read'@'localhost' IDENTIFIED BY 'password_234567';

3. 安装 rsyslog

 PATH=$ PATH:/usr/local/mysql/bin  # 因为MySQL手工安装，不在环境变量中，而rsyslog的configure会从环境变量中找MySQL的lib
 ./configure --prefix=/usr/local/rsyslog --enable-mysql  # 打开MySQL支持，将日志写到MySQL中可以在前端web上直接展示，报表
 make && make install
 mysql -u root -p < ./plugins/ommysql/createDB.sql      # 导入db结构

######### createDB.sql start #########

CREATE DATABASE Syslog;
USE Syslog;
CREATE TABLE SystemEvents
(
ID int unsigned not null auto_increment primary key,
CustomerID bigint,
ReceivedAt datetime NULL,
DeviceReportedTime datetime NULL,
Facility smallint NULL,
Priority smallint NULL,
FromHost varchar(60) NULL,
Message text,
NTSeverity int NULL,
Importance int NULL,
EventSource varchar(60),
EventUser varchar(60) NULL,
EventCategory int NULL,
EventID int NULL,
EventBinaryData text NULL,
MaxAvailable int NULL,
CurrUsage int NULL,
MinUsage int NULL,
MaxUsage int NULL,
InfoUnitID int NULL ,
SysLogTag varchar(60),
EventLogType varchar(60),
GenericFileName VarChar(60),
SystemID int NULL
);

CREATE TABLE SystemEventsProperties
(
ID int unsigned not null auto_increment primary key,
SystemEventID int NULL ,
ParamName varchar(255) NULL ,
ParamValue text NULL
);

######### createDB.sql end #########

 cp rsyslog.conf /etc/                # 默认配置文件
 ln -s /usr/local/rsyslog/sbin/rsyslogd /sbin/rsyslogd      # 这一步可用可不用

4. 配置

a. 在/etc/rsyslog.conf最上面加上 $ ModLoad ommysql 载入mysql支持的模块
b. 去掉/etc/rsyslog.conf内以下两行前的#号，打开udp监听端口

$ ModLoad imudp.so  # provides UDP syslog reception
$ UDPServerRun 514  # start a UDP syslog server at standard port 514

c. 增加/etc/rsyslog.conf下面两行，将local7和user的日志写到mysql中

local7.*  :ommysql:127.0.0.1,Syslog,rsyslog_write,password_123456  (去掉本行中的)
user.*    :ommysql:127.0.0.1,Syslog,rsyslog_write,password_123456   (去掉本行中的)

d. 去掉链接错的日志示例

:msg, contains, "error: connect"  ~

5. 替换

a. 由于rsyslog没有附带启动脚本，我做了如下修改
b. cp /etc/init.d/syslog /etc/init.d/syslogd  #保留老的的syslog启动文件，以备要恢复时使用
c. 编辑 /etc/init.d/syslog 将里面路径有关的全改成/usr/local/rsyslog/sbin/rsyslogd 如果你上面3.g这一步做了链接，就可以只把syslog改为rsyslogd
d. 这样修改完后就是先停掉老的syslog，再启用新的rsyslog了
e. /etc/init.d/syslogd  stop;  # 停掉系统自带的
f. /etc/init.d/syslog start      # 启用新的 rsyslog
6. 修改 iptables ，增加udp54端口出入，防止被人强x

a. Iptables -A RH-Firewall-1-INPUT -s 1.2.0.0/255.255.0.0 -p udp -m udp –dport 514 -j ACCEPT
b. Iptables -A RH-Firewall-1-INPUT -s 3.4.0.0/255.255.0.0 -p udp -m udp –dport 514 -j ACCEPT
7. 安装phplogcon

a.http://www.phplogcon.org/上下载最新版本
b. 解压到某个目录，并配置好apache的vhost，这些步骤就不写了，比较平常的操作
c. 访问http://127.0.0.1/install.php安装，填上 mysql的账号和密码就行了，其他选项都默认。
8. 配置日志客户端

a. 在web服务器上echo ‘kern.*;user.*  @1.2.3.4′ >> /etc/syslog.conf
b. /etc/init.d/syslog reload #重启syslogd