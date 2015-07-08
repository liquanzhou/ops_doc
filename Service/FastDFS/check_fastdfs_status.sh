#!/bin/bash 
source ~/.bash_profile
Basedir=`dirname $0`
Active=$Basedir/active.txt
IP=$Basedir/ip.txt
Syn_time=$Basedir/syn_time.txt
/sbin/ip add |grep em2 |grep inet|cut -d/ -f1|awk '{print $2}' >$IP
/usr/local/fastdfs/bin/fdfs_monitor /usr/local/fastdfs/conf/storage.conf >status.txt
AIP=`cat $IP`
/bin/cat status.txt | grep $AIP |awk '/ip_addr/{print $NF}' > active.txt
Now_time=`date +%s` 
sed -n '/Storage/,/Storage/p' status.txt >Storage1
sed -n '/Storage 2/,//p' status.txt >Storage2
Hostip=`cat Storage1 |grep "$AIP"`
if [ "$Hostip" != "" ];then
    num=`cat Storage1| grep last_synced_timestamp | awk -F"(" '{print $2}' |awk '{print $1}' |awk -F"s" '{print $1}'`
    cat Storage1| grep last_synced_timestamp | awk '{ print $3,$4 }' >$Syn_time
    NUM=$num
else
    num=`cat Storage2| grep last_synced_timestamp | awk -F"(" '{print $2}' |awk '{print $1}' |awk -F"s" '{print $1}'`
    cat Storage2| grep last_synced_timestamp | awk '{ print $3,$4 }' >$Syn_time
    NUM=$num
fi
paste $Syn_time $IP $Active > main.log 
cat main.log | while read day time ip active 
do 
  if [ "$num" == "" ];then
   sys_time=`date -d "$day $time" +%s`
   num1=`expr ${Now_time} - ${sys_time}`
   if [ "${active}" == "ACTIVE" ]&&[ "$num1" -lt 120 ];
   then 
   echo "OK - FASTDFS_STORAGE status: $active and delay is $num1"
   exit 0
   else
   echo "Critical - FASTDFS_STORAGE status: $ip State is $active, Update time delay $num1 (s),please check."
   exit 1 
   fi
  else
   if [ "${active}" == "ACTIVE" ]&&[ "$NUM" -lt 120 ];
   then
   echo "OK - FASTDFS_STORAGE status: $active and delay is $NUM"
   exit 0
   else
   echo "Critical - FASTDFS_STORAGE status: $ip State is $active, Update time delay $NUM (s),please check."
   exit 2 
   fi
  fi
done 
rm -rf $Active $IP $Syn_time main.log status.txt
