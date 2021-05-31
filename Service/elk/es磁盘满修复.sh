es磁盘满修复.sh






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



curl -XGET -u elastic:b7sameEdxrfDiu3a  "http://es-cn-mp919e8y500059lv6.elasticsearch.aliyuncs.com:9200/_cat/shards" |grep advert-spark


advert-spark                    4 p STARTED    835169636 948.7gb 172.18.32.72 qdg1QgY
advert-spark                    2 p STARTED    835179787 948.5gb 172.18.32.76 -Ur_O-8
advert-spark                    2 r UNASSIGNED
advert-spark                    3 p UNASSIGNED
advert-spark                    3 r UNASSIGNED

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




单shard太大了，948GB，已经分配不了了。需要强制扩一个节点上来，才能分配上