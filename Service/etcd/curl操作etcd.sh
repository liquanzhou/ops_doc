curl操作etcd

https://coreos.com/etcd/docs/0.4.7/etcd-api/


set写数据
curl -L http://127.0.0.1:4001/v2/keys/message -XPUT -d value="Hello world"
curl -L http://127.0.0.1:4001/v2/keys/foo -XPUT -d value=bar -d ttl=5   # 过期

get 取key
curl -L http://127.0.0.1:4001/v2/keys/message

删除key
curl -L http://127.0.0.1:4001/v2/keys/message -XDELETE

等待变化
curl -L http://127.0.0.1:4001/v2/keys/foo?wait=true

递归目录
curl -L http://127.0.0.1:4001/v2/keys/?recursive=true

删除目录
curl -L 'http://127.0.0.1:4001/v2/keys/foo_dir?dir=true' -XDELETE  # 删除空目录
curl -L http://127.0.0.1:4001/v2/keys/dir?recursive=true -XDELETE  # 递归删除目录

获取锁
curl -L http://127.0.0.1:4001/mod/v2/lock/mylock -XPOST -d ttl=20

续订锁
curl -L http://127.0.0.1:4001/mod/v2/lock/mylock -XPUT -d index=5 -d ttl=20

检索锁
curl -L http://127.0.0.1:4001/mod/v2/lock/mylock?field=index

leader统计
curl -L http://127.0.0.1:4001/v2/stats/leader
