				openvpn 安装笔记


一、使用方法

1、常用信息

vpn安装路径
/etc/openvpn/2.0

服务端配置文件
/etc/openvpn/server.conf

服务端证书文件
ca.crt server.crt server.key dh1024.pem

客户端配置文件
client.ovpn

客户端证书文件
ca.crt ca.key client1.crt client1.csr client1.key

2、创建vpn登陆账号
useradd -s /bin/false  vpnuser

3、生成密码
mkpasswd -l 8  -C 2 -c 2 -d 4 -s 0

4、修改用户vpnuser的密码
passwd vpnuser

5、删除账号
注意：必须确认此用户不是需要登录shell的用户（/bin/false）后，才可以删除。
userdel vpnuser

6、查看日志
tail -f /var/log/messages 

7、重启vpn
/etc/init.d/openvpn restart

8、每隔3个月：重新生成key(让之前的key失效)、重置vpn用户的密码

重新生成ca文件，服务端证书，客户端证书。

cd /etc/openvpn/2.0
source ./vars
rm -rf /etc/openvpn/2.0/keys
./clean-all
./build-ca
./build-key-server server
./build-key client1
./build-dh
cd /etc/openvpn/2.0/keys
cp ca.crt server.crt server.key dh1024.pem /etc/openvpn/
service openvpn restart
 
------------------------------------------

二、openvpn服务端软件安装

检查linux系统版本
lsb_release -a

centos5.5请使用 安装方法1 
redhat4.8请使用 安装方法2

安装方法1: centos5.5

1、上传需要的软件包:
lzo-2.02-3.el5.kb.i386.rpm
openvpn-2.1-0.20.rc4.el5.kb.i386.rpm

2、安装加密软件包
[root@localhost ~]#rpm -ivh lzo-2.02-3.el5.kb.i386.rpm

3、安装openvpn
[root@localhost ~]#rpm -ivh openvpn-2.1-0.20.rc4.el5.kb.i386.rpm


安装方法2: redhat4.8

1、安装yum服务

(1)、上传需要的安装包列表：
centos-yumconf_4-4.3_noarch.rpm
python-urlgrabber_2.9.6-2_noarch.rpm
python-elementtree_1.2.6-4_i386.rpm
sqlite_3.2.2-1_i386.rpm
python-sqlite_1.1.6-1_i386.rpm
yum_2.4.0-1.centos4_noarch.rpm

(2)、安装上述yum服务的rpm包
[root@localhost ~]# rpm -ivh *.rpm

(3)、将默认的centos库去除
[root@localhost ~]# rm /etc/yum.repos.d/CentOS-Base.repo

2、升级yum源地址

(1)、上传需要软件包：
epel-release-4-10.noarch.rpm

(2)、升级
[root@localhost ~]# rpm -Uvh epel-release-4-10.noarch.rpm

3、安装加密软件lzo和openvpn
[root@localhost ~]# yum install lzo openvpn

------------------------------------------

三、配置openvpn服务端

1、复制生成证书密钥的文件夹
[root@localhost ~]#cp -r /usr/share/openvpn/easy-rsa/2.0/ /etc/openvpn/

2、复制范例的配制文件
[root@localhost ~]#cp /usr/share/doc/openvpn-2.1/sample-config-files/server.conf /etc/openvpn/

3、加载环境

[root@localhost ~]# cd /etc/openvpn/2.0/
[root@localhost 2.0]# vi vars

修改下面几项

export KEY_COUNTRY=”CN”(注：国家)
export KEY_PROVINCE=”Beijing”(注：省份)
export KEY_CITY=”Beijing”(注：城市)
export KEY_ORG=”PIP”(注：公司名称)
export KEY_EMAIL=”mis@pe.com”(注：电子邮件)

查询环境变量
[root@localhost 2.0]#env |grep KEY(先查看一下，看到是没有)

加载环境配置文件
[root@localhost 2.0]# source ./vars
NOTE: If you run ./clean-all, I will be doing a rm -rf on /etc/openvpn/2.0/keys
(注：如果你已经运行了./clean-all,就运行rm -rf /etc/openvpn/2.0/keys 删除)

加载后再次查询环境变量
[root@localhost 2.0]# env |grep KEY

KEY_EXPIRE=3650
KEY_EMAIL=mis@pe.com
KEY_SIZE=1024
KEY_DIR=/etc/openvpn/2.0/keys
KEY_CITY=Beijing
KEY_PROVINCE=Beijing
KEY_ORG=PIP
KEY_CONFIG=/etc/openvpn/2.0/openssl.cnf
KEY_COUNTRY=CN

4、初始化PKI  (PKI:公开密钥管理并能支持认证、加密、完整性和可追究性服务的基础设施)

生成keys的目录
[root@localhost 2.0]# ./clean-all

生成ca文件
[root@localhost 2.0]# ./build-ca

Country Name (2 letter code) [CN]:
State or Province Name (full name) [Beijing]:
Locality Name (eg, city) [Beijing]:
Organization Name (eg, company) [PIP]:
Organizational Unit Name (eg, section) []:MIS
Common Name (eg, your name or your server’s hostname) [server CA]:server  (注意一定要添server)
Name []:
Email Address [mis@pe.com]:

[root@localhost 2.0]# ls keys/ (可以看到keys下生成了ca.crt ca.key 两个文件)

5、生成server key

password和name一定要一样

[root@localhost 2.0]# ./build-key-server server

Country Name (2 letter code) [CN]:
State or Province Name (full name) [Beijing]:
Locality Name (eg, city) [Beijing]:
Organization Name (eg, company) [PIP]:
Organizational Unit Name (eg, section) []:MIS
Common Name (eg, your name or your server's hostname) [server]:server
Name []:
Email Address [mis@pe.com]:
A challenge password []:1qazWSX(注：密码一定要添)
An optional company name []:mis
Sign the certificate? [y/n]:y
1 out of 1 certificate requests certified, commit? [y/n]y

查看生成的  server.crt  server.csr  server.key
[root@localhost 2.0]# ls keys/

6、生成客户端 key

[root@localhost 2.0]# ./build-key client1

Country Name (2 letter code) [CN]:
State or Province Name (full name) [Beijing]:
Locality Name (eg, city) [Beijing]:
Organization Name (eg, company) [PIP]:
Organizational Unit Name (eg, section) []:
Common Name (eg, your name or your server’s hostname) [client1]:client1
Name []:
Email Address [mis@pe.com]:
A challenge password []:1qazWSX
An optional company name []:mis
Sign the certificate? [y/n]:y
1 out of 1 certificate requests certified, commit? [y/n]y

以上选项要和那个server的保持一致。

查看生成的  client1.crt  client1.key  client1.csr
[root@localhost 2.0]# ls keys/

7、生成Diffie Hellman  (Diffie Hellman:密钥交换协议/算法,确保共享KEY安全穿越不安全网络)
[root@localhost 2.0]# ./build-dh

…….+……………………+………………………………………….++*++*++*

8、创建服务端证书及配置文件

将keys下的 ca.crt server.crt server.key dh1024.pem 拷贝到/etc/openvpn下
[root@localhost 2.0]# cd keys/
[root@localhost keys]# cp ca.crt server.crt server.key dh1024.pem /etc/openvpn/

修改服务端配置文件，直接全部内容删除，把下面的粘贴即可
[root@localhost openvpn]# vi /etc/openvpn/server.conf

port 1194

proto udp

dev tun

ca ca.crt

cert server.crt

key server.key

dh dh1024.pem

server 10.8.0.0 255.255.255.0

push "redirect-gateway def1 bypass-dhcp"

push "dhcp-option DNS 8.8.8.8"

keepalive 10 120

comp-lzo

persist-key

persist-tun

status openvpn-status.log

verb 3

plugin /usr/lib/openvpn/plugin/lib/openvpn-auth-pam.so login

username-as-common-name

9、启动服务
[root@localhost openvpn]# service openvpn restart

服务启动后用ifconfig查看 可以看到有一个新的接口tun0
[root@localhost openvpn]# ifconfig

tun0 Link encap:UNSPEC HWaddr 00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00
inet addr:10.8.0.1 P-t-P:10.8.0.2 Mask:255.255.255.255
UP POINTOPOINT RUNNING NOARP MULTICAST MTU:1500 Metric:1
RX packets:26 errors:0 dropped:0 overruns:0 frame:0
TX packets:22 errors:0 dropped:0 overruns:0 carrier:0
collisions:0 txqueuelen:100
RX bytes:2804 (2.7 KiB) TX bytes:18332 (17.9 KiB)


10、添加防火墙转发功能

打开转发功能
echo 1 > /proc/sys/net/ipv4/ip_forward

添加转发
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -j MASQUERADE

查看转发规则
iptables -t nat -nL

保存规则
/etc/init.d/iptables save

更新当前主机iptables.cfg，在最后端添加如下内容

# Generated by iptables-save v1.3.5 on Sat Jan 28 16:29:35 2012
*nat
:PREROUTING ACCEPT [6020:941844]
:POSTROUTING ACCEPT [27397:1648716]
:OUTPUT ACCEPT [27397:1648716]
#vpn转发
-A POSTROUTING -s 10.8.0.0/255.255.255.0 -j MASQUERADE
COMMIT
# Completed on Sat Jan 28 16:29:35 2012

------------------------------------------

四、Windows上的客户端的设置

1、安装openvpn软件
http://openvpn.se/files/install_packages/openvpn-2.0.9-gui-1.0.3-install.exe

2、下载 服务器上的/etc/openvpn/2.0/keys/下的ca.crt ca.key client1.crt client1.csr client1.key 到C:\Program Files\OpenVPN\config下

3、copy C:\Program Files\OpenVPN\sample-config\client.ovpn 到C:\Program Files\OpenVPN\config下
使用记事本编辑client.ovpn  直接全部内容删除，把下面的粘贴即可

client

dev tun

proto udp

remote 192.168.30.213 1194    #注意服务器IP和端口

persist-key

persist-tun

ca ca.crt

cert client1.crt

key client1.key

ns-cert-type server

comp-lzo

verb 3

redirect-gateway def1

auth-user-pass

 




