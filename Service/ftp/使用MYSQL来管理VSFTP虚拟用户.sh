
使用MYSQL来管理VSFTP虚拟用户  

2012-01-15 19:12:48|  分类： 技术文稿 |  标签：linux  服务器架设   |举报 |字号 订阅
               VSFTPD是linux平台上一款以安全、高效、稳定而著称的ftp服务器软件。软件配置灵活，使用方便，支持多种认证方式包括：匿名用户认证；本地用户认证；虚拟用户认证方式。  前两种很好理解，其中第三种虚拟用户认证方式又分两种，一种为使用文件文件方式创建虚拟用户表后使用db_load转换为佰克利数据库格式使用。还有一种是使用mysql数据库时行管理。 今天写的是如何使用mysql来管理虚拟用户。
     1、安装vsftpd  软件 ,启动对应的服务 
       yum -y  install  vsftpd 
       service vsftpd  start
       chkconfig  vsftpd  on  
     2、安装mysql  软件 ，启动对应的服务
        yum  -y  install   mysql-devel  mysql-server
         service  mysqld start
         chkconfig  mysqld  on 
     3、配置mysql数据库 
            3.1 首先设置mysql管理员密码  
                   mysql  -u root  password   test123
            3.2  进入mysql数据。建立相应的数据库和密码认证表。 
                  #mysql  -u root -ptest123
                 mysql> create database  vftp;
                 mysql> use  vftp;
                 mysql> create table  userinfo(name  char(16),pwd  char(32));
                 mysql> insert into  userinfo(name,pwd) value ('jack','123456');
                 mysql> insert into  userinfo(name,pwd)  value  ('lili','654321');
                创建一个vftp的数据库，在其中创件一个userinfo的表文件，插入两条数据
             3.3  为安全考虑，可以创建一个用户专门读取此表。
                 mysql>select on vftp.userinfo to ftpuser@localhost identified by 'test123';
                 mysql>flush privileges;
     4、下载安装专门用于验证mysql的pam 认证程序 。 
                4.1  猛击这里下载文件  
                4.2   tar  -xzvf  am_mysql-0.7RC1.tar.gz    
                4.3   cd pam_mysql-0.7RC1 
                4.4   ./configuer   
                4.5    make;make install  
               网上有些教程说的是安装到/lib/security 目录下，不知怎么搞的，我的pam认证文件会安装到/usr/lib/security 目录下，加了--perfix  等参数都不可以。郁闷。  不过大家不用太纠结于此，不管安装到什么位置，只要在/etc/pam.d/vsftpd 中指定文件正确的路径即可。
       5、  添加虚拟用记所对应的系统用户
               mkdir   /var/ftp/ftproot
                useradd   -d  /var/ftp/ftproot   -s /sbin/nologin   virtual
                chown   virtual.  /var/ftp/ftproot 
       6、  配置 /etc/vsftpd/vsftpd.conf 文件 
               在文件底部添加如下两行:
               guest_enable=yes                
               guest_username=virtual  
                并修改原文件中的 anonymous_enable=yes 改为no 
       7 、编辑vsftpd 的pam 认证文件。
                /etc/pam.d/vsftpd文件，将原文件中所有内容注释掉，并添加如下两行。
              # auth required
			  auth            sufficient      /usr/lib/security/pam_mysql.so user=vsftpd passwd=123456 host=localhost db=vftp table=userinfo usercolumn=name passwdpasswdcolumn=passwd crypt=2 
			  
			  
         8、        重启FTP服务器进行测试。
               service  vsftpd  restart 
           FTP Voyager - 版本 15.1.0.0

                  状态：> 正在连接到"192.168.157.134" 使用端口 21。
                     220 Welcome to blah FTP service.
                  状态：> 已连接。正在登录服务器
                    命令：> USER jack
                    331 Please specify the password.
                  命令：> PASS ********
                    230 Login successful.
                   状态：> 登录成功
                   命令：> SYST

            不能登陆的常见问题：  
         1、检查是否开启了selinux  
              getenforc      若开启后请关闭或者是请允许FTP服务连接数据库
               setsebool   ftpd_connect_db=1
        2、检查是否开启了iptable 防火墙。 
              若开启了请关闭或者添加一条规则到规则库里
              iptables  -I  INPUT  2  -p tcp  - -dport 21 -j ACCEPT
         3、若还是有问题，请仔细检查配置文件，看有没有错误的地方。
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 编辑vsftp配置文件，参考我的配置

    [root@localhost ~]# vim /etc/vsftpd/vsftpd.conf 
    [root@localhost ~]# grep -v "^#" /etc/vsftpd/vsftpd.conf 
    anonymous_enable=YES 
    local_enable=YES 
    write_enable=YES 
    local_umask=022 
    anon_upload_enable=YES 
    anon_mkdir_write_enable=YES 
    dirmessage_enable=YES 
    xferlog_enable=YES 
    connect_from_port_20=YES 
    xferlog_std_format=YES 
    chroot_local_user=YES 
    listen=YES 
    pam_service_name=vsftpd.mysql #主要修改这一行，指定使用vsftpd.mysql这个pam配置文件调用pam认证 
    guest_enable=YES #开启来宾账户 
    guest_username= mysqlftp #映射来宾账户，这个账户将会被映射为mysql数据库中的账户 
    user_config_dir=/etc/vsftpd/vsftpd_user_conf #创建mysql每个虚拟用户的配置目录 

编辑pam配置文件，参考我的配置
[root@localhost ~]# cp /etc/pam.d/vsftpd /etc/pam.d/vsftpd.mysql #复制原来的vsftp认证方法，在此基础上添加mysql认证

编辑PAM认证配置文件
[root@localhost ~]# vim /etc/pam.d/vsftpd.mysql

    #%PAM-1.0 
     
    session         optional        pam_keyinit.so    force revoke 
     
    #第一步认证首先使用数据库认证，如果通过不再检查下面其它认证，直接登陆，通不过就使用下面的认证 
     
    auth            sufficient      /usr/lib/security/pam_mysql.so user=vsftpd passwd=123456 host=localhost db=vsftpd table=users usercolumn=name passwdpasswdcolumn=passwd crypt=2 
     
    #数据库认证通不过，就采用vsftp默认的其余认证方法 
     
    auth            required        pam_listfile.so item=user sense=deny file=/etc/vsftpd/ftpusers onerr=succeed 
    auth            required        pam_shells.so
    auth            include         password-auth 
     
    #授权和认证也是一样的 
    account         sufficient      /usr/lib/security/pam_mysql.so user=vsftpd passwd=123456 host=localhost db=vsftpd table=users usercolumn=name passwdpasswdcolumn=passwd crypt=2 
    account         include         password-auth 
    session         required        pam_loginuid.so
    session         include         password-auth 

以上的PAM配置既可以使用mysql数据库中的用户认证，也可以使用系统用户认证，如果只希望使用mysql数据库中的用户认证的话，可以讲系统认证的配置相关行删除。