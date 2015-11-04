#!/bin/bash
#check_neiwang

if [ $# -ne 2 ];then
echo "USAGE: $0 -h IP"
exit 1
fi

while getopts :h: parameter
do
case $parameter in
h)
ip=$OPTARG
;;
*)
echo "USAGE: $0 -h IP"
exit 1
;;
esac
done

if [ -z $ip ]
then
echo "USAGE: $0 -h IP"
exit 1
fi

#定义nagios返回的状态变量
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

Date=`date +%y%m%d_%R` 


/usr/local/nagios/libexec/check_ping -H $ip -w 2000.0,80% -c 3000.0,100% -p 1 >/dev/null
if [ $? -ne 0 ];then
	echo "${Date}.昌平内网_${ip}_已宕机" |iconv -f gbk -t utf8
	exit $STATE_CRITICAL
else
	echo "昌平内网_${ip}_正常" |iconv -f gbk -t utf8
	exit $STATE_OK
fi

