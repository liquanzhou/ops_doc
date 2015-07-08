vi /etc/rsyncd.conf 

uid = root
gid = root
use chroot = no
max connections = 10
strict modes =yes
port = 873
pid file = /var/run/rsyncd.pid
lock file = /var/run/rsync.lock
log file = /var/log/rsyncd.log

[user]
path = /data/DATA/smc/interface/logs/user_visit_daily/
comment = This is a test
ignore errors
read only = yes
hosts allow = 10.13.81.125
[dc]
path = /data/DATA/smc/interface/logs/dc/
comment = This is a test
ignore errors
read only = no
hosts allow = 10.13.81.47
#hosts allow = 10.10.70.155



rsync -azv --update yd125@10.13.81.130::user /opt/smc/activeuser/ > /dev/null 2>&1