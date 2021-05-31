#!/bin/sh
#check_disk
#./check_disk -w warning -c critical

#判断脚本参数是否正确
if [ $# -ne 4 ];then
echo "USAGE: $0 -w warning -c critical"
exit 1
fi

while getopts :w:c: parameter
do
case $parameter in
w)
warning=$OPTARG
;;
c)
critical=$OPTARG
;;
*)
echo "USAGE: $0 -w warning -c critical"
exit 1
;;
esac
done

if [ -z $warning ] || [ -z $critical ] 
then
echo "USAGE: $0 -w warning -c critical"
exit 1
fi

#定义nagios返回的状态变量
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

#取服务器中被监控的值
disk_warning=`df|grep -v '/dev/shm'|awk 'NR!=1{print $5}'|awk -F"%" '{print $1}'|awk '$1 > '"$warning"' && $1 < '"$critical"''|wc -l`
disk_critical=`df|grep -v '/dev/shm'|awk 'NR!=1{print $5}'|awk -F"%" '{print $1}'|awk '$1 >= '"$critical"''|wc -l`
disk_space=`df -h|grep -v '/dev/shm'|awk 'NR!=1{print "("$6,$4,$5")"}'`

#判断得出
if [ "$disk_critical" == 0 ]&&[ "$disk_warning" == 0 ];then
echo ""$disk_space"" |iconv -f gbk -t utf8
exit $STATE_OK

elif [ "$disk_critical" -ge 1 ];then
echo ""$disk_space"" |iconv -f gbk -t utf8
exit $STATE_CRITICAL

elif [ "$disk_warning" -ge 1 ];then
echo ""$disk_space"" |iconv -f gbk -t utf8
exit $STATE_WARNING
fi

#脚本结束


