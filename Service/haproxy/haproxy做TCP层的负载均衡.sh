haproxy做TCP层的负载均衡

最近正在上游戏项目，在做haproxy负载时出现启动不了情况，所以打算重新部署一下haproxy TCP负载均衡，在网上查了这方面的资料参考一下，结合自己的经验写了如下文章，希望大家参考！
1.下载haproxy最新版本
http://haproxy.1wt.eu/download/1.4/src/haproxy-1.4.16.tar.gz
2.安装haproxy软件
       tar zxvf haproxy-1.4.16.tar.gz
       cd haproxy-1.4.16
 
　　uname -a    //查看linux内核版本
 
　　make TARGET=linux26 PREFIX=/opt/haproxy
 
　　make install PREFIX=/opt/haproxy
3.配置haproxy
mkdir /opt/haproxy/conf
vim /opt/haproxy/conf/haproxy.cfg
###########全局配置#########
global
chroot /opt/haproxy
daemon
nbproc 1
group nobody
user nobody
pidfile /opt/haproxy/logs/haproxy.pid
ulimit-n 65536
#spread-checks 5m 
#stats timeout 5m
#stats maxconn 100

########默认配置############
defaults
mode tcp               #默认的模式mode { tcp|http|health }，tcp是4层，http是7层，health只会返回OK
retries 3              #两次连接失败就认为是服务器不可用，也可以通过后面设置
option redispatch      #当serverId对应的服务器挂掉后，强制定向到其他健康的服务器
option abortonclose    #当服务器负载很高的时候，自动结束掉当前队列处理比较久的链接
maxconn 32000          #默认的最大连接数
timeout connect 5000ms #连接超时
timeout client 30000ms #客户端超时
timeout server 30000ms #服务器超时
#timeout check 2000    #心跳检测超时
log 127.0.0.1 local0 err #[err warning info debug]
 
########test1配置#################
listen test1
bind 0.0.0.0:8008
mode tcp
balance roundrobin
server s1 127.0.0.1:8010 weight 1 maxconn 10000 check inter 10s
server s2 127.0.0.1:8011 weight 1 maxconn 10000 check inter 10s
server s3 127.0.0.1:8012 weight 1 maxconn 10000 check inter 10s
 
########test2配置#################
listen test2
bind 0.0.0.0:8007
mode tcp
balance roundrobin
server s1 192.168.1.88:8010 weight 1 maxconn 10000 check inter 10s
server s2 192.168.1.88:8011 weight 1 maxconn 10000 check inter 10s
########统计页面配置########
listen admin_stats
bind 0.0.0.0:8099 #监听端口
mode http         #http的7层模式
option httplog    #采用http日志格式
#log 127.0.0.1 local0 err
maxconn 10
stats refresh 30s #统计页面自动刷新时间
stats uri /stats #统计页面url
stats realm XingCloud\ Haproxy #统计页面密码框上提示文本
stats auth admin:admin #统计页面用户名和密码设置
stats hide-version #隐藏统计页面上HAProxy的版本信息
4.配置启动脚本
vim /opt/haproxy/sbin/haproxy.sh
#!/bin/sh
cd /opt/haproxy/sbin
/opt/haproxy/sbin/haproxy -f /opt/haproxy/conf/haproxy.cfg &
5.查看启动进程
ps -ef |grep haproxy  或者netstat -ntpl |grep haproxy  来检查haproxy是否启动成功！