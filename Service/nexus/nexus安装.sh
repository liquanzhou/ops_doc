
nexus安装

下载tar
http://www.sonatype.org/nexus/go

新版本需要jdk7支持

# 创建用户
groupadd nexus
useradd  -g nexus -d /opt/nexus-2.8.1-01/home nexus

cd bin/
vim nexus
#添加一行启动用户
RUN_AS_USER=nexus

#配置文件  指定监听端口及IP等
conf/nexus.properties


http://10.13.81.87:8081/nexus/



# 启动
cd bin
./nexus restart
# 启动后注意看log的报错
vim ../logs/wrapper.log

# 启动用户为root，可在 bin/nexus 中设置为 RUN_AS_USER=root  或指定用户 nexus
If you insist running as root, then set the environment variable RUN_AS_USER=root before running this script.

# 启动用户需要有家目录
su: warning: cannot change directory to /home/nexus: No such file or directory
This account is currently not available.


# jdk版本过低 需要安装 jdk7
jvm 5    | Exception in thread "main" java.lang.UnsupportedClassVersionError: org/sonatype/nexus/bootstrap/jsw/JswLauncher : Unsupported major.minor version 51.0
# 如原来已有jdk低版本
# 可在新创建的nexus用户家目录的 .bash_profile 文件中添加环境 , 注意放到 $JAVA_HOME/bin 放到 $PATH 前
export JAVA_HOME=/usr/java/jdk1.7.0_60
export CLASSPATH=.:$JAVA_HOME/jre/lib/rt.jar:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
export PATH=$JAVA_HOME/bin:$PATH


Nexus work directory already in use
# /opt/sonatype-work/ 默认在解压目录的同一层目录,可能启动用户没有写权限，也可能因为之前用其他用户启动失败导致
# 最好修改 nexus.properties 配置文件中的 此变量 可去掉 ../  ，即放到当前解压目录下
nexus-work=${bundleBasedir}/../sonatype-work/nexus