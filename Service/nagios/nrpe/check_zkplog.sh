#!/bin/sh

file=/opt/zookeeper/zookeeper-3.3.5/zookeeper.out

now=`date --date "1 min ago" +"%Y-%m-%d %H:%M"`
check=`tail -n 5000 $file | grep "$now" | grep "ERROR \[CommitProcessor:0:NIOServerCnxn@445\] - Unexpected Exception"`
#check=`tail -n 5000 $file | grep "java.nio.channels.CancelledKeyException"`
#check=`tail -n 5000 $file | grep "NIOServerCnxn$Factory@251"`

if [ "$check" == '' ]
then
    echo "zookeeperlog is ok"
    exit 0
else
    echo "zooklog is error"
    exit 2
fi
