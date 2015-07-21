Kafka安装配置


kafka下载：https://www.apache.org/dyn/closer.cgi?path=/kafka/0.8.1/kafka_2.10-0.8.1.tgz
分别在三台服务器上安装kafka：
tar zxvf kafka_2.10-0.8.1.tgz

修改每台服务器的 config/server.properties 
broker.id:   # 唯一，填数字，本文中分别为132/133/134
host.name:   # 唯一，填服务器IP，之前配置时，把中间的'.'给忘写了，导致kafka集群形同虚设（基本只有leader机器在起作用），以及一系列莫名其妙的问题，伤啊

zookeeper.connect=192.168.40.134:2181,192.168.40.132:2181,192.168.40.133:2181
# 一组zookeeper只能被一组kafka使用，但zookeeper同时还可以让其他服务使用，增加删除节点，不影响

先启动zookeeper服务:   bin/zkServer.sh start   (本文中zookeeper为独立安装，具体过程在此不细述)
再在每台机器上执行：   bin/kafka-server-start.sh config/server.properties  


# kafka配置注意
# 需要配置较大 分片影响读写速度
num.partitions=64

# 数据目录也要单独配置磁盘较大的地方
log.dirs=/data/kafka-logs

# 时间按需求保留过期时间 避免磁盘满
log.retention.hours=168



# 后台启动   
nohup bin/kafka-server-start.sh /opt/kafka/config/server.properties &  
# 注意 kafka如果有问题 nohup的日志文件会非常大,把磁盘占满


创建topic
bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 3 --partitions 1 --topic mykafka

查看Topic
bin/kafka-topics.sh --list --zookeeper localhost:2181
显示Topic：mykafka

查看详细信息
bin/kafktopics.sh --describe --zookeeper 192.168.40.132:2181

  Topic:mykafka	PartitionCount:1	ReplicationFactor:3	Configs:
  Topic: mykafka	Partition: 0	Leader: 133	Replicas: 133,134,132	Isr: 134

发送消息
bin/kafka-console-producer.sh --broker-list 192.168.40.134:9092 --topic mykafka
23423

bin/kafka-console-producer.sh --brokelist 192.168.40.134:9092 --topic mykafka
4533


如果出现以下信息，则需要下载slftj-nop-1.5.jar，并将其cp至kafka的libs目录下：
[plain] view plaincopyprint?在CODE上查看代码片派生到我的代码片
<span style="font-family:Microsoft YaHei;font-size:14px;">SLF4J: Failed to load class "org.slf4j.impl.StaticLoggerBinder".  
SLF4J: Defaulting to no-operation (NOP) logger implementation  
SLF4J: See http://www.slf4j.org/codes.html#StaticLoggerBinder for further details. </span>  


接收消息
bin/kafka-console-consumer.sh --zookeeper 192.168.40.133:2181 --topic mykafka --from-beginning



停止应执行脚本(传递ctrl+c的信号),这样加载避免检测错误,加载快
sh bin/kafka-server-stop.sh


# kafka插件

# the host of the StatsD server (localhost)
external.kafka.statsd.host=10.10.76.71

# the port of the StatsD server (8125)
external.kafka.statsd.port=8125

./statsdaemon -address=10.10.76.71:8125 -graphite=10.10.76.42:2003 -opentsdb=10.13.80.115:4243


tail -f nohup.out
# 在重启kafka8集群中的单台 如果有持续如下提示警告[几条很快过去的可忽略], 需要先停掉整个集群, 在全部启动.
# 正常日志启动过程应该是 先加载数据,在一直输入提示关闭链接
[2015-07-08 04:30:26,582] WARN [Kafka-91] Produce request with correlation id 25970079 from client rdkafka on partition [msg,24] failed due to Topic push-broker-msg either doesnt exist or is in the process of being deleted (kafka.server.KafkaApis)
[2015-07-08 04:30:26,582] WARN [Kafka-91] Fetch request with correlation id 12 from client syn.recNews.clienttorec.topic.group.kafka8.ads-ConsumerFetcherThread-syn.recNews.clienttorec.topic.group.kafka8.ads_yd-33-177-1429496275939-a7b49c84-0-91 on partition [test.syn.recNews.clienttorec.topic,5] failed due to Topic test.syn.recNews.clienttorec.topic either doesnt exist or is in the process of being deleted (kafka.server.KafkaApis)





