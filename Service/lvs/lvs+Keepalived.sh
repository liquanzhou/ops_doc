
四台centos5.5

VIP 192.168.0.82
lvs 192.168.0.81 192.168.0.74
web 192.168.0.72 192.168.0.73


LVS服务器(DR模式，所有IP都在内网)

ln -s /usr/src/kernels/2.6.18-53.e15-i686/ /usr/src/linux
#如果/usr/src/kernels/目录空先安装kernel-devel 
#yum install  kernel-devel 
yum install ipvsadm
ipvsadm
lsmod |grep ip_vs

echo "1" > /proc/sys/net/ipv4/ip_forward

#/bin/bash
VIP=192.168.0.82
WEB1=192.168.0.72
WEB2=192.168.0.73

case "$1" in
start)

/sbin/ifconfig eth0:0 $VIP broadcast $VIP netmask 255.255.255.255 up
/sbin/route add -host $VIP dev eth0:0
/sbin/ipvsadm -C
/sbin/ipvsadm -A -t $VIP:80 -s rr
/sbin/ipvsadm -a -t $VIP:80 -r $WEB1 -g
/sbin/ipvsadm -a -t $VIP:80 -r $WEB2 -g
touch /var/lock/subsys/ipvsadm >/dev/null 2>&1
echo "lvs status-------------------[OK]"
;;
stop)
/sbin/ipvsadm -C
/sbin/ifconfig eth0:0 down
route del $VIP
rm -rf /var/lock/subsys/ipvsadm >/dev/null 2>&1
echo "lvs stop"
;;
status)
if [ ! -e /var/lock/subsys/ipvsadm ];then
	echo "lvs stop"
	exit 1
else
	echo "lvs status-------------------[OK]"
fi
;;
*)
echo "Usage: $0 {start|stop|status}"
exit 1
;;
esac




WEB服务器(两台一致)

#!/bin/bash
#description:start realserver
#chkconfig 
VIP=192.168.0.82
/etc/rc.d/init.d/functions
case "$1" in
start)
echo " start LVS of REALServer"
/sbin/ifconfig lo:0 $VIP1 broadcast $VIP1 netmask 255.255.255.255 up
/sbin/route add -host $VIP1 dev lo:0
echo "1" >/proc/sys/net/ipv4/ip_forward
echo "1" >/proc/sys/net/ipv4/conf/eth0/arp_ignore
echo "2" >/proc/sys/net/ipv4/conf/eth0/arp_announce
echo "1" >/proc/sys/net/ipv4/conf/all/arp_ignore
echo "2" >/proc/sys/net/ipv4/conf/all/arp_announce
;;
stop)
/sbin/ifconfig lo:0 down
echo "close LVS Directorserver"
echo "0" >/proc/sys/net/ipv4/ip_forward
echo "0" >/proc/sys/net/ipv4/conf/eth0/arp_ignore
echo "0" >/proc/sys/net/ipv4/conf/eth0/arp_announce
echo "0" >/proc/sys/net/ipv4/conf/all/arp_ignore
echo "0" >/proc/sys/net/ipv4/conf/all/arp_announce
;;
*)
echo "Usage: $0 {start|stop}"
exit 1
esac



编译 keepalived-1.1.17(版本不可过高)

yum install libnl-devel
./configure
make
make install

cp /usr/local/etc/rc.d/init.d/keepalived /etc/rc.d/init.d/   #设置为service方式启动
cp /usr/local/etc/sysconfig/keepalived /etc/sysconfig/
mkdir /etc/keepalived
cp /usr/local/etc/keepalived/keepalived.conf /etc/keepalived/
cp /usr/local/sbin/keepalived /usr/sbin/

/etc/init.d/keepalived start   #启动keepalived

vi /etc/rc.local  #添加为开机自启动
/usr/local/sbin/keepalived -D -f /etc/keepalived/keepalived.conf

# sed -i 's#net.ipv4.ip_forward = 0#net.ipv4.ip_forward = 1#' /etc/sysctl.conf  #开启内核转发功能
# sysctl -p    #查看是否开启内核转发

mv /etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf_bak  #备份原始配置文件

vi /etc/keepalived/keepalived.conf

========================================================


!Configuration File for keepalived

global_defs {
	#notification_email {
	#	quanzhou.li@pearlinpalm.com    #填写自己的邮箱出现故障接收报警邮件用
	#}
	#notification_email_from Alexandre.Cassen@firewall.loc
	#smtp_server 127.0.0.1
	#smtp_connect_timeout 30
	router_id LVS_01 #备份服务器改为LVS_02
}

vrrp_instance VI_1 {
	state MASTER #备份服务器上MASTER为BACKUP
	interface eth0
	#lvs_sync_daemon_inteface eth1
	virtual_router_id 51
	priority 100 #备份服务上优先级要低于100，如改为90
	advert_int 1
	authentication {
		auth_type PASS
		auth_pass 1111
	}
	virtual_ipaddress {
		192.168.0.82   #这里填写VIP地址，也可添加多个VIP
	}
}

virtual_server 192.168.0.82 80 {   #这里填写VIP地址
	delay_loop 6
	lb_algo rr
	lb_kind DR
	#nat_mask 255.255.255.0
	persistence_timeout 50
	protocol TCP
	real_server 192.168.0.72 80 { #这里是真实服务器的IP
		weight 1
		TCP_CHECK {
			connect_timeout 3
			nb_get_retry 3
			delay_before_retry 3
			connect_port 80
		}
	}
	real_server 192.168.0.73 80 { #这里是第二台真实服务器的IP
		weight 2
		TCP_CHECK {
			connect_timeout 3
			nb_get_retry 3
			delay_before_retry 3
			connect_port 80
		}
	}
}

========================================================





keepalived.conf 文件详解


安装完成之后，生成的配置文件放置于:/usr/local/keepalived/etc/keepalived/keepalived.conf
官方提供了不少模板性的配置文件：/usr/local/keepalived/etc/keepalived/samples
建议将配置文件放置于: /etc/keepalived/keepalived.conf
如果运用不指定配置文件，他可以直接调用/etc/keepalived/keepalived.conf中的配置文件

接下来，详细说明配置文件中的各项含义：

#全局定义块，以下模块不可省略，必须存在。
global_defs {
notification_email {
email #如有故障，发邮件报警的地址，一般不采用，可以随意填写
}

notification_email_from email
smtp_server host
smtp_connect_timeout num #邮件服务链接超时的最长时间
lvs_id string #Lvs负载均衡器标识，在一个网络里面，请保持他是唯一性。

}

#VRRP实例定义块

vrrp_sync_group string {  #确定失败切换（FailOver）包含的路由实例个数。即在有2个负载均衡器的场景，一旦某个负载均衡器失效
group {
string #备用的负载均衡的服务器名
string
}

vrrp_instance string { #前面定义的后备的负载均衡的服务器名

state MASTER|BACKUP #只有MASTER和BACKUP两种状态，都必须保持大写。

interface string #进行通信的端口，如eth0,eth1

mcast_src_ip @IP #真实的IP地址

lvs_sync_daemon_interface string #负载均衡器之间的监控接口。如果采用DR模式，可以保持和通信端口一致。

virtual_router_id num #这个标识是同一个vrrp实例使用唯一的标识。即同一个vrrp_stance,MASTER和BACKUP的virtual_router_id是一致的，同时在整个vrrp内是唯一的。

priority num #权重，数值越大，权重越大，Master大于Slave。

advert_int num #Master和Slave负载均衡器之间同步检查的时间间隔，单位：秒

smtp_alert

authentication { #Master和Slave之间认证的方式

auth_type PASS|AH

auth_pass string #认证的秘密

}

virtual_ipaddress { # Block limited to 20 IP addresses

IP
IP
IP

}

virtual_ipaddress_excluded { # Unlimited IP addresses number

IP
IP
IP

}

#虚拟服务器定义块

virtual_server (@IP PORT)|(fwmark num) { #上面定义的virtual_ipaddress，需要添加端口

delay_loop num #服务健康检查周期，单位：秒

lb_algo rr|wrr|lc|wlc|sh|dh|lblc #负载均衡的调度算法方式，一般使用rr或者wlc。

lb_kind NAT|DR|TUN #负载均衡转发规则，一般采用DR

(nat_mask @IP) #地址掩码，可不填

persistence_timeout num #会话保持时间，单位：秒。如果是动态服务，建议开启。

persistence_granularity @IP

virtualhost string

protocol TCP|UDP #通信协议，有

sorry_server @IP PORT

real_server @IP PORT { #真实IP地址

weight num #权重值，数值越大，权重越高，分发的可能越大。

TCP_CHECK {

connect_port num #检查端口

connect_timeout num #检查超时时间

}

}

real_server @IP PORT {

weight num

MISC_CHECK {

misc_path /path_to_script/script.sh

(or misc_path “/path_to_script/script.sh ”)

}

}

real_server @IP PORT {

weight num

HTTP_GET|SSL_GET {

url { # You can add multiple url block

path alphanum

digest alphanum

}

connect_port num

connect_timeout num

nb_get_retry num

delay_before_retry num

}

}

}

keepalived 实例

Master 服务器

#guration File for keepalived (Master Server)

#writed by eric.w.t 2011/04/12

###################################
#   global define
###################################

global_defs {
notification_email {
mesopodamia@gmail.com
}
notification_email_from sns-lvs@gmail.com
smtp_server 127.0.0.1
smtp_connect_timeout 30
router_id LVS_DEVEL
}

####################################
#   vrrp define
####################################

vrrp_sync_group VGM {
group {
VI_1
}
}

vrrp_instance VI_1 {

state MASTER
interface eth0
virtual_router_id 110
priority 100
advert_int 1
virtual_ipaddress {
10.249.0.208
}
}

#####################################
#   virtual machine setting
#####################################

virtual_server 10.249.0.208 80 {
delay_loop 6
lb_algo rr
lb_kind NAT
nat_mask 255.255.255.0
protocol TCP
persistence_timeout 20

real_server 10.249.0.254 80 {

weight 10
TCP_CHECK {
connect_timeout 3
nb_get_retry 3
delay_before_retry 3
connect_port 80
}
}

}

Slave 服务器配置

#guration File for keepalived (Slave Server)

#writed by eric.w.t 2011/04/12

###################################
#   global define
###################################

global_defs {
notification_email {
mesopodamia@gmail.com
}
notification_email_from sns-lvs@gmail.com
smtp_server 127.0.0.1
smtp_connect_timeout 30
router_id LVS_DEVEL
}

####################################
#   vrrp define
####################################

vrrp_sync_group VGM {
group {
VI_1
}
}

vrrp_instance VI_1 {

state SLAVE
interface eth0
virtual_router_id 110
priority 99
advert_int 1
virtual_ipaddress {
10.249.0.208
}
}

#####################################
#   virtual machine setting
#####################################

virtual_server 10.249.0.208 80 {
delay_loop 6
lb_algo rr
lb_kind NAT
nat_mask 255.255.255.0
protocol TCP
persistence_timeout 20

real_server 10.249.0.254 80 {

weight 10
TCP_CHECK {
connect_timeout 3
nb_get_retry 3
delay_before_retry 3
connect_port 80
}
}

}

参考文档 ：

http://www.keepalived.org/documentation.html


#调用检测脚本

vrrp_script check_run {

     script "/root/keepalived_check_mysql.sh"

     interval 5

}



