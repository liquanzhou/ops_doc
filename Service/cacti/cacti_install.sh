cacti安装

yum扩展源
http://download.fedoraproject.org/pub/epel
wget http://download.fedoraproject.org/pub/epel/5/i386/epel-release-5-4.noarch.rpm
rpm -Uvh epel-release-5-4.noarch.rpm



yum install  -y rrdtool httpd php php-mysql php-snmp php-xml php-gd mysql mysql-server net-snmp net-snmp-libs net-snmp-utils
安装配置net-snmp
1、安装net-snmp

2、配置net-snmp
修改：
view systemview included .1.3.6.1.2.1.1
为：
view systemview included .1.3.6.1.2.1
3、测试net-snmp
# service snmpd start
# snmpwalk -v 1 -c public localhost .1.3.6.1.2.1.1.1.0
SNMPv2-MIB::sysDescr.0 = STRING: Linux cronos 2.4.28 #2 SMP ven jan 14 14:12:01 CET 2005 i686

service httpd start
service mysqld start
mysqladmin -uroot password myjob
mysqladmin --user=root --password reload
安装cacti
1、下载cacti
cd /tmp
wget http://www.cacti.net/downloads/cacti-0.8.8a.tar.gz
tar xzf cacti-0.8.8a.tar.gz
mv cacti-0.8.8a /var/www/html/cacti
cd /var/www/html/cacti
2、创建数据库
mysqladmin --user=root -p create cacti
3、导入数据库
mysql -uroot -p cacti < cacti.sql
4、创建数据库用户
shell> mysql -uroot -p mysql
mysql> GRANT ALL ON cacti.* TO cacti@localhost IDENTIFIED BY 'myjob';
mysql> flush privileges;
5、配置include/config.php
$database_type = "mysql";
$database_default = "cacti";
$database_hostname = "localhost";
$database_username = "cacti";
$database_password = "myjob";
/* load up old style plugins here */
$plugins = array();
//$plugins[] = 'thold';
/*
Edit this to point to the default URL of your Cacti install
ex: if your cacti install as at http://serverip/cacti/ this
would be set to /cacti/
*/
$url_path = "/cacti/";
/* Default session name - Session name must contain alpha characters */
#$cacti_session_name = "Cacti";
6、设置目录权限
chown -R cactiuser rra/ log/
cactiuser为系统存在的用户，为了收集数据。
7、配置计划任务
crontab -e
*/5 * * * * php /var/www/html/cacti/poller.php

8、完成cacti的安装
1) 在浏览器中输入：ip/cacti
默认用户名： admin  密码：admin
2) 更改密码
3）设置cacti用到的命令路径


检测snmp是否可以取数据
snmpwalk -v 2c -c public
