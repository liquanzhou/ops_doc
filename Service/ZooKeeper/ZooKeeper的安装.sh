 ZooKeeper系列之三：ZooKeeper的安装

 http://blog.csdn.net/shenlan211314/article/details/6185171

ZooKeeper的安装模式分为三种，分别为：单机模式（stand-alone）、集群模式和集群伪分布模式。ZooKeeper 单机模式的安装相对比较简单，如果第一次接触ZooKeeper的话，建议安装ZooKeeper单机模式或者集群伪分布模式。

# Exhibitor 是 ZooKeeper 实例监控，备份，恢复，清理和可视化工具， 是 ZooKeeper 的监控管理系统。
http://www.oschina.net/p/%E2%80%8Bexhibitor
# 解压后台启动 就可以用 
http://ip:8088/exhibitor/v1/ui/index.html


clientPort=2181
maxClientCnxns=1024

tickTime=2000
initLimit=20
syncLimit=10

dataDir=/opt/zookeeper/data
dataLogDir=/opt/zookeeper/log

server.0=10.10.94.51:2888:3888
server.1=10.10.94.52:2888:3888
server.2=10.10.94.53:2888:3888

 

1）单机模式

 

首先，从Apache官方网站下载一个ZooKeeper 的最近稳定版本。


http://hadoop.apache.org/zookeeper/releases.html

 

作为国内用户来说，选择最近的的源文件服务器所在地，能够节省不少的时间。


http://labs.renren.com/apache-mirror//hadoop/zookeeper/

 

ZooKeeper 要求 JAVA 的环境才能运行，并且需要 JAVA6 以上的版本，可以从 SUN 官网上下载，并对 JAVA 环境变量进行设置。除此之外，为了今后操作的方便，我们需要对 ZooKeeper 的环境变量进行配置，方法如下，在 /etc/profile 文件中加入如下的内容：

 

#Set ZooKeeper Enviroment

export ZOOKEEPER_HOME=/root/hadoop-0.20.2/zookeeper-3.3.1

export PATH=$PATH:$ZOOKEEPER_HOME/bin:$ZOOKEEPER_HOME/conf

 

ZooKeeper 服务器包含在单个 JAR 文件中，安装此服务需要用户创建一个配置文档，并对其进行设置。我们在 ZooKeeper-*.*.* 目录（我们以当前 ZooKeeper 的最新版 3.3.1 为例，故此下面的“ ZooKeeper-*.*.* ”都将写为“ ZooKeeper-3.3.1” ）的 conf 文件夹下创建一个 zoo.cfg 文件，它包含如下的内容：


tickTime=2000

dataDir=/var/zookeeper

clientPort=2181

 

在这个文件中，我们需要指定 dataDir 的值，它指向了一个目录，这个目录在开始的时候需要为空。下面是每个参数的含义：

 

tickTime ：基本事件单元，以毫秒为单位。它用来指示心跳，最小的 session 过期时间为两倍的 tickTime. 。

dataDir ：存储内存中数据库快照的位置，如果不设置参数，更新事务日志将被存储到默认位置。

clientPort ：监听客户端连接的端口

 

使用单机模式时用户需要注意：这种配置方式下没有 ZooKeeper 副本，所以如果 ZooKeeper 服务器出现故障， ZooKeeper 服务将会停止。


以下代码清单 A 是我们的根据自身情况所设置的 zookeeper 配置文档： zoo.cfg

代码清单 A ： zoo.cfg

# The number of milliseconds of each tick

tickTime=2000

 

# the directory where the snapshot is stored.

dataDir=/root/hadoop-0.20.2/zookeeper-3.3.1/snapshot/data

 

# the port at which the clients will connect

clientPort=2181

 

2）集群模式

 

为了获得可靠的 ZooKeeper 服务，用户应该在一个集群上部署 ZooKeeper 。只要集群上大多数的 ZooKeeper 服务启动了，那么总的 ZooKeeper 服务将是可用的。另外，最好使用奇数台机器。 如果 zookeeper 拥有 5 台机器，那么它就能处理 2 台机器的故障了。


之后的操作和单机模式的安装类似，我们同样需要对 JAVA 环境进行设置，下载最新的 ZooKeeper 稳定版本并配置相应的环境变量。不同之处在于每台机器上 conf/zoo.cfg 配置文件的参数设置，参考下面的配置：


tickTime=2000

dataDir=/var/zookeeper/

clientPort=2181

initLimit=5

syncLimit=2

server.1=zoo1:2888:3888

server.2=zoo2:2888:3888

server.3=zoo3:2888:3888

 

“ server.id=host:port:port. ”指示了不同的 ZooKeeper 服务器的自身标识，作为集群的一部分的机器应该知道 ensemble 中的其它机器。用户可以从“ server.id=host:port:port. ”中读取相关的信息。 在服务器的 data （ dataDir 参数所指定的目录）目录下创建一个文件名为 myid 的文件，这个文件中仅含有一行的内容，指定的是自身的 id 值。比如，服务器“ 1 ”应该在 myid 文件中写入“ 1 ”。这个 id 值必须是 ensemble 中唯一的，且大小在 1 到 255 之间。这一行配置中，第一个端口（ port ）是从（ follower ）机器连接到主（ leader ）机器的端口，第二个端口是用来进行 leader 选举的端口。在这个例子中，每台机器使用三个端口，分别是： clientPort ， 2181 ； port ， 2888 ； port ， 3888 。


我们在拥有三台机器的 Hadoop 集群上测试使用 ZooKeeper 服务，下面代码清单 B 是我们根据自身情况所设置的 ZooKeeper 配置文档：

代码清单 B ： zoo.cfg

# The number of milliseconds of each tick

tickTime=2000

 

# The number of ticks that the initial

# synchronization phase can take

initLimit=10

 

# The number of ticks that can pass between

# sending a request and getting an acknowledgement

syncLimit=5

 

# the directory where the snapshot is stored.

dataDir=/root/hadoop-0.20.2/zookeeper-3.3.1/snapshot/d1

 

# the port at which the clients will connect

clientPort=2181

 

server.1=IP1:2887:3887

server.2=IP2:2888:3888

server.3=IP3:2889:3889

 

清单中的 IP 分别对应的配置分布式 ZooKeeper 的 IP 地址。当然，也可以通过机器名访问 zookeeper ，但是需要在 ubuntu 的 hosts 环境中进行设置。读者可以查阅 Ubuntu 以及 Linux 的相关资料进行设置。

 

3)集群伪分布

 

 

简单来说，集群伪分布模式就是在单机下模拟集群的ZooKeeper服务。

 

那么，如何对配置 ZooKeeper 的集群伪分布模式呢？其实很简单，在 zookeeper 配置文档中， clientPort 参数用来设置客户端连接 zookeeper 的端口。 server.1=IP1:2887:3887 中， IP1 指示的是组成 ZooKeeper 服务的机器 IP 地址， 2887 为用来进行 leader 选举的端口， 3887 为组成 ZooKeeper 服务的机器之间通信的端口。集群伪分布模式我们使用每个配置文档模拟一台机器，也就是说，需要在单台机器上运行多个 zookeeper 实例。但是，我们必须要保证各个配置文档的 clientPort 不能冲突。


下面是我们所配置的集群伪分布模式，通过 zoo1.cfg ， zoo2.cfg ， zoo3.cfg 模拟了三台机器的 ZooKeeper 集群。详见代码清单 C ：

代码清单C ： zoo1.cfg ：

# The number of milliseconds of each tick

tickTime=2000

 

# The number of ticks that the initial

# synchronization phase can take

initLimit=10

 

# The number of ticks that can pass between

# sending a request and getting an acknowledgement

syncLimit=5

 

# the directory where the snapshot is stored.

dataDir=/root/hadoop-0.20.2/zookeeper-3.3.1/d_1

 

# the port at which the clients will connect

clientPort=2181

 

server.1=localhost:2887:3887

server.2=localhost:2888:3888

server.3=localhost:2889:3889

zoo2.cfg ：

# The number of milliseconds of each tick

tickTime=2000

 

# The number of ticks that the initial

# synchronization phase can take

initLimit=10

 

# The number of ticks that can pass between

# sending a request and getting an acknowledgement

syncLimit=5

 

# the directory where the snapshot is stored.

dataDir=/root/hadoop-0.20.2/zookeeper-3.3.1/d_2

 

# the port at which the clients will connect

clientPort=2182

 

#the location of the log file

dataLogDir=/root/hadoop-0.20.2/zookeeper-3.3.1/logs

 

server.1=localhost:2887:3887 

server.2=localhost:2888:3888

server.3=localhost:2889:3889

 

zoo3.cfg ：

# The number of milliseconds of each tick

tickTime=2000

 

# The number of ticks that the initial

# synchronization phase can take

initLimit=10

 

# The number of ticks that can pass between

# sending a request and getting an acknowledgement

syncLimit=5

 

# the directory where the snapshot is stored.

dataDir=/root/hadoop-0.20.2/zookeeper-3.3.1/d_2

 

# the port at which the clients will connect

clientPort=2183

 

#the location of the log file

dataLogDir=/root/hadoop-0.20.2/zookeeper-3.3.1/logs

 

server.1=localhost:2887:3887 

server.2=localhost:2888:3888

server.3=localhost:2889:3889

 

从上述三个代码清单中可以看到，除了 clientPort 不同之外， dataDir 也不同。另外，不要忘记在 dataDir 所对应的目录中创建 myid 文件来指定对应的 zookeeper 服务器实例。

 

这里ZooKeeper的安装已经说完了，下一节我们来谈一谈对ZooKeeper的参数配置 的理解。

 

-----

如有疑问请发Email至shenlan211314@gmail.com，谢谢！




测试配置

tickTime=2000
initLimit=10
syncLimit=5
dataDir=/data/zookeeper/zookeeper-3.4.3/data
clientPort=2181
#autopurge.purgeInterval=1
server.0=127.0.0.1:2688:2688
server.1=127.0.0.1:2689:2689
server.2=127.0.0.1:2690:2690
server.3=127.0.0.1:2691:2691



当启动 ZooKeeper 服务成功之后，输入下述命令，连接到 ZooKeeper 服务：
zkCli.sh –server 10.77.20.23:2181
连接成功后，系统会输出 ZooKeeper 的相关环境以及配置信息，并在屏幕输出“ Welcome to ZooKeeper ”等信息。
输入 help 之后，屏幕会输出可用的 ZooKeeper 命令



ZooKeeper的简单操作


1 ）使用 ls 命令来查看当前 ZooKeeper 中所包含的内容：
[zk: 10.77.20.23:2181(CONNECTED) 1] ls /
[zookeeper]

2 ）创建一个新的 znode ，使用 create /zk myData 。这个命令创建了一个新的 znode 节点“ zk ”以及与它关联的字符串：
[zk: 10.77.20.23:2181(CONNECTED) 2] create /zk myData
Created /zk

3 ）再次使用 ls 命令来查看现在 zookeeper 中所包含的内容：
[zk: 10.77.20.23:2181(CONNECTED) 3] ls /
[zk, zookeeper]

此时看到， zk 节点已经被创建。

4 ）下面我们运行 get 命令来确认第二步中所创建的 znode 是否包含我们所创建的字符串：
[zk: 10.77.20.23:2181(CONNECTED) 4] get /zk
myData
Zxid = 0x40000000c
time = Tue Jan 18 18:48:39 CST 2011
Zxid = 0x40000000c
mtime = Tue Jan 18 18:48:39 CST 2011
pZxid = 0x40000000c
cversion = 0
dataVersion = 0
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 6
numChildren = 0

5 ）下面我们通过 set 命令来对 zk 所关联的字符串进行设置：
[zk: 10.77.20.23:2181(CONNECTED) 5] set /zk shenlan211314
cZxid = 0x40000000c
ctime = Tue Jan 18 18:48:39 CST 2011
mZxid = 0x40000000d
mtime = Tue Jan 18 18:52:11 CST 2011
pZxid = 0x40000000c
cversion = 0
dataVersion = 1
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 13
numChildren = 0

6 ）下面我们将刚才创建的 znode 删除：
[zk: 10.77.20.23:2181(CONNECTED) 6] delete /zk

7 ）最后再次使用 ls 命令查看 ZooKeeper 所包含的内容：
[zk: 10.77.20.23:2181(CONNECTED) 7] ls /
[zookeeper]

经过验证， zk 节点已经被删除。



# 注意 myid文件里面的数字要和 zoo.conf里面配置的当前server的.几对应  
/opt/zookeeper/data/myid
