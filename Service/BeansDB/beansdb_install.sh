beansdb安装


yum install autoconf automake

tar -zxvf beansdb-0.5.8.tar.gz 
cd beansdb-0.5.8   

./configure --prefix=/opt/beansdb   
make   
make install   
cd /opt/beansdb/
mkdir {data,log}   

vim admin_beansdb.sh 

#################################################################
#!/bin/sh

basepath=/opt/beansdb
user=root
port=6666
pidfile=${basepath}/beansdb_${port}.pid
execbin=${basepath}/bin/beansdb
datadir=${basepath}/data
accesslog=${basepath}/log/access.log
#flush_period=1 #sec
#flush_num=2048 #k

function _usage_() {
  echo "Usage:$0 <start|stop>"
}

if [ -z $1 ]
then
  _usage_
  exit 1
fi

#if [ -n $2 ]
#then
#  port=$2
#fi

case "$1" in
  start)
    if [ -f ${pidfile} ]
    then
      pid=`cat ${pidfile}`
      cnt=`ps -ef | grep $pid | grep "beansdb" | grep -v "grep" | wc -l`
      if [ $cnt -gt 0 ]
      then
        echo "There is already an instance at port ${port}."
      else
        ${execbin} -u ${user} -p ${port} -P ${pidfile} -H ${datadir} -L ${accesslog} -T 2 -d
      fi
    else
      ${execbin} -u ${user} -p ${port} -P ${pidfile} -H ${datadir} -L ${accesslog} -T 2 -d
    fi
  ;;
  stop)
    echo "Are you sure to stop beansdb instance at port ${port} (y/n)?"
    read cfm
    if [ $cfm == 'y' ]
    then
      if [ -f ${pidfile} ]
      then
        kill `cat ${pidfile}`
      else
        echo "pid file not exists."
      fi
    else
      echo "do nothing."
    fi
  ;;
  *)
    _usage_
  ;;
esac


#################################################################


sh admin_beansdb.sh start
ll data
netstat -na | grep 6666



