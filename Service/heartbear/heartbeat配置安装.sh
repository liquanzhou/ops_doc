
#vip为程序读取mysql的IP，应和程序服务器的网卡一个网段
VIP  192.168.10.151
主   192.168.10.152
备   192.168.10.99

# heartbeat安装(主备一样)

#######################################################

#所需安装包
libnet.tar.gz
heartbeat-2.1.3.tar.gz
#安装步骤
groupadd haclient
useradd -g haclient hacluster
#首先安装libnet
tar zxvf libnet.tar.gz
cd libnet/
./configure
make
make install
#安装heartbeat
tar zxvf heartbeat-2.1.3.tar.gz
cd heartbeat-2.1.3
./ConfigureMe configure
make
#注意!make到一半，会报一个类似hbaping  HBcomm等字样的错误，解决方法：make后，重命名 lib/plugins/HBcomm/hbaping.loT 为 lib/plugins/HBcomm/hbaping.lo ，重新再执行make即可继续编译。
#这里的hbaping.loT在第一次make之前是不存在的，必须要先make编译，生成了hbaping.loT，再在报错的时候文件名修改为hbaping.lo，再重新make一次即可。
mv lib/plugins/HBcomm/hbaping.loT lib/plugins/HBcomm/hbaping.lo
make
make install


#主配置文件
vi /etc/ha.d/ha.cf
###################################

#日志
logfile	/var/log/ha-log

logfacility	local0

#心跳间隔时间(默认秒s)
keepalive 2

#死亡时间
deadtime 12

warntime 8

initdead 60

#端口
udpport	694

#使用哪块网卡做为心跳检查
bcast	eth0

#备用地址(主备不同)
ucast eth0 192.168.10.99

#主节点恢复后是否接管服务
auto_failback on

#两主机名
node	master152
node	backup99

#ping测试
ping 192.168.10.1

###################################

# 配置验证模式
vi /etc/ha.d/authkeys

auth 1
1 crc

chmod 600 authkeys

# 将mysql启动脚本添加为系统服务

# chkconfig: - 69 88
# description: this script is used for mysql
# author: mysql
#

ln -s /data3/mysql5/data/mysql.sh /etc/init.d/mysql_3310

# 配置虚拟服务(主机名 vip 服务名)
vi /etc/ha.d/haresources
master152 192.168.10.151 mysql_3310

# hosts文件要配置上两个机器的IP和机器名
vi /etc/hosts
192.168.10.152  master152
192.168.10.99  backup99

#主备都启动heartbeat服务后，heartbeat会自动启动mysql，关闭heartbeat时也会关闭mysql
service heartbeat start

#######################################################

1、主mysql的主机宕机，备用mysql自动接管
2、stop 主heartbeat服务，备用mysql自动接管
3、kill 主heartbeat服务，主mysql依然正常服务，备用mysql不接管，可重新启动主heartbeat服务。
4、kill或stop 主mysql服务，备用mysql不会接管服务，只能手动重启主heartbeat服务，heartbeat会自动启动主mysql服务。
可使用脚本检测主mysql服务，如果服务不存在则重启主heartbeat服务






