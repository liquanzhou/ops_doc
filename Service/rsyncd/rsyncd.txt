一、下载、安装rsync
http://rsync.samba.org/ftp/rsync/src/
#tar zxvf rsync-2.6.9.tar.gz
#cd rsync-2.6.9
#./configure --prefix=/usr/local/rsync
#make 
#make install 

二、配置rsync server
1、启动RSYNC
#vi /etc/xinetd.d/rsync
  把原来的YES改成NO
service rsync
{
        disable = no
        socket_type     = stream
        wait            = no
        user            = root
        server          = /usr/bin/rsync
        server_args     = --daemon
        log_on_failure  += USERID
}
随系统启动RSYNC
     #chkconfig rsync on


vi /etc/rsyncd.conf

uid = root                                  //运行RSYNC守护进程的用户
gid = root                                  //运行RSYNC守护进程的组
use chroot = no                 //不使用chroot
max connections = 4             // 最大连接数为4
strict modes =yes                //是否检查口令文件的权限
port = 873                      //默认端口873


[backup]                   //这里是认证的模块名，在client端需要指定
path = /home/backup/        //需要做镜像的目录,不可缺少！
comment = backup       //这个模块的注释信息 
ignore errors                //可以忽略一些无关的IO错误
read only = yes              // 只读
list = no                   //不允许列文件
auth users = hening             //认证的用户名，如果没有这行则表明是匿名，此用户与系统无关
secrets file = /etc/rsync.pas           //密码和用户名对比表，密码文件自己生成
hosts allow = 192.168.1.1,10.10.10.10      //允许主机
hosts deny = 0.0.0.0/0                   //禁止主机
#transfer logging = yes


3、配置rsync密码（在上边的配置文件中已经写好路径） /etc/rsync.pas（名字随便写，只要和上边配置文件里的一致即可），格式(一行一个用户)
账号：密码
  #vi /etc/rsync.pas
例子:
hening:111111
权限：因为rsync.pas存储了rsync服务的用户名和密码，所以非常重要。要将rsync.pas设置为root拥有, 且权限为600。
#cd /etc
#chown root.root rsync.pas 
#chmod 600 rsync.pas
3.rsyncd.motd（配置欢迎信息，可有可无）
# vi /etc/rsyncd.motd
rsyncd.motd记录了rsync服务的欢迎信息，你可以在其中输入任何文本信息，如：
Welcome to use the rsync services!
4、让配置生效
#service xinetd restart
三、启动rsync server
  RSYNC服务端启动的两种方法
1、启动rsync服务端（独立启动）
#/usr/bin/rsync –daemon
2、启动rsync服务端 （有xinetd超级进程启动）
# /etc/rc.d/init.d/xinetd reload
四：加入rc.local 
在各种操作系统中，rc文件存放位置不尽相同，可以修改使系统启动时把rsync --daemon加载进去。
#vi /etc/rc.local
加入一行/usr/bin/rsync --daemon
    

五．检查rsync
#netstat -a | grep rsync
   tcp        0      0 0.0.0.0:873                 0.0.0.0:*                   LISTEN   
六．配置rsync client 
1、设定密码
#vi /etc/rsync.pas
111111
修改权限
#cd /etc
#chown root.root rsync.pas 
#chmod 600 rsync.pas
2、client连接SERVER
  从SERVER端取文件
/usr/bin/rsync -vzrtopg --progress --delete hening@192.168.0.217::backup /home/backup --password-file=/etc/rsync.pas
  向SERVER端上传文件
   /usr/bin/rsync -vzrtopg --progress --password-file=/root/rsync.pas  /home/backup hening@192.168.0.217::backup
    这个命令将把本地机器/home/backup目录下的所有文件（含子目录）全部备份到RSYNC SERVER（172.20.0.6）的backup模块的设定的备份目录下。
请注意如果路径结束后面带有"/",表示备份该目录下的东东，但不会创建该目录，如不带"/"则创建该目录。
RSYNC用法：
       rsync [OPTION]... [USER@]HOST::SRC  [DEST]              #从RSYNC SERVER备份文件到本地机器
    rsync [OPTION]... SRC [SRC]...      [USER@]HOST::DEST   #从本地机器备份文件到RSYNC SERVER
3、自动运行
1）vi /usr/local/rsync/time.sh     //制作脚本文件
把下边的内容复制进去
#!/bin/bash
/usr/bin/rsync -vzrtopg --progress --delete hening@192.168.0.217::backup /home/backup --password-file=/etc/rsync.pas
2) crontab -e
加入55 * * * * /usr/local/rsync/time.sh        //每55分运行一次time.sh脚本文件
五 iptables
iptables -A INPUT -p tcp -s ! 11.22.33.44 --dport 873 -j DROP
如此, 只有 11.22.33.44 这个 client IP 能进入这台 rsync server.
命令介绍：-rvlHpogDtS
rsync命令参数
-v表示verbose详细显示
-z表示压缩
-r表示recursive递归
-t表示保持原文件创建时间
-o表示保持原文件属主
-p表示保持原文件的参数
-g表示保持原文件的所属组
-a存档模式
-P表示代替-partial和-progress两者的选项功能
-e ssh建立起加密的连接。
--partial阻止rsync在传输中断时删除已拷贝的部分(如果在拷贝文件的过程中，传输被中断，rsync的默认操作是撤消前操作，即从目标机上
删除已拷贝的部分文件。)
--progress是指显示出详细的进度情况
--delete是指如果服务器端删除了这一文件，那么客户端也相应把文件删除，保持真正的一致。
--exclude不包含/ins目录
--size-only 这个参数用在两个文件夹中的差别仅是源文件夹中有一些新文件，不存在重名且被修改过的文件，因为这种文件有可能会因为内容被修改可大小一样，而被略过。这个参数可以大大地提高同步的效率，因为它不需要检查同名文件的内容是否相同。
--password-file来指定密码文件，内容包含server端指定认证用户的密码。
这样就可以在脚本中使用而无需交互式地输入验证密码了，这里需要注意的是这份密码文件权限属性要设得只有属主可读。
hening@192.168.0.217::backup
hening是指server端指定认证的用户
192.168.0.217是指服务器端的ip
::backup 表示服务器端需要同步的模块名称；
/home/quack/backup/$DATE是同步后的文件指存放在本机的目录地址。
/var/log/rsync.$DATE是同步后的日志文件存放在本机的目录地址。
注意
不放/  则目录名也包含mirror，放 / 则只有目录里面的东西mirror了
实例总结流程：
1.配置主控端
# vim /etc/rsyncd.conf
###################################
uid = nobody
gid = nobody
use chroot = no
max connections = 4
stirict modes = yes
port = 873
[backup]
path = /usr/local/test/
comment = This is a test
ignore errors
read only = false
list = no
hosts allow = 192.168.0.11
hosts deny = 0.0.0.0/0
auth users = bakweb
secrets file =/etc/rsyncd.pw
pid file = /var/run/rsyncd.pid
lock file = /var/run/rsync.lock
log file = /var/log/rsyncd.log
###################################
# vim /etc/rsyncd.pw
###################################
bakweb:123456
###################################
# cd /etc
# chown root.root rsyncd.pw
# chmod 600 rsyncd.pw
启动rsync server
# rsync --daemon
查看端口873是否打开
加入启动
# echo "rsync --daemon" >>/etc/rc.local
给/usr/local/test目录写权限
# chown -R nobody.nobody /usr/local/test
# chmod -R 770 /usr/local/test
主控配置完成
2.客户端配置
# vim /etc/rsyncd.pw
####################################
123456
####################################
# chown root.root /etc/rsyncd.pw
# chmod 600 /etc/rsyncd.pw
再使用命令直接更新到服务器数据文件就不需要密码
rsync -vzrtopg --progress --password-file=/etc/rsyncd.pw  /usr/local/bin/ bakweb@192.168.0.10::backup
注意：
1.这里的backup名字为主控conf配置里面的[backup]，一定要同名
2.bakweb为主控conf配置里面的bakweb，可以随意命名，不是系统用户