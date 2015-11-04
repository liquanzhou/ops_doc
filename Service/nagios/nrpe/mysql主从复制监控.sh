#!/bin/sh
#脚本名:check_repl
#mysql主从复制监控插件

#判断脚本参数是否正确
if [ $# -ne 8 ];then
echo "USAGE: $0 -u user -p passwd -P port -h host"
exit 1
fi

while getopts :u:p:P:h: name
do
case $name in
u)
mysql_user=$OPTARG
;;
p)
mysql_passwd=$OPTARG
;;
P)
mysql_port=$OPTARG
;;
h)
mysql_host=$OPTARG
;;
*)
echo "USAGE: $0 -u user -p passwd -P port -h host"
exit 1
;;
esac
done

if [ -z $mysql_user ] || [ -z $mysql_passwd ] || [ -z $mysql_port ] || [ -z $mysql_host ]
then
echo "USAGE: $0 -u user -p passwd -P port -h host"
exit 1
fi


#定义返回状态变量
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

#取服务器中被监控的值

results=`mysql -u"$mysql_user" -p"$mysql_passwd" -P "$mysql_port" -h $mysql_host -A -e "show slave status\G;" 2> /dev/null|awk '/Slave_IO_Running/||/Slave_SQL_Running/{print $2}'|sed 'N;s/\n/_/'`

#判断得出
if [  -z "$results" ];then
echo ""$mysql_port"从库无法登陆" |iconv -f gbk -t utf8
exit $STATE_CRITICAL
elif [ "$results" == "Yes_Yes" ];then
echo ""$mysql_port" "$results"" |iconv -f gbk -t utf8
exit $STATE_OK
elif [ "$results" == "No_Yes" ] || [ "$results" == "Yes_No" ] || [ "$results" == "No_No" ];then
echo ""$mysql_port" "$results"" |iconv -f gbk -t utf8
exit $STATE_CRITICAL
else
echo ""$mysql_port" 从库异常" |iconv -f gbk -t utf8
exit $STATE_CRITICAL
fi

#脚本结束



