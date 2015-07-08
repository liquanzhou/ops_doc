#!/bin/bash
#nrpe.sh

case $1 in
start)
/usr/local/nagios/bin/nrpe -c /usr/local/nagios/etc/nrpe.cfg -d
sleep 2
netstat -nltp |grep nrpe
;;
stop)
kill `lsof  /usr/local/nagios/bin/nrpe |awk '/nrpe/{print $2}'`
;;
restart)
kill `lsof  /usr/local/nagios/bin/nrpe |awk '/nrpe/{print $2}'`
sleep 2
/usr/local/nagios/bin/nrpe -c /usr/local/nagios/etc/nrpe.cfg -d
sleep 2
netstat -nltp |grep nrpe
;;
*)
echo "Usage: $0 start|stop|restart"
;;
esac