



#mongos配置文件
vim /opt/mongodb2.4.2/conf/Mongos.config
logpath=/opt/mongodb2.4.2/logs/Mongos/mongos.log
port=58029
configdb=10.0.0.11:36029,10.0.0.12:36029
bind_ip=10.0.0.63
logappend=true
fork=true
quiet=true

#启动mongos
numactl --interleave=all /opt/mongodb2.4.2/bin/mongos -f /opt/mongodb2.4.2/conf/Mongos.config




#关闭mongos
ps -eaf |grep '/opt/mongodb' |grep -v grep |awk '{print $2}' |xargs -t -i kill -9 {}


# 非正常启动
about to fork child process, waiting until server is ready for connections.
forked process: 14297
all output going to: /opt/mongodb2.4.2/logs/Mongos/mongos.log
child process started successfully, parent exiting

#log
Mon Nov 18 11:50:25.629 [mongosMain] ERROR: config servers not in sync! config servers 10.0.0.XX:36029 and 10.0.0.XX:36029 differ

#配置文件不同步导致的




