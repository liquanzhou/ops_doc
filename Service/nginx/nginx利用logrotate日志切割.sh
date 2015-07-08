nginx利用logrotate日志切割


用"logrotate"来管理linux日志文件，它可以实现日志的自动滚动，日志归档等功能。下面以nginx日志文件来讲解下logrotate的用法。

#!/bin/bash
log_conf="/opt/work/logrotate/logrotate.conf"
if [ -f $log_conf ] ; then
      /usr/sbin/logrotate -s /opt/work/logrotate/logstatus -f ${log_conf}
fi

################################################################################
/opt/work/logrotate/logrotate.conf

/opt/wwwlogs/nginxlog/new.host.access.log{
      daily
      copytruncate
      dateext
      rotate 4
}

注释：
/var/log/nginx/*.log：需要轮询日志路径
daily：每天轮询
rotate 30：保留最多30次滚动的日志
missingok:如果日志丢失，不报错继续滚动下一个日志
notifempty:当日志为空时不进行滚动
compress：旧日志默认用gzip压缩
/var/run/nginx.pid：nginx主进程pid


/var/log/nginx/*.log {
        daily
        missingok
        rotate 30
        compress
        notifempty
        create 640 www www
        sharedscripts
        postrotate
                [ -f /var/run/nginx.pid ] && kill -USR1 `cat /var/run/nginx.pid`
        endscript
}

 

