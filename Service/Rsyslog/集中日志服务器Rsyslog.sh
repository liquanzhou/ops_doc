集中日志服务器Rsyslog


基于主机的管理一般需要收集服务器的日志信息用于及时发现错误，处理故障。

搭建linux下的集中日志服务器的程序一般可以用syslog,rsyslog,syslog-ng,还有scribe和fluentd等。

基本每一种方式都是服务器端和客户端的模式。

一般syslog,syslog-ng,rsyslog用于收集系统日志，scribe和fluentd用于收集业务日志，rsyslog和syslog-ng也可以收集业务日志，并可定制和过滤、筛选。

LogAnalyzer和LogZilla是分析系统日志，并用web界面展示的的工具，一般只用在syslog,syslog-ng,rsyslog日志系统中。

如下是基于Centos5的rsyslog+mysql+phplogcon的安装，安装前确认安装有EPEL源。

安装rsyslog以及rsyslog-mysql接口支持
帮助

	
yum install rsyslog rsyslog-mysql

安装数据库以及web程序
帮助

	
yum install mysql-server
yum install httpd php php-mysyql php-gd
service mysqld status || service mysqld start

创建rsyslog写入数据需要的库文件，路径可能根据版本有所不同
mysql < /usr/share/doc/rsyslog-mysql-2.0.8/createDB.sql 创建账户和密码(确保一致/etc/rsyslog.conf and /path/top/phplogcon/config.php )
帮助

mysql&gt; grant all on Syslog.* to syslog@localhost identified by 'mypass';
mysql&gt; flush privileges ;
 
vi /etc/rsyslog.conf
# Log to Mysql Settings
$ModLoad ommysql
*.* :ommysql:localhost,Syslog,syslog,phplogcon
#Standard Redhat syslog settings
*.info;mail.none;authpriv.none;cron.none /var/log/messages
authpriv.* /var/log/secure
mail.* -/var/log/maillog
cron.* /var/log/cron
*.emerg *
uucp,news.crit /var/log/spooler
local7.* /var/log/boot.log

启动rsyslog:
帮助
显示代码
1
2
	
service syslog stop
service rsyslog start

如果有如下报错信息
Feb 23 23:43:30 mon rsyslogd:could not load module ‘/usr/lib/rsyslog/ommysql’, dlopen: /usr/lib/rsyslog/ommysql: cannot open shared object file: No such file or directory

请尝试软连接
fix fast with:
ln -s /usr/lib/rsyslog/ommysql.so /usr/lib/rsyslog/ommysql

开机启动rsyslog，并关闭syslog的开机启动：
chkconfig syslog off
chkconfig rsyslog on

开启接收远程信息：
edit /etc/sysconfig/rsyslog with option -r:
修改成：SYSLOGD_OPTIONS=”-m 0 -r”
默认开启UDP 514端口，请确保防火墙没有阻止。

以下是PHPLOGCON的安装
到网址下载最新版本，http://www.phplogcon.org/
新版本已更名为LogAnalyzer

安装如下方式安装
tar -zxvf phplogcon-2.8.1.tar.gz
cd phplogcon-2.8.1
mkdir /var/www/html/syslog
cp -a src/* /var/www/html/syslog
cd /var/www/html/syslog
chmod 666 config.php

打开浏览器输入: http://yourserver/syslog/
按照提示操作
安装好后，请做如下操作，以防止被修改。
chmod 644 config.php

客户端发送日志

以Centos为例，不需要安装其他日志程序，直接修改/etc/syslog.conf，在最后一行下面加入：

/var/log/messages @rsyslog_IP

保存，重启service syslog restart

查看phplogcon界面是否有客户端的日志出现。
