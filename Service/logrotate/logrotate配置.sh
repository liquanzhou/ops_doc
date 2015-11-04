0 0 * * * /usr/sbin/logrotate -f /opt/scm/log/push-receive-worker/push_logstatus.conf

/usr/sbin/logrotate -f /opt/scm/log/push-receive-worker/push_logstatus.conf

# /opt/scm/log/push-receive-worker/push_logstatus.conf
/opt/scm/log/push-receive-worker/push-receive-worker.log {
daily
copytruncate
ifempty
#olddir /opt/scm/log/push-receive-worker/
rotate 7
dateext
}


/opt/smc/log/server/*.log /opt/smc/log/server/*.err {
daily
copytruncate
ifempty
olddir /opt/smc/log/debuglog
rotate 7
dateext
}



# 注意 如果目录不存在要及时去掉,否则所有切割报错.  要不可以分成多个 {} 任务 则不互相影响
