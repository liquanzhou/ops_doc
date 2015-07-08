squid安装+反向代理+缓存配置 

欢迎系统运维加群: 198173206   # 转载请保留

groupadd squid
useradd -g squid -s /sbin/nologin squid

tar zxvpf squid-3.0.STABLE24.tar.gz
cd squid-3.0.STABLE24

./configure --prefix=/opt/squid --enable-gnuregex --enable-icmp --enable-default-err-language=Simplify_Chinese\
 --enable-kill-parent-hack --enable-cache-digests --enable-async-io=160 --enable-delay-pools --enable-snmp \
 --enable-arp-acl --mandir=/usr/share/man --with-large-files  --with-filedescriptors=65536  --enable-underscore

make
make install
 
vim /opt/squid/etc/squid.conf
# 添加配置文件内容
######################################################################
cache_effective_user squid
cache_effective_group squid
pid_filename /opt/squid/var/logs/squid.pid
# squid主机名
visible_hostname system-test
http_port 80 vhost vport
cache_mgr root@localhost
error_directory /opt/squid/share/errors/Simplify_Chinese

# 添加web服务器
cache_peer 10.152.14.85 parent 8080 0 no-query originserver round-robin weight=100 name=web1
cache_peer 10.152.14.85 parent 8180 0 no-query originserver round-robin weight=100 name=web2
cache_peer 10.152.14.86 parent 8180 0 no-query originserver round-robin weight=100 name=web3

# 配置web服务器对应域名
cache_peer_domain web1 .123.com
cache_peer_domain web2 .456.com
cache_peer_domain web3 .456.com

#dns_defnames    on
#dns_nameservers 10.0.0.132
#hosts_file /opt/squid/etc/hosts

forwarded_for on
cache_log /opt/squid/var/cache.log

cache_swap_low 90
cache_swap_high 95
maximum_object_size 100 KB
minimum_object_size 0 KB
cache_mem 2048 MB

memory_replacement_policy lru
cache_dir ufs /opt/squid/cache 10240 16 256

access_log /opt/squid/var/access.log squid
logformat squid  %ts.%03tu %6tr %>a %Ss/%03Hs %<st %rm %ru %un %Sh/%<A %mt
#logformat combined %>a %ui %un [%tl] "%rm %ru HTTP/%rv" %Hs %<st "%{Referer}>h" "%{User-Agent}>h" %Ss:%Sh
#access_log /opt/squid/var/access.log combined

acl AL src 0.0.0.0/0.0.0.0

http_access allow AL

acl QUERY urlpath_regex cgi-bin .php .cgi .avi .wmv .rm .ram .mpg .mpeg .zip .exe

cache deny QUERY
acl manager proto cache_object
acl PURGE method PURGE
acl localhost src 127.0.0.1/32
acl clearcache src 116.213.92.246/32
acl to_localhost dst 127.0.0.0/8

http_access allow manager localhost
http_access allow manager clearcache
http_access deny manager
http_access allow PURGE localhost
http_access allow PURGE clearcache
http_access deny PURGE

######################################################################
chown squid.squid /opt/squid -R


/opt/squid/sbin/squid -z             # 初始化缓存目录

/opt/squid/sbin/squid -k parse       # 验证 squid.conf 语法和配置

/opt/squid/sbin/squid -N -d1         # 在前台启动squid,并输出启动过程。
# 如果有到 ready to server reques,启动成功。然后 ctrl + c,停止squid,并以后台运行的方式启动它。

/opt/squid/sbin/squid -s             # 后台启动

/opt/squid/sbin/squid -k shutdown    # 停止squid

/opt/squid/sbin/squid -k reconfigure # 重新载入新的配置文件

/opt/squid/sbin/squid -k rotate      # 轮循日志


# 状态信息
/opt/squid/bin/squidclient -p 80 mgr:5min                  # 可以看到详细的性能情况,其中PORT是你的proxy的端口，5min可以是60min
/opt/squid/bin/squidclient -p 80 mgr:info                  # 取得squid运行状态信息
/opt/squid/bin/squidclient -p 80 mgr:mem                   # 取得squid内存使用情况
/opt/squid/bin/squidclient -p 80 mgr:diskd                 # 取得squid的磁盘使用情况
/opt/squid/bin/squidclient -p 80 -m PURGE http://www.yejr.com/static.php    # 强制更新某个url
/opt/squid/bin/squidclient -p 80 mgrbjects. use it carefully,it may crash   # 取得squid已经缓存的列表
/opt/squid/bin/squidclient -h 或者 squidclient -p 80 mgr:  # 更多的请查看

# 查命中率：
/opt/squid/bin/squidclient -hIP -p80 mgr:info


欢迎系统运维加群: 198173206   # 转载请保留
