cat del-index.sh


#!/bin/sh
date
datepattern=`date -u -d "30 days ago" +%Y.%m.%d`

if [[ "$1" =~ ^[0-9]{4}\.[0-9]{2}\.[0-9]{2}$ ]];then
    datepattern=$1
fi


# 删除索引
indices=`curl p-loges-01:9200/_cat/indices 2>/dev/null | awk "/$datepattern/"'{print $3}'`
for i in $indices; do
    echo "Delete indice $i"...
    curl p-loges-01:9200/$i -XDELETE
    echo ""
done

# 关闭索引，这样就搜不到了，节省内存
# set the indice close
for i in $indices; do
    echo "Close indice $i"...
    curl -XPOST 'p-loges-01:9200/'{$i}'/_close'
    echo ""
done


# 默认没有备份分片，每天凌晨把昨天的备份分片打开, 因为一开始就有备份分片，会降低效率
# set the replic to 1, default is 0

for i in {1..25}; do
    datepattern=`date -u -d "$i hours ago" +%Y.%m.%d.%H`
    echo "Add replication for ngxlog-$datepattern ..."
    curl -XPUT p-loges-01:9200/ngxlog-$datepattern/_settings -d '{ "index" : { "number_of_replicas" : 1 } }'
    echo ""
done


