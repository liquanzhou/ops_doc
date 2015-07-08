
twemproxy学习  


twemproxy可以用在memcached和redis的代理。
安装

$ ./configure
$ make
$ sudo make install

调试模式

$ CFLAGS="-ggdb3 -O0" ./configure --enable-debug=full


配置文件
一般位于conf/nutcracker.yml 

redis-for-tl:
listen: ip:22121

redis: true
hash: fnv1a_64
distribution: ketama
timeout: 400
auto_eject_hosts: false
preconnect: true
servers:
- ip:7001:1 name-1
- ip:7002:1 name-2


memcached-for-timeline:
listen: ip:22122
redis: false
hash: fnv1a_64
distribution: modula
timeout: 400
auto_eject_hosts: false
preconnect: true
servers:
- ip:11213:1 name1
- ip:11213:1 name2


启动
./bin/nutcracker --conf-file=./conf/n2.yml --stats-port=22554 -d

通过http访问统计
 curl "http://127.17.1.163:22554"

日志级别
LOG_INFO (-v 6 or --verbosity=6)，在 config时指定 --enable-debug=log 

resilient_pool:
  auto_eject_hosts: true
  server_retry_timeout: 30000
  server_failure_limit: 3

auto _eject_hosts为true 表示在 连续sever_failure_limit 次失败后，那台server会被剔除。server_retry_timeout表示
直到这个时间过去后，剔除的server才会被包含到哈希环中。这会导致原来分布到剔除server的key被分布到幸存的server。
如果想要确保请求总是成功，则客户端需要进行重试。重试次数必须大于server_retyr_timeout。
timeout值的配置可以确保proxy到server的链接能被关闭。

Mbuf
mbuf可以配置 512-65k，缺省16k（--mbuf-size=N）。并发连接数取决于mbuf大小。mbuf小允许的连接数多，mbuf大则允许从内核socket buffer读写更多数据。需要处理的并发连接多，则配512或1k。

节点名用于一致性哈希

servers:
 - 127.0.0.1:6379:1
 - 127.0.0.1:6380:1
 - 127.0.0.1:6381:1
 - 127.0.0.1:6382:1

Or,

servers:
 - 127.0.0.1:6379:1 server1
 - 127.0.0.1:6380:1 server2
 - 127.0.0.1:6381:1 server3
 - 127.0.0.1:6382:1 server4

前者将key直接映射到 host:port:weight。后者将key映射到 node name，node name再映射到 host:port:weight。这允许我们重新分配节点而不破坏哈希环当auto_eject_host为false。当使用node name映射时，权重被忽略。