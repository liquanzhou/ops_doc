


nginx --> filebeat-6.5.1 --> kafka --> logstash-6.5.1 --> elasticsearch --> kibana




    log_format main '{ '
        '"@timestamp": "$time_iso8601",'
        '"nginx": "$hostname",'
        '"x_forwarded_for": "$http_x_forwarded_for",'
        '"remote_addr": "$remote_addr",'
        '"method": "$request_method",'
        '"status": $status,'
        '"host": "$host",'
        '"request": "$request_uri",'
        '"upstream": "$upstream_addr",'
        '"uri": "$uri",'
        '"scheme": "$scheme",'
        '"request_length": $request_length,'
        '"request_time": $request_time,'
        '"response_time": "$upstream_response_time",'
        '"body_bytes_sent": $body_bytes_sent,'
        '"user_agent": "$http_user_agent",'
        '"xc-src-name": "$http_xc_src_name",'
        '"referer": "$http_referer"'
        '}';


https://es-cn-v0h0p52fm000akje5.kibana.elasticsearch.aliyuncs.com:5601/app/kibana#/discover?_g=(refreshInterval:(display:Off,pause:!f,value:0),time:(from:now-30m,mode:quick,to:now))&_a=(columns:!(status,http_upstream,http_user_agent,request),index:'logstash-*',interval:auto,query:(query_string:(analyze_wildcard:!t,query:'-status:%20500')),sort:!('@timestamp',desc))




/opt/filebeat-6.5.1-linux-x86_64/filebeat.yml
#==========================================================================================================
filebeat.inputs:

- type: log
  enabled: true
  paths:
    - /app/nginx/logs/opapi_access.log
    - /app/nginx/logs/*_access.log

filebeat.config.modules:
  path: ${path.config}/modules.d/*.yml

  reload.enabled: false

setup.template.settings:
  index.number_of_shards: 3

output.kafka:
  # initial brokers for reading cluster metadata
  hosts: ["172.16.0.155:9092", "172.16.0.154:9092", "172.16.0.156:9092"]

  # message topic selection + partitioning
  topic: 'filebeatnginx'
  partition.round_robin:
    reachable_only: false

  required_acks: 1
  compression: gzip
  max_message_bytes: 1000000
  codec.format:
      string: '%{[message]}'

#==========================================================================================================


/opt/filebeat-6.5.1-linux-x86_64/filebeat -c /opt/filebeat-6.5.1-linux-x86_64/filebeat.yml -e





/opt/logstash-6.5.1/config/kafka-logstash-es.conf

#==========================================================================================================

input {
    kafka {
        bootstrap_servers => "172.16.0.155:9092,172.16.0.154:9092,172.16.0.156:9092"
        group_id => "logstash-dmz-nginxlog"
        topics => ["filebeatnginx"]
        codec => json
        consumer_threads => 4
        auto_offset_reset => latest
        #consumer_threads => 2
        #queue_size => 500
    }
}

filter {
    mutate { gsub => [ "message", "\\x", "\\\x" ] }
    json {
        source => "message"
    }
}


output {
    elasticsearch {
        hosts => ["es-cn-v0h0p52fm0elasticsearch.aliyuncs.com:9200"]
        user => "logstash"
        password => "b7sameEdxr3a"
        index => "nginxlog-%{+YYYY-MM-dd}"
        http_compression => true
    }
}


#==========================================================================================================


# 阿里云需要开启 自动创建索引, 并且在 kibana6 创建用户, 创建用户对应索引名称
https://help.aliyun.com/document_detail/63423.html?spm=5176.11065259.1996646101.searchclickresult.209e66d9mJ0T4j










[program:filebeat]
environment=HOME=/home/work
command=/opt/filebeat-6.5.1-linux-x86_64/filebeat -c /opt/filebeat-6.5.1-linux-x86_64/filebeat.yml -e
directory=/opt/filebeat-6.5.1-linux-x86_64
user=work
autostart=true
autorestart=true
stopsignal=QUIT
stopasgroup=true
stdout_logfile=/data/log/filebeat.log
stderr_logfile=/data/log/filebeat_error.log
stdout_logfile_maxbytes=50MB
stdout_logfile_backups=10
stderr_logfile_maxbytes=50MB
stderr_logfile_backups=10




/opt/logstash-6.5.1/bin/logstash  -f /opt/logstash-6.5.1/config/kafka-logstash-es.conf -w 4  -b 1024


[program:logstash]
environment=HOME=/home/work,JAVA_HOME=/usr/local/jdk1.8.0_151
command=/opt/logstash-6.5.1/bin/logstash  -f /opt/logstash-6.5.1/config/kafka-logstash-es.conf  -w 4  -b 1024
directory=/opt/logstash-6.5.1
user=work
autostart=true
autorestart=true
stopsignal=QUIT
stopasgroup=true
stdout_logfile=/data/log/logstash.log
stderr_logfile=/data/log/logstash_error.log
stdout_logfile_maxbytes=50MB
stdout_logfile_backups=10
stderr_logfile_maxbytes=50MB
stderr_logfile_backups=10






es插件, 可管理多个es集群, 支持所有版本,  跟kopf


https://github.com/lmenezes/cerebro



安装
https://www.jianshu.com/p/8f95b855296c




es安装
#版本下载
https://www.elastic.co/downloads/past-releases




vim /etc/sysctl.conf
vm.max_map_count = 262144


vim /etc/security/limits.conf
* soft memlock unlimited
* hard memlock unlimited



/etc/elasticsearch/elasticsearch.yml   # 主配置文件

cluster.name: anti_cheating
node.name: anti_cheating_node_1
path.data: /data/es/data
path.logs: /data/es/logs
discovery.zen.ping.unicast.hosts: ["172.16.0.225","172.16.0.223"]
network.host: 0.0.0.0



/etc/elasticsearch/jvm.options         # 调整内存 两个参数要一致,不然无法启动


mkdir -p /data/es/data /data/es/log
chown -R work.work /data/es /app/elasticsearch-5.6.7


sudo systemctl enable elasticsearch.service

sudo systemctl start elasticsearch.service


# 使用普通用户启动
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





curl '127.0.0.1:9200/_cat/health?v'                    # 健康检查
curl '127.0.0.1:9200/_cat/nodes?v'                     # 获取集群的节点列表
curl '127.0.0.1:9200/_cat/indices?v'                   # 列出所有索引
curl 127.0.0.1:9200/indexname -XDELETE                 # 删除索引
curl -XGET http://127.0.0.1:9200/_cat/shards           # 查看分片
curl '127.0.0.1:9200/_cat/indices'                     # 查分片同步  unassigned_shards  # 没同步完成





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




# kibana.yml
server.host: "172.20.81.75"
#server.name: "sre-elk"
elasticsearch.url: "http://localhost:9200"
elasticsearch.requestTimeout: 90000



kibana 汉化
https://github.com/anbai-inc/Kibana_Hanization