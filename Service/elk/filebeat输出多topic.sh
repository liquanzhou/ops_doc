filebeat输出多topic

filebeat7.5

https://www.elastic.co/guide/en/beats/filebeat/current/kafka-output.html



filebeat.prospectors:
- type: log
  enabled: true
  paths:
    - /var/log/mylog/test1.log
  fields:
    log_topics: test1
- type: log
  enabled: true
  paths:
    - /var/log/mylog/test2.log
  fields:
    log_topics: test2


output.kafka:
  # initial brokers for reading cluster metadata
  hosts: ["kafka1:9092", "kafka2:9092", "kafka3:9092"]

  # message topic selection + partitioning
  topic: '%{[fields.log_topic]}'
  partition.round_robin:
    reachable_only: false

  required_acks: 1
  compression: gzip
  max_message_bytes: 1000000