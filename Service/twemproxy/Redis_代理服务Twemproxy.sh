Redis 代理服务Twemproxy(简介) 2014-04-10 19:03:59
分类： 其他平台
1、twemproxy explore
当我们有大量 Redis 或 Memcached 的时候，通常只能通过客户端的一些数据分配算法（比如一致性哈希），来实现集群存储的特性。虽然Redis 2.6版本已经发布Redis Cluster，但还不是很成熟适用正式生产环境。 Redis 的 Cluster 方案还没有正式推出之前，我们通过 Proxy 的方式来实现集群存储。
Twitter，世界最大的Redis集群之一部署在Twitter用于为用户提供时间轴数据。Twitter Open Source部门提供了Twemproxy。
Twemproxy,也叫nutcraker。是一个twtter开源的一个redis和memcache代理服务器。 redis作为一个高效的缓存服务器，非常具有应用价值。但是当使用比较多的时候，就希望可以通过某种方式 统一进行管理。避免每个应用每个客户端管理连接的松散性。同时在一定程度上变得可以控制。
Twemproxy是一个快速的单线程代理程序，支持Memcached ASCII协议和更新的Redis协议：
它全部用C写成，使用Apache 2.0 License授权。项目在Linux上可以工作，而在OSX上无法编译，因为它依赖了epoll API.
Twemproxy 通过引入一个代理层，可以将其后端的多台 Redis 或 Memcached 实例进行统一管理与分配，使应用程序只需要在 Twemproxy 上进行操作，而不用关心后面具体有多少个真实的 Redis 或 Memcached 存储。
2、twemproxy特性：
支持失败节点自动删除
可以设置重新连接该节点的时间
可以设置连接多少次之后删除该节点
该方式适合作为cache存储
支持设置HashTag
通过HashTag可以自己设定将两个KEYhash到同一个实例上去。
减少与redis的直接连接数
保持与redis的长连接
可设置代理与后台每个redis连接的数目
自动分片到后端多个redis实例上
多种hash算法：能够使用不同的策略和散列函数支持一致性hash。
可以设置后端实例的权重
避免单点问题
可以平行部署多个代理层.client自动选择可用的一个
支持redis pipelining request
支持请求的流式与批处理，降低来回的消耗
支持状态监控
可设置状态监控ip和端口，访问ip和端口可以得到一个json格式的状态信息串
可设置监控信息刷新间隔时间
高吞吐量
连接复用，内存复用。
将多个连接请求，组成reids pipelining统一向redis请求。
另外可以修改redis的源代码，抽取出redis中的前半部分，作为一个中间代理层。最终都是通过linux下的epoll 事件机制提高并发效率，其中nutcraker本身也是使用epoll的事件机制。并且在性能测试上的表现非常出色。
3、twemproxy问题与不足
Twemproxy 由于其自身原理限制，有一些不足之处，如：
不支持针对多个值的操作，比如取sets的子交并补等（MGET 和 DEL 除外）
不支持Redis的事务操作
出错提示还不够完善
也不支持select操作
4、安装与配置 
具体的安装步骤可用查看github：https://github.com/twitter/twemproxy
Twemproxy 的安装，主要命令如下：
apt-get install automake
apt-get install libtool
git clone git://github.com/twitter/twemproxy.git
cd twemproxy
autoreconf -fvi
./configure --enable-debug=log
make
src/nutcracker -h
通过上面的命令就算安装好了，然后是具体的配置，下面是一个典型的配置
redis1:
  listen: 127.0.0.1:6379 #使用哪个端口启动Twemproxy
  redis: true #是否是Redis的proxy
  hash: fnv1a_64 #指定具体的hash函数
  distribution: ketama #具体的hash算法
  auto_eject_hosts: true #是否在结点无法响应的时候临时摘除结点
  timeout: 400 #超时时间（毫秒）
  server_retry_timeout: 2000 #重试的时间（毫秒）
  server_failure_limit: 1 #结点故障多少次就算摘除掉
  servers: #下面表示所有的Redis节点（IP:端口号:权重）
  - 127.0.0.1:6380:1
  - 127.0.0.1:6381:1
  - 127.0.0.1:6382:1
redis2:
  listen: 0.0.0.0:10000
  redis: true
  hash: fnv1a_64
  distribution: ketama
  auto_eject_hosts: false
  timeout: 400
  servers:
  - 127.0.0.1:6379:1
  - 127.0.0.1:6380:1
  - 127.0.0.1:6381:1
  - 127.0.0.1:6382:1
你可以同时开启多个 Twemproxy 实例，它们都可以进行读写，这样你的应用程序就可以完全避免所谓的单点故障。