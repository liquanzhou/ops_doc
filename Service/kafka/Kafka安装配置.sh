Kafka安装配置


kafka下载：https://www.apache.org/dyn/closer.cgi?path=/kafka/0.8.1/kafka_2.10-0.8.1.tgz
分别在三台服务器上安装kafka：

# 尽量安装个高版本的kafka,有删除topic的功能,配置上也更多支持一些参数

tar zxvf kafka_2.10-0.8.1.tgz

修改每台服务器的 config/server.properties 
broker.id:   # 唯一，填数字，本文中分别为132/133/134
#host.name:   # 唯一，填服务器IP，之前配置时，把中间的'.'给忘写了，导致kafka集群形同虚设（基本只有leader机器在起作用），以及一系列莫名其妙的问题，伤啊

advertised.listeners=PLAINTEXT://-kafka01:9092  # 0.9以后的参数,不加无法写数据


zookeeper.connect=192.168.40.134:2181,192.168.40.132:2181,192.168.40.133:2181
# 一组zookeeper只能被一组kafka使用，但zookeeper同时还可以让其他服务使用，增加删除节点，不影响

先启动zookeeper服务:   bin/zkServer.sh start   (本文中zookeeper为独立安装，具体过程在此不细述)
再在每台机器上执行：   bin/kafka-server-start.sh config/server.properties  


https://kafka.apache.org/documentation.html

# kafka配置注意

# broker处理消息的最大线程数，一般情况下不需要去修改
num.network.threads =4

# broker处理磁盘IO的线程数，数值应该大于你的硬盘数
num.io.threads =8

# 一些后台任务处理的线程数，例如过期消息文件的删除等，一般情况下不需要去做修改
# background.threads =4

# 等待IO线程处理的请求队列最大数，若是等待IO的请求超过这个数值，那么会停止接受外部消息，应该是一种自我保护机制。
# queued.max.requests =500


# 需要配置较大 分片影响并发读写速度
num.partitions=64

# 数据目录也要单独配置磁盘较大的地方
log.dirs=/data/kafka-logs

# 时间按需求保留过期时间 避免磁盘满
log.retention.hours=96

# 是否允许自动创建topic，允许自动创建为true，不允许自动创建为false，就需要通过命令创建topic
auto.create.topics.enable=true
# 最好禁止自动创建,有可能遇到不能创建的情况






-----------------------------------------------------

broker.id=1
listeners=PLAINTEXT://172.20.81.72:9092
num.network.threads=3
num.io.threads=8
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600
log.dirs=/data1/kafka-logs
#log.dirs=/data/data/kafka,/data02/kafka,/data03/kafka,/data04/kafka
num.partitions=16
num.recovery.threads.per.data.dir=1
offsets.topic.replication.factor=2
transaction.state.log.replication.factor=2
transaction.state.log.min.isr=1
log.retention.hours=100
log.segment.bytes=1073741824
log.retention.check.interval.ms=300000
zookeeper.connect=172.20.81.72:2181,172.20.81.73:2181,172.20.81.74:2181
zookeeper.connection.timeout.ms=6000
group.initial.rebalance.delay.ms=0

-----------------------------------------------------

# 启动服务
vim /data/kafka_2.12-1.1.0/start.sh
/data/kafka_2.12-1.1.0/bin/kafka-server-start.sh -daemon /data/kafka_2.12-1.1.0/config/server.properties




[program:kafka]
directory=/app/kafka-2.12/
environment=JAVA_HOME=/usr/local/jdk1.8.0_151/
command=/app/kafka-2.12/bin/kafka-server-start.sh  /app/kafka-2.12/config/server.properties
user=root
stopsignal=TERM
stopasgroup=true
autorestart=true
startretries = 3
redirect_stderr=true
stdout_logfile=/data/log/supervisor/kafka.log
stdout_logfile_maxbytes=50MB
stdout_logfile_backups=10
loglevel=info


[program:zookeeper]
directory=/app/zookeeper-3.5.5/
environment=JAVA_HOME=/usr/local/jdk1.8.0_151/
command=/app/zookeeper-3.5.5/bin/zkServer.sh start-foreground
user=root
stopsignal=TERM
stopasgroup=true
autorestart=true
startretries = 3
redirect_stderr=true
stdout_logfile=/data/log/supervisor/zookeeper.log
stdout_logfile_maxbytes=50MB
stdout_logfile_backups=10
loglevel=info


# 创建topic
./kafka-topics.sh --create --zookeeper 127.0.0.1:2181 --replication-factor 3 --partitions 32 --topic mykafka

# 查看Topic
./kafka-topics.sh --list --zookeeper 127.0.0.1:2181
显示Topic： mykafka

# 查看详细信息
./kafka-topics.sh --describe --zookeeper 127.0.0.1:2181

  Topic:mykafka	PartitionCount:1	ReplicationFactor:3	Configs:
  Topic: mykafka	Partition: 0	Leader: 133	Replicas: 133,134,132	Isr: 134


# 获取 group 列表
./kafka-consumer-groups.sh --bootstrap-server 127.0.0.1:9092 --list

KMOffsetCache-sh-inf-manager01.in.izuiyou.com
im-consumer

# 查看group每个线程消费信息
./kafka-consumer-groups.sh --bootstrap-server 127.0.0.1:9092 --describe --group im-consumer
TOPIC            PARTITION  CURRENT-OFFSET  LOG-END-OFFSET  LAG             CONSUMER-ID                                 HOST            CLIENT-ID
im_status 11         2915479         2915481         2               sarama-fe61af2d-a76a-4049-9d74-b017277f96a1 /172.16.2.72    sarama



# 发送消息
./kafka-console-producer.sh --broker-list 172.20.82.5:9092 --topic mykafka




如果出现以下信息，则需要下载slftj-nop-1.5.jar，并将其cp至kafka的libs目录下：
[plain] view plaincopyprint?在CODE上查看代码片派生到我的代码片
<span style="font-family:Microsoft YaHei;font-size:14px;">SLF4J: Failed to load class "org.slf4j.impl.StaticLoggerBinder".  
SLF4J: Defaulting to no-operation (NOP) logger implementation  
SLF4J: See http://www.slf4j.org/codes.html#StaticLoggerBinder for further details. </span>  


# 接收消息  --from-beginning 从头
./kafka-console-consumer.sh --bootstrap-server 127.0.0.1:9092 --topic mykafka --from-beginning


# 修改group offsets 位置 到最新的
./kafka-consumer-groups.sh --bootstrap-server 127.0.0.1:9092 --group sensor_consumer_test --topic sensor_stream_test --reset-offsets --to-latest --execute

# 0.8.2以后加的删除topic
./kafka-topics.sh --zookeeper 127.0.0.1:2181 --delete --topic mykafka_test1


# 停止应执行脚本(传递ctrl+c的信号),这样加载避免检测错误,加载快
sh kafka-server-stop.sh




















# 这个错误可能因为zookeeper信息错误导致的,新创建topic写数据一直报错, 最后把集群全部关闭后重启恢复

WARN Error while fetching metadata [{TopicMetadata for topic mykafka_test -> 
No partition metadata for topic mykafka_test due to kafka.common.LeaderNotAvailableException}] for topic [mykafka_test]: class kafka.common.LeaderNotAvailableException  (kafka.producer.BrokerPartitionInfo)
[2015-07-27 16:47:24,130] ERROR Failed to collate messages by topic, partition due to: Failed to fetch topic metadata for topic: mykafka_test (kafka.producer.async.DefaultEventHandler)





# 无法创建topic 可能是zookeeper信息出问题, 建议删除topic 重启zookeeper和kafka集群  
No partition metadata for topic mykafka_test2 due to kafka.common.LeaderNotAvailableException}] for topic [mykafka_test2]: class kafka.common.LeaderNotAvailableException 
07-28 10:35:15  ERROR - Failed to send requests for topics mykafka_test2 with correlation ids in [0,8]




