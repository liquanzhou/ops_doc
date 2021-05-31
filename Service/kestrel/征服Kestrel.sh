
征服Kestrel

kestrel的项目主页   http://github.com/robey/kestrel  
Kestrel的安装配置   http://robey.github.io/kestrel/readme.html  
                    https://github.com/robey/kestrel/blob/master/docs/guide.md  
                    http://dmouse.iteye.com/blog/1746171  
kestrel的wiki页     http://wiki.github.com/robey/kestrel  
memcache官网        http://www.memcached.org/  
xmemcached项目主页  http://code.google.com/p/xmemcached/  

因为要面对高并发PUSH需求，考虑将其按队列方式实现，最终选型Kestrel。
至于Kestrel：

    基于Scala语言的Twitter开源消息中间件
    高性能（TPS 6000不成问题）、小巧（2K行代码）、持久存储（记录日志到journal）并且可靠（支持可靠获取）
    Kestrel的前身是Ruby写的Starling项目，后来twitter的开发人员尝试用Scala重新实现。 


可支持的标准协议：

    SET          存
    GET          取
    FLUSH_ALL    清理
    STATS        状态 


扩展协议：

    SHUTDOWN       关闭kestrel server，如果执行该操作，需强制重启Kestrel
    RELOAD         动态重新加载配置文件 
    DUMP_CONFIG    dump配置文件 
    FLUSH queueName   flush某个队列 


经测试，支持DELETE协议！

PS:XMemcached-1.2及其以上版本已对其协议完全支持，注意使用KestrelCommandFactory。

当然，Redis也可以做消息队列，但Redis目前只是Master-Slave模式，还不能像Kestrel做到Cluster。所以，如果只是考虑队列服务，还是纯粹一点，直接用Kestrel，配合XMemcached作为客户端，保持一致性哈希，用起来更放心。因为，高可用嘛！呵呵！

想要消化Kestrel，需要做些准备工作：

    kestrel，必须的！这里用kestrel-2.1.7-SNAPSHOT.jar
    daemon，Linux守护进程，这里用daemon-0.6.4 


本想Git下来，逐个编译一把，但始终未果，只好找兄弟copy一份来运行！
我会在附件中，追加相应的配置文件，以及kestrel-2.1.5.jar。

如果你的Server还没有安装Daemon，参考如下操作：
Shell代码  收藏代码

    wget http://libslack.org/daemon/download/daemon-0.6.4.tar.gz  
    tar zxvf daemon-0.6.4.tar.gz  
    cd daemon-0.6.4  
    ./configure && make && make install  



一、Kestrel目录结构
Kestrel目录结构如下：
Kestrel
  |-kestrel-1.2.7-SNAPSHOT.jar
  |-kestrel-1.2.7-SNAPSHOT.pom
  |-config
      |-development.conf
      |-production.conf
  |-libs
  |-scripts
      |-devel.sh
      |-kestrel.sh
      |-qdump.sh

libs中的jar列表：

    configgy-1.6.4.jar     
    naggati_2.7.7-0.7.4.jar 
    slf4j-jdk14-1.5.2.jar   
    twitteractors_2.7.7-2.0.0.jar
    json-1.1.3.jar         
    scala-library.jar       
    specs-1.6.2.1.jar       
    vscaladoc-1.1-md-3.jar
    mina-core-2.0.0-M6.jar 
    slf4j-api-1.5.2.jar     
    twitteractors-1.1.0.jar 
    xrayspecs-1.0.7.jar 


由于附件体积限制，可能需要另行下载（Maven是个好帮手！ ）
我们只需要关注以下几个文件：
适用于开发环境：

    script/devel.sh用于验证服务配置是否可用
    config/development.conf配合devel.sh进行操作的配置文件 



适用于生产环境：

    scripts/kestrel.sh核心执行文件
    config/production.conf核心配置文件 



二、Kestrel脚本&配置说明
这里将Kestrel安装至/opt/servers/kestrel路径下，你可能需要对应修改路径配置。
先说用于开发环境的脚本&配置文件：
devel.sh
引用

#!/bin/bash
APP_NAME="kestrel"
#应用路径
APP_PATH="/opt/servers/kestrel"
#版本
VERSION="1.2.7-SNAPSHOT"

echo "Starting kestrel in development mode..."
java -server -Xmx1024m -Dstage=development -jar $APP_PATH/$APP_NAME-$VERSION.jar

注意修改APP_PATH！

development.conf
引用

# kestrel config for a production system

# where to listen for connections:
port = 22133
host = "0.0.0.0"

log {
  #日志路径
  filename = "/var/logs/kestrel_development.log"
  roll = "daily"
  level = "info"
}

queue_path = "/var/spool/kestrel"


做一个简单的测试：
引用
./scripts/devel.sh
Starting kestrel in development mode...

进行如下操作：
引用

telnet localhost 22133
Trying 127.0.0.1...
Connected to localhost.localdomain (127.0.0.1).
Escape character is '^]'.
set x 0 0 5
12345
STORED

在另一个终端上获得该消息：
引用

telnet localhost 22133
Trying 127.0.0.1...
Connected to localhost.localdomain (127.0.0.1).
Escape character is '^]'.
get x
VALUE x 0 5
12345
END
get x
END

如上操作，说明配置已成功。

如法炮制生产环境配置：
kestrel.sh
引用

APP_NAME="kestrel"
VERSION="1.2.7-SNAPSHOT"
#Kestrel路径
APP_HOME="/opt/servers/$APP_NAME"
AS_USER="daemon"
DAEMON="/usr/local/bin/daemon"
QUEUE_PATH="/var/spool/kestrel"

HEAP_OPTS="-Xmx2048m -Xms1024m -XX:NewSize=256m"
JMX_OPTS="-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=22134 -Dcom.sun.management.jmxremote.authenticate=false
-Dcom.sun.management.jmxremote.ssl=false"
# add JMX_OPTS below if you want jmx support.
#如果需要控制字符集，使用-Dfile.encoding=UTF8
JAVA_OPTS="-server -verbosegc -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintGCDateStamps -XX:+PrintTenuringDistribution -XX:+
UseConcMarkSweepGC -XX:+UseParNewGC $HEAP_OPTS"

你可能需要修改APP_HOME变量


production.conf
引用

# kestrel config for a production system

# where to listen for connections:
port = 22133
#建议绑定主机IP
host = "0.0.0.0"

log {
  filename = "/var/logs/kestrel.log"
  roll = "daily"
  level = "info"
}

#队列存储路径，用于存储/恢复队列消息，建议存放在磁盘较大的区域
queue_path = "/var/spool/kestrel"

建议绑定host，确保服务器安全

可以重复上述测试操作，测试服务是否可用！
或者，直接查看服务状态——STATS！
引用
telnet localhost 22133
Trying 127.0.0.1...
Connected to localhost.localdomain (127.0.0.1).
Escape character is '^]'.
stats
STAT uptime 52568
STAT time 1343093076
STAT version 1.2.7-SNAPSHOT
STAT curr_items 0
STAT total_items 1
STAT bytes 0
STAT curr_connections 1
STAT total_connections 9
STAT cmd_get 2
STAT cmd_set 1
STAT cmd_peek 0
STAT get_hits 1
STAT get_misses 1
STAT bytes_read 91
STAT bytes_written 151
STAT queue_test_items 0
STAT queue_test_bytes 0
STAT queue_test_total_items 1
STAT queue_test_logsize 27
STAT queue_test_expired_items 0
STAT queue_test_mem_items 0
STAT queue_test_mem_bytes 0
STAT queue_test_age 0
STAT queue_test_discarded 0
STAT queue_test_waiters 0
STAT queue_test_open_transactions 0
END

最后，拷贝kestrel.sh文件到/etc/init.d/路径下，并赋予执行权限：
Shell代码  收藏代码

    cp kestrel.sh /etc/init.d/kestrel  
    chmod +x /etc/init.d/kestrel  



后续，我们就可以通过服务方式，调用kestrel了！
引用

service kestrel {start|stop|restart|status}


由于jar文件较大，未在附件内上传外，其余配置文件相见附件！

PS:重点说明一点，队列名称/缓存键名称，一定不要始终“-”作为连接符，请使用“_”作为连接符，避免意想不到的错误。！


