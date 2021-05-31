keepalive安装(配合mysql主主复制)

系统:centos5.5_64

#vip为程序读取mysql的IP，应和程序服务器的网卡一个网段

主库实际IP   192.168.10.48
从库实际IP   192.168.10.49
虚拟VIP      192.168.10.50   #该IP供程序连接使用

【一】、keepalived安装步骤，这里建议使用keepalived-1.1.17，不可使用过高版本

wget http://www.keepalived.org/software/keepalived-1.1.17.tar.gz

tar zxvpf keepalived-1.1.17.tar.gz
cd keepalived-1.1.17
./configure
#不使用lvs只需要Use VRRP Framework为Yes
make
make install

#拷贝配置文件并创建配置问文件目录
cp /usr/local/etc/rc.d/init.d/keepalived /etc/init.d/
#suse使用keepalived.suse.init启动脚本覆盖/etc/init.d/keepalived
cp /usr/local/sbin/keepalived /usr/sbin/
cp /usr/local/etc/sysconfig/keepalived /etc/sysconfig/
mkdir /etc/keepalived

【二】、定义配置文件

vim /etc/keepalived/keepalived.conf   #（见下面文件详细配置）

#启动服务
/etc/init.d/keepalived start

#启动后加载配置文件(一般无需该操作，只有在更新了配置之后重新加载时使用)
/usr/sbin/keepalived -f /etc/keepalived/keepalived.conf


#如下是keepalived.conf配置文件内容，因为我们的需求是主主热备，无需其他功能，故主从的配置文件一致即可
#在同一局域网内，两组keepalived两参数 router_id 和 virtual_router_id 不可以一致
#
#主从库需要区别修改的三处如下：
#
# state 初始状态值，主库对应参数为 MASTER 从库对应的参数为 BACKUP
# priority 主库的优先级参数为150 从库的优先级参数为 100  注意这里的参数，从库的优先级一定要低于主库
# virtual_ipaddress 定义虚拟VIP地址以及绑定的网卡参数
#
###########################keepalived.conf配置内容##########################
! Configuration File for keepalived
global_defs {
	router_id mysql     #keepalive主机标识，这里的标识很重要，影响到主从库之间的keepalived通讯
}
vrrp_script check_run {
    script "/etc/keepalived/check_mysql.sh"    #服务器检查脚本，主要检查mysql是否可以正常访问
    interval 3                                 #服务检查周期，单位：秒
}
vrrp_sync_group VG1 {
	group {
		VI_1    #服务组名，多个时候一个出错就切换
	}
	notify_master  /etc/keepalived/takeover.sh    #状态切换为从库接管时执行该脚本，即主库宕机时，从库接管
	notify_backup  /etc/keepalived/recovery.sh    #状态切换为主库接管时执行该脚本，即主库恢复时，从库归还
}
vrrp_instance VI_1 {
	state BACKUP           #初始状态,都设置为BACKUP,配合不抢占参数
	interface eth1         #实例绑定网卡
	virtual_router_id 11   #VRID标识0-255
	priority 150           #主库的高优先级竞选为MASTER，从库的优先级要低于主库，故需要设置为100
	advert_int 1           #检查时间，单位：秒
	nopreempt              #不抢占,只能设置在BACKUP上
	authentication {
		#验证方式
		auth_type PASS
		auth_pass 1qaz@WSX
	}
	track_script {
		check_run          #定义程序的检查方法，调用脚本
	}
	virtual_ipaddress {
		#VIP
		10.10.20.205 dev eth1 label eth1:1
	}
}
##########################end#############################################
【三】、注意事项

1、无论主从服务器mysql都要优先keepalived启动，所以mysql开机启动权值应高于keepalived
2、将启动脚本加入系统服务启动项，需在脚本加入如下一段内容,位置放到`#!/bin/sh`下即可，注意前面的`#`号需要添加

`# chkconfig: 2345 90 80 `

#解释如下：
# chkconfig   系统命令通过该命令获取参数
# 2345        启动顺序
# 20          开机启动优先权  故mysql的启动优先权一定要高于keepalived优先权，建议将mysql设置为15 ,keepalived设置为80
# 80          关机停止优先权  故mysql的停止优先权一定要高于keepalived优先权，建议将mysql设置为60 ,keepalived设置为80

3、添加启动

chkconfig --add keepalived
chkconfig --level 35 keepalived on

4、如果需要主从两台服务器关机维护时，如迁移机房，应先关闭从库服务器上的mysql和keepalived，再关闭主库的服务，避免因为先关闭主库而导致从库接管服务

【四】、需要配合的检查脚本及报警脚本如下

##########################################################################
#!/bin/bash
#脚本位置：/etc/keepalived/check_mysql.sh
#脚本作用：mysql状态检测脚本

mysql -urepl -p"repl"  -h127.0.0.1 -P3306 -e "show status;" >/dev/null 2>&1
if [ "$?" -ne 0 ];then
/etc/init.d/keepalived stop
fi
#脚本结束
##########################################################################

chmod 700 /etc/keepalived/check_mysql.sh

##########################################################################
#!/bin/sh
#脚本位置：/etc/keepalived/takeover.sh
#脚本作用：接管服务报警脚本

#报警短信手机号
Phonenumber=13811080724

LANG="zh_CN.GBK"
export LANG

IP=`/sbin/ifconfig|awk -v RS="Bcast:" '{print $NF}'|awk -F: '/addr/{print $2}'|awk '{printf"%s_",$0}' | sed 's/_$//'`

node=`ls /data1/*mysql5*/data/*_mysql5_*_[0-9][0-9]*|awk -F "/" '{print $NF}'|awk -F"_" '{print $1}'`

case $node in
master)
	#报警信息
	SMS="${node}库`hostname`已恢复服务_${IP}_`date +%Y%m%d_%R`"
	#邮件报警
	echo $SMS | /bin/mail -s "keepalived恢复通知" mis@pearlinpalm.com
	#短信报警
	java -cp "/root/sh" SmsDelegate $Phonenumber "$SMS"
;;
slave)
	#备用节点接管后，停止数据库备份
	sed -i  's/\(.*\)dbbackup\.sh\(.*\)/#\1dbbackup\.sh\2/' /var/spool/cron/root
	#报警信息
	SMS="${node}库`hostname`已接管服务_${IP}_`date +%Y%m%d_%R`"
	#邮件报警
	echo $SMS | /bin/mail -s "keepalived接管通知" mis@pearlinpalm.com
	#短信报警
	java -cp "/root/sh" SmsDelegate $Phonenumber "$SMS"
		
;;
esac

#记录日志
echo $SMS >> /etc/keepalived/keepalived.log
	
#脚本结束
##########################################################################

chmod 700 /etc/keepalived/takeover.sh

##########################################################################
#!/bin/sh
#脚本位置：/etc/keepalived/recovery.sh
#脚本作用：关闭服务通知脚本

Phonenumber=15801177843

LANG="zh_CN.GBK"
export LANG

IP=`/sbin/ifconfig|awk -v RS="Bcast:" '{print $NF}'|awk -F: '/addr/{print $2}'|awk '{printf"%s_",$0}' | sed 's/_$//'`

node=`ls /data1/*mysql5*/data/*_mysql5_*_[0-9][0-9]*|awk -F "/" '{print $NF}'|awk -F"_" '{print $1}'`
case $node in
master)
SMS="${node}库`hostname`已等待接管_${IP}_`date +%Y%m%d_%R`"
;;
slave)
SMS="${node}库`hostname`已等待接管_${IP}_`date +%Y%m%d_%R`"
#主节点恢复后，启动数据库备份
sed -i  's/#\(.*\)dbbackup\.sh\(.*\)/\1dbbackup\.sh\2/' /var/spool/cron/root
;;
esac

#记录日志
echo $SMS >> /etc/keepalived/keepalived.log

#脚本结束
##########################################################################

chmod 700 /etc/keepalived/recovery.sh

【五】、测试结果

1、首先需要保证mysql和keepalived都正常启动，且mysql优先启动于keepalived.可以ifconfig查看到主库的虚拟VIP网卡，从库是正常网卡

2、将主库服务器电源直接断电，从库自动接管，时间预计2秒钟左右.从库将自动启动虚拟VIP网卡，并接管成功，访问数据库正常。在接管的同时从库会发出报警告知。

3、重新启动主库,待主库正常启动，从库将自动归还，这时从库的虚拟VIP将消失，主库的虚拟VIP加载。同时从库在归还的同时将发出报警告知。

4、如果结果vip不生效,从接管VIP后主动刷新arp:  /sbin/arping -I em1 -c 10 -s vip gateway&>/dev/null