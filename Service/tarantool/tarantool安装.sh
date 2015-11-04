tarantool1.4或1.5安装

#1.6改变太大暂时不做使用

# 与redis区别是列式的

# 端口管理混乱，千万别再一个主机安装2个或多个

wget http://10.10.76.79:81/muzy/software/tarantool.tar.gz

rpm -ivh tarantool-1.4.8-58-g9bfd97d-linux-x86_64.rpm

mkdir -p /opt/tarantool/snap  
mkdir -p /opt/tarantool/xlog

上传如下文件到目录 /opt/tarantool/
saveToFile.sh
start.sh
stop.sh
tarantool.cfg

#首次启动前初始化   # 清空数据
#tarantool_box -c tarantool.cfg --init-storage

#启动
tarantool_box -c tarantool.cfg --background


#登录管理端口   admin_port = 33015  
/usr/local/bin/tarantool -h 127.0.0.1 -p 33015
telnet 10.16.12.18  33015
echo "show slab" |nc 10.16.12.18  33015   # 用nc反弹取使用率，方便截取
show slab    # 查看使用率


# 无数据文件，保证关闭不丢失数据，要每天做快照，保留2天的xlog
# 恢复快照: 把 .snap 的快照放到snap_dir目录下，在基于最近的wal_dir，即可保证数据完整
# 快照  数据不更新无法快照
/usr/local/bin/tarantool -h 127.0.0.1 -p 33015 <<EOF
save snapshot
exit
EOF

# 删除过多xlog，过多影响启动速度
find /opt/tarantool/xlog -name "*.xlog" -ctime +3 -exec rm -f {} \;

########################################################################
#本地备份脚本
#saveToFile.sh
#/bin/bash

path='/opt/tarantool/'
port=33015

rm -f ${path}snap/*.bak
find ${path}snap/  -name "*.snap" -exec  rename .snap .bak {} \;

/usr/local/bin/tarantool -h 127.0.0.1 -p $port <<EOF
save snapshot
exit
EOF

find ${path}xlog/ -name "*.xlog" -ctime +3 -exec rm -f {} \;

########################################################################

#远程备份
#/bin/bash
#  5 5 * * * /opt/scripts/tarantool_bak/tarantool_bak.sh

Today=`date +%Y-%m-%d`

Date10=`date -d "10 days ago" +%Y-%m-%d`

echo $Today
for IP in `cat /opt/scripts/tarantool_bak/tarantool.ip`
do
        echo $IP

        ssh $IP /opt/tarantool/saveToFile.sh
        mkdir -p /data/Backup_tarantool/${IP}/
        scp $IP:/opt/tarantool/snap/*.snap  /data/Backup_tarantool/${IP}/tarantool_${Today}.snap
        rm -f /data/Backup_tarantool/${IP}/tarantool_${Date10}.snap

done
########################################################################

slab_alloc_arena = 32    # 内存大小 G
rows_per_wal = 500000    # xlog条数
wal_dir="xlog"           # xlog目录
snap_dir="snap"          # 快照目录

########################################################################
# tarantool.cfg

# Limit of memory used to store tuples to 100MB   (0.1 GB)
slab_alloc_arena = 32

pid_file = "box.pid"

# Read only and read-write port.
primary_port = 33013

# Read-only port.
secondary_port = 33014

# The port for administrative commands.
admin_port = 33015
memcached_port=33017
#主
#replication_port = 33016
#从
#replication_source=10.10.76.74:33016
logger="cat - >> tarantool.log"
log_level =4

rows_per_wal = 2000000
wal_dir="xlog"
snap_dir="snap"

# Define a simple space with 1 HASH-based
# primary key.
space[0].enabled = 1
space[0].index[0].type = "HASH"
space[0].index[0].unique = 1
space[0].index[0].key_field[0].fieldno = 0
space[0].index[0].key_field[0].type = "STR"
space[1].enabled = 1
space[1].index[0].type = "HASH"
space[1].index[0].unique = 1
space[1].index[0].key_field[0].fieldno = 0
space[1].index[0].key_field[0].type = "STR"
#memcached_space=2
#memcached_expire=true

########################################################################

#监控
#check_tarantool
#$USER1$/check_tarantool $HOSTADDRESS$
#!/bin/sh
ip=$1

items=`echo "show slab" |nc $1  33015  | grep "items_used"|awk {'print $2'}| awk -F'.' {'print $1'}`
arena=`echo "show slab" |nc $1  33015  | grep "arena_used"|awk {'print $2'}| awk -F'.' {'print $1'}`

#echo $items
#echo $arena

if [ $items -gt 90 ] || [ $arena -gt 90 ]
then
    echo "tarantool itmes $items %,arena $arena %"
    exit 2
else
    echo "tarantool itmes $items %,arena $arena %"
    exit 0
fi



