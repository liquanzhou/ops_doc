#!/bin/sh
#check_nginx
#./check_nginx -w warning -c critical
# warning 7500 critical 9000

STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

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
		exit $STATE_UNKNOWN
	;;
	esac
done

if [ -z $warning ] || [ -z $critical ] 
then
	echo "USAGE: $0 -w warning -c critical"
	exit $STATE_UNKNOWN
fi

NginxStatus=$(curl -s 127.0.0.1:9999/server-status)
Active=$(echo $NginxStatus |awk '/Active/{print $3}' )

if [ "X$Active" == "X" ];then
	echo "Nginx Down: $NginxStatus" 
	exit $STATE_CRITICAL
elif [ $Active -lt $warning ];then
	echo "Nginx OK: $NginxStatus" 
	exit $STATE_OK
elif [ $Active -lt $critical ];then
	echo "Nginx warning: $NginxStatus" 
	exit $STATE_WARNING
elif [ $Active -ge $critical ];then
	echo "Nginx critical: $NginxStatus" 
	exit $STATE_CRITICAL
fi

#end


