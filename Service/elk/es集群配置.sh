

#版本下载
https://www.elastic.co/downloads/past-releases




vim /etc/sysctl.conf
vm.max_map_count = 262144


vim /etc/security/limits.conf
* soft memlock unlimited
* hard memlock unlimited


sysctl -p

/etc/elasticsearch/elasticsearch.yml   # 主配置文件

#bootstrap.memory_lock: true
#bootstrap.mlockall: true
#discovery.zen.minimum_master_nodes: 1
#index.merge.scheduler.max_thread_count: 1
#index.refresh_interval: 3s
cluster.name: anti_cheating
node.name: anti_cheating_node_1
path.data: /data/es/data
path.logs: /data/es/logs
discovery.zen.ping.unicast.hosts: ["172.16.0.225","172.16.0.223"]
network.host: 0.0.0.0



# 调整队列
thread_pool.bulk.queue_size: 1000
thread_pool.get.queue_size: 1000
thread_pool.search.queue_size: 1000
thread_pool.index.queue_size: 1000


/etc/elasticsearch/jvm.options         # 调整内存 两个参数要一致,不然无法启动


mkdir -p /data/es/data /data/es/log
chown -R work.work /data/es /app/elasticsearch-5.6.7


sudo systemctl enable elasticsearch.service

sudo systemctl start elasticsearch.service


# 使用普通用户启动

/app/elasticsearch-5.6.7/bin/elasticsearch -d

vim /etc/rc.local
su - work -c "
/app/elasticsearch-5.6.7/bin/elasticsearch -d
"


supervisor-elasticsearch.conf


[program:elasticsearch]
environment=JAVA_HOME=/usr/local/jdk1.8.0_151
directory=/app/elasticsearch-5.6.7/
command=/app/elasticsearch-5.6.7/bin/elasticsearch
user=work
stopsignal=TERM
stopasgroup=true
autorestart=true
startretries = 3
redirect_stderr=true
stdout_logfile=/data/log/supervisor/elasticsearch.log
stdout_logfile_maxbytes=500MB
stdout_logfile_backups=10
loglevel=info


[program:kibana]
environment=JAVA_HOME=/usr/local/jdk1.8.0_151
directory=/app/kibana-5.6.14-linux-x86_64
command=/app/kibana-5.6.14-linux-x86_64/bin/kibana
user=work
stopsignal=TERM
stopasgroup=true
autorestart=true
startretries = 3
redirect_stderr=true
stdout_logfile=/data/log/supervisor/kibana.log
stdout_logfile_maxbytes=500MB
stdout_logfile_backups=10
loglevel=info




curl '127.0.0.1:9200/_cat/health?v'                    # 健康检查
curl '127.0.0.1:9200/_cat/nodes?v'                     # 获取集群的节点列表
curl '127.0.0.1:9200/_cat/indices?v'                   # 列出所有索引
curl 127.0.0.1:9200/indexname -XDELETE                 # 删除索引
curl -XGET http://127.0.0.1:9200/_cat/shards           # 查看分片
curl '127.0.0.1:9200/_cat/indices'                     # 查分片同步  unassigned_shards  # 没同步完成



# 阿里云带账号密码的的es操作
curl -XGET -u elastic:b7sameEfiu3a  "http://es-cn-mp90lv6.elasticsearch.aliyuncs.com:9200/_cat/indices"
curl -XDELETE -u elastic:b7sarfDiu3a "http://es-cn-mp09lv6.elasticsearch.aliyuncs.com:9200/advert-action"







集群磁盘满了,导致从master主节点接收同步数据的时候失败，此时ES集群为了保护数据，会自动把索引分片index置为只读read-only

PUT _all/_settings
{
   "index": {
     "blocks": {
       "read_only_allow_delete": null
    }
  }
}

等待恢复


如果是4core的，并且ES集群没有业务，可以考虑设置下面这个。

PUT _cluster/settings
{
  "transient" : {
    "indices.recovery.max_bytes_per_sec": "200mb",
    "cluster.routing.allocation.node_concurrent_incoming_recoveries": 20,
    "cluster.routing.allocation.node_concurrent_outgoing_recoveries": 20,
    "cluster.routing.allocation.node_initial_primaries_recoveries": 20
  }
}

----------
如果是4core的，并且ES集群有业务流量过来，可以参考下面这个

PUT _cluster/settings
{
  "transient" : {
    "indices.recovery.max_bytes_per_sec": "100mb",
    "cluster.routing.allocation.node_concurrent_incoming_recoveries": 10,
    "cluster.routing.allocation.node_concurrent_outgoing_recoveries": 10,
    "cluster.routing.allocation.node_initial_primaries_recoveries": 10
  }
}