zabbix

agent  [passive   active]
snmp
ipmi
simple check    # 主动发起的
internal checks
trapper   # 自定义脚本
JMX       # 采集java的一些信息


history   保存每个采集到的值


#Zabbix触发器支持的函数说明
http://pengyao.org/zabbix-triggers-functions.html

Trigger 函数
     abschange	 最近值与之前值的绝对值
	 avg         平均值
	 change      最近的值与之前值的差值
	 count       统计出现次数
	 date        当前日期
	 dayofmonth  当前是本月第几月
	 
	 
	 
	 logseverity   返回最近日志条目的日志等级
	 logsource     检查最近的日志条目是否匹配参数的日志来源
	 max           返回指定时间间隔的最大值
	 min           返回指定时间间隔的最小值
	 

192.168.238.128
	 
安装
yum -y install mysql-server
service mysqld restart


# 修改字符集为utf8
vim /etc/my.cnf
	 
[mysql]
default-character-set=utf8

[mysqld]
character-set-server=utf8
	 
#mysql登陆后 \s 看字符集
/etc/init.d/mysqld restart
	 
	 
rpm -ivh http://repo.zabbix.com/zabbix/2.2/rhel/6/x86_64/zabbix-release-2.2-1.el6.noarch.rpm
	 
mysql -uroot -p
	 
create database zabbix;
grant all on zabbix.* to zabbix@localhost identified by "zabbix_pass";


yum -y install zabbix-server zabbix-server-mysql
	 
	 
	 
# 主配置文件 
vim /etc/zabbix/zabbix_server.conf
DBHost=
DBName=zabbix
DBPassword=zabbix_pass
	 
rpm -ql zabbix-server-mysql |grep sql

mysql zabbix < /usr/share/doc/zabbix-server-mysql-2.2.6/create/schema.sql   # 先创建表
mysql zabbix < /usr/share/doc/zabbix-server-mysql-2.2.6/create/images.sql   # 先图片
mysql zabbix < /usr/share/doc/zabbix-server-mysql-2.2.6/create/data.sql     # 最后有关联图片表

service zabbix-server start
chkconfig zabbix-server on


tail -f /var/log/zabbix/zabbix_server.log 

netstat -anlp |grep 10051


yum -y install zabbix-web zabbix-web-mysql  


vim /etc/httpd/conf.d/zabbix.conf
php_value date.timezone Asia/Chongqing

/etc/init.d/httpd start
chkconfig httpd on



http://192.168.238.128/zabbix


# 默认账户密码
admin/zabbix

# 关闭selinux
# setenforce 0 

# 中文
vim /usr/share/zabbix/include/locales.inc.php   # 58行  true
Profile   --->  Language   
http://www.zabbix.org/pootle


yum -y install zabbix-agent

vim /etc/zabbix/zabbix_agentd.conf

Server=127.0.0.1,192.168.238.128
#ServerActive=127.0.0.1

/etc/init.d/zabbix-agent start
chkconfig zabbix-agent  on


# zabbix_agentd -t key   # d启动是个独立的服务
zabbix_agent -t system.hostname
zabbix_agent -t system.sw.os[]
zabbix_agent -t system.uptime
zabbix_agent -t system.users.num
zabbix_agent -t system.localtime
zabbix_agent -t system.cpu


zabbix_agentd -t vm.memory.size[total]   # 

mem total  —-> vm.memory.size[total]
mem used —-> vm.memory.size[used]
mem used percent  —-> vm.memory.size[pused]		
mem free  —-> vm.memory.size[free]	
mem buffers  —-> vm.memory.size[buffers]
mem cached  —-> vm.memory.size[cached]
swap total  —-> system.swap.size[,total]	
swap used  —-> system.swap.size[,used]	
swap free  —-> system.swap.size[,free]

zabbix_agentd -t vfs.fs.size[/,used]
zabbix_agentd -t vfs.fs.inode[/,used]

/ Size  —-> vfs.fs.size[/,total]
/ Used  —-> vfs.fs.size[/,used]
/ Avail  —-> vfs.fs.size[/,free]
/ Use%  —-> vfs.fs.size[/,pused]
/ Inodes  —-> vfs.fs.inode[/,total]
/ IUsed  —-> vfs.fs.inode[/,used]
/ IFree  —-> vfs.fs.inode[/,free]
/ IUse%  —->  vfs.fs.inode[/,pused]



net.if.in[eth0,packets]



# 网卡流量注意  * 8 
Use custom multiplier


wget 'http://downloads.sourceforge.net/project/wqy/wqy-microhei/0.2.0-beta/wqy-microhei-0.2.0-beta.tar.gz?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Fwqy%2Ffiles%2Fwqy-microhei%2F0.2.0-beta%2F&ts=1365584502&use_mirror=jaist' -O wqy-microhei-0.2.0-beta.tar.gz

tar xvf wqy-microhei-0.2.0-beta.tar.gz 
mkdir -p /usr/share/fonts/wqy
cd wqy-microhei
cp wqy-microhei.ttc /usr/share/fonts/wqy/


cd /usr/share/zabbix/fonts
rm -f graphfont.ttf 
ln -s /usr/share/fonts/wqy/wqy-microhei.ttc graphfont.ttf


https://www.zabbix.com/documentation/2.2/manual/config/items/itemtypes/zabbix_agent


grpsum["Linux servers", "net.if.in[eth0]", last, 0]



#自定义脚本

cd /etc/zabbix/zabbix_agentd.d
vim LISTEN.conf
# UserParameter=custom.netstat.stats["LISTEN"],ss -ant|awk 'BEGIN{S=0}/^$1/{++S}END{print S}'
UserParameter=custom.netstat.stats[*],ss -ant|awk 'BEGIN{S=0}/^$1/{++S}END{print S}'
# * 可以把字符传递给后面作为参数   如果awk中需要显示原来的$1 需要在多加一个$   $$1

# 重启zabbix_agentd
/etc/init.d/zabbix-agent restart

zabbix_agentd -t custom.netstat.stats[LISTEN]
zabbix_agentd -t custom.netstat.stats[ESTAB]

UserParameter=aa.test[*],echo $1 $2 $3
zabbix_agentd -t aa.test[1,2,3]   # 传递3个参数  $1 $2 $3

# 电话报警
https://github.com/pengyao/zabbix-alert


#proxy
yum -y install zabbix-proxy zabbix-proxy-mysql
# 创建数据库，赋权限，导入表
# 修改配置文件 
vim /etc/zabbix/zabbix_proxy.conf
# 修改mysql配置














