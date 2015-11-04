Kafka安装

安装kafka

下载：http://people.apache.org/~nehanarkhede/kafka-0.7.0-incubating/kafka-0.7.0-incubating-src.tar.gz


> tar xzf kafka-0.7.0-incubating-src.tar.gz

> cd kafka-0.7.0-incubating-src

> ./sbt update

> ./sbt package

启动zkserver:

bin/zookeeper-server-start.sh config/zookeeper.properties

启动server:

bin/kafka-server-start.sh config/server.properties
# 后台启动   
nohup bin/kafka-server-start.sh /opt/kafka/config/server.properties &  