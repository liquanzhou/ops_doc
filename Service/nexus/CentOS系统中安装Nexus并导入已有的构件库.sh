CentOS系统中安装Nexus并导入已有的构件库

Nexus是Maven仓库管理器，用于搭建一个本地仓库服务器，这样做的主要的好处就是节约网络资源，速度快，开发团队中所有的Maven可以共享这个本地仓库，下载一遍共享使用。另外一个优点就是他为你的组织提供一个搭建构件的地方。本文将介绍如何在CentOS系统中安装配置Nexus，并介绍如何导入已有的构件仓库。
 
1、 软件
 
a) 下载Nexus 地址：http://www.sonatype.org/downloads/nexus-2.1.2-bundle.tar.gz
 b) 如无特殊说明，本文档操作用户为nexus
 c) nexus默认的管理员用户名密码是：admin/admin123
 
2、 安装
 
a) 解压

$ tar zxvf nexus-2.1.2-bundle.tar.gz
b) 移动到其他目录
 
$ mv nexus-2.1.2 /home/nexus/nexus
c) 设置为系统自启动服务（使用root用户）
 
# cd /etc/init.d/
# cp /home/nexus/nexus/bin/jsw/linux-x86-64/nexus nexus
 
 
编辑/etc/init.d/nexus文件，添加以下变量定义：
NEXUS_HOME=/home/nexus/nexus
PLATFORM=linux-x86-64
PLATFORM_DIR="${NEXUS_HOME}/bin/jsw/${PLATFORM}" 
 
修改以下变量：
 
WRAPPER_CMD="${PLATFORM_DIR}/wrapper"
WRAPPER_CONF="${PLATFORM_DIR}/../conf/wrapper.conf"
PIDDIR="${NEXUS_HOME}"
修改如下变量，设置启动用户为nexus：

RUN_AS_USER=nexus
执行命令添加nexus自启动服务
 
# chkconfig –add nexus
# chkconfig –levels 345 nexus on
执行如下命令启动、停止nexus服务
 
# service nexus start
# service nexus stop
 
 
d) 检查是否启动成功
 
在本机浏览器中访问URL: http://localhost:8081/nexus
会出现Nexus的欢迎页面
 注：如果想远程通过浏览器访问，则在远程浏览器中输入http://<ip>:8081/nexus
 <ip> 可通过在本地机器上输入命令 ifconfig 查看
 如果未能访问到nexus的欢迎页面，需要查看本机的防火墙设置，是否打开了端口8081
 
e) 修改配置
 
配置文件位置nexus/conf/nexus.properties，配置示例如下：

# Sonatype Nexus
 # ==============
 # This is the most basic configuration of Nexus.
 
 # Jetty section
 application-port=8081
 application-host=0.0.0.0
 nexus-webapp=${bundleBasedir}/nexus
 nexus-webapp-context-path=/nexus
 
 # Nexus section
 nexus-work=${bundleBasedir}/../sonatype-work/nexus
 runtime=${bundleBasedir}/nexus/WEB-INF
 pr.encryptor.publicKeyPath=/apr/public-key.txt

主要配置参数：
 
application-port：nexus启动端口
nexus-work：指定构件库的存储位置