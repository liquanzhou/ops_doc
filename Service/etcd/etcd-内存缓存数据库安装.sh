
etcd-K/V数据库安装

用于服务发现的键值存储系统


# etcd：从应用场景到实现原理的全方位解读
https://linux.cn/article-4810-1.html


Etcd是一个高可用的 Key/Value 存储系统，主要用于分享配置和服务发现。
简单：支持 curl 方式的用户 API (HTTP+JSON)
安全：可选 SSL 客户端证书认证
快速：单实例可达每秒 1000 次写操作
可靠：使用 Raft 实现分布式


https://github.com/coreos/etcd/

二进制包下载
https://github.com/coreos/etcd/releases/


curl -L  https://github.com/coreos/etcd/releases/download/v2.3.3/etcd-v2.3.3-linux-amd64.tar.gz -o etcd-v2.3.3-linux-amd64.tar.gz
tar xzvf etcd-v2.3.3-linux-amd64.tar.gz
cd etcd-v2.3.3-linux-amd64
./etcd

# cp etcd* /bin/
# etcd -version



#!/bin/sh

ETCD_INITIAL_CLUSTER="infra0=http://10.10.10.117:2380,infra1=http://10.10.10.118:2380,infra2=http://10.10.10.119:2380"
ETCD_INITIAL_CLUSTER_STATE=new

nohup ./etcd -name infra1 -initial-advertise-peer-urls http://10.10.10.118:2380 \
  -listen-peer-urls http://10.10.10.118:2380 \
  -listen-client-urls http://10.10.10.118:2379,http://127.0.0.1:2379 \
  -advertise-client-urls http://10.10.10.118:2379 \
  -initial-cluster-token etcd-cluster-1 \
  -initial-cluster infra0=http://10.10.10.117:2380,infra1=http://10.10.10.118:2380,infra2=http://10.10.10.119:2380 \
  -initial-cluster-state new  &




简单操作


curl -L http://127.0.0.1:4001/v2/keys/mykey -XPUT -d value="this is awesome"
curl -L http://127.0.0.1:4001/v2/keys/mykey


letong@me:~$ curl -L http://192.168.0.123:4001/v2/keys/lekey -XPUT -d value=”this is key”  #添加
{“action”:”set”,”node”:{“key”:”/lekey”,”value”:”this is key”,”modifiedIndex”:4,”createdIndex”:4}}

letong@me:~$ curl -L http://192.168.0.123:4001/v2/keys/lekey #查询
{“action”:”get”,”node”:{“key”:”/lekey”,”value”:”this is key”,”modifiedIndex”:4,”createdIndex”:4}}

letong@me:~$ curl -L http://192.168.0.123:4001/v2/keys/lekey -XDELETE #删除
{“action”:”delete”,”node”:{“key”:”/lekey”,”modifiedIndex”:5,”createdIndex”:4},”prevNode”:{“key”:”/lekey”,”value”:”this is key”,”modifiedIndex”:4,”createdIndex”:4}}
