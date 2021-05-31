haprox安装

http://www.haproxy.org/    # 需要翻墙


tar zxvpf haproxy-1.5.11.tar.gz

cd haproxy-1.5.11

make TARGET=linux26 USE_PCRE=1 USE_OPENSSL=1 USE_ZLIB=1

# 透明代理  make TARGET=linux26 USE_LINUX_TPROXY=1

make install PREFIX=/usr/local/haproxy

cp -a examples/haproxy.cfg /usr/local/haproxy/


# 日志配置
    # centos5-6.1
    加上日志支持
    # vim /etc/syslog.conf
    在最下边增加
    local3.*         /var/log/haproxy.log
    local0.*         /var/log/haproxy.log

    #vim /etc/sysconfig/syslog
    修改： SYSLOGD_OPTIONS="-r -m 0"
    /etc/init.d/syslog restart


    # CENTOS6.2系统日志rsyslog替换默认的日志服务syslog

    vim /etc/rsyslog.conf    # 兼容系统自带的syslog.conf配置文件
    local0.*         /var/log/haproxy.log     # 增加
    # rsyslog 默认情况下，需要在514端口监听UDP，所以可以把/etc/rsyslog.conf如下的注释去掉 
    # Provides搜索 UDP syslog reception 
    $ModLoad imudp 
    $UDPServerRun 514
    
    /etc/init.d/rsyslog restart

# 启动
/usr/local/haproxy/sbin/haproxy -f /usr/local/haproxy/haproxy.cfg

# 关闭
kill `cat haproxy.pid` 


# 配置文件
global   参数是进程级的，通常和操作系统(OS)相关。这些参数一般只设置一次，如果配置无误，就不需要再次配置进行修改
defaults 配置默认参数的，这些参数可以被利用配置到frontend，backend，listen组件
frontend 接收请求的前端虚拟节点，Frontend可以根据规则直接指定具体使用后端的backend(可动态选择)
backend  后端服务集群的配置，是真实的服务器，一个Backend对应一个或者多个实体服务器
listen   Frontend和Backend的组合体

vim /usr/local/haproxy/haproxy.cfg
############################################################################################
global           #全局设置
       log 127.0.0.1   local0      #日志输出配置，所有日志都记录在本机，通过local0输出
       #log loghost    local0 info
       maxconn 4096             #最大连接数
       chroot /usr/local/haproxy
       uid 99                   #所属运行的用户uid
       gid 99                   #所属运行的用户组
       daemon                   #以后台形式运行haproxy
       nbproc 2                 #启动2个haproxy实例
       pidfile /usr/local/haproxy/haproxy.pid  #将所有进程写入pid文件
       #debug
       #quiet

defaults             #默认设置
       #log    global
       log     127.0.0.1       local3         #日志文件的输出定向
       mode    http         #所处理的类别,默认采用http模式，可配置成tcp作4层消息转发
       option  httplog       #日志类别,采用httplog
       option  dontlognull  
       option  forwardfor   #如果后端服务器需要获得客户端真实ip需要配置的参数，可以从Http Header中获得客户端ip
       option  httpclose    #每次请求完毕后主动关闭http通道,haproxy不支持keep-alive,只能模拟这种模式的实现
       retries 3           #3次连接失败就认为服务器不可用，主要通过后面的check检查
       option  redispatch   #当serverid对应的服务器挂掉后，强制定向到其他健康服务器
       maxconn 2000                     #最大连接数
stats   uri     /haproxy-admin  #haproxy 监控页面的访问地址
       contimeout      5000            #连接超时时间
       clitimeout      50000           #客户端连接超时时间
       srvtimeout      50000           #服务器端连接超时时间
stats auth  xuesong:xuesong   #设置监控页面的用户和密码：xuesong

stats hide-version         #隐藏统计页面的HAproxy版本信息


frontend http-in                        #接收请求的前端虚拟节点
       bind *:808
       mode    http
       option  httplog
       log     global
       default_backend htmpool       #静态服务器池

backend htmpool                    #后台
       balance leastconn    #负载均衡算法
       option  httpchk HEAD /a.html HTTP/1.0       #健康检查
       server  web1 192.168.56.102:80 cookie 1 weight 5 check inter 2000 rise 2 fall 3
       server  web2 192.168.56.102:80 cookie 2 weight 3 check inter 2000 rise 2 fall 3

#cookie 1表示serverid为1，check inter 1500 是检测心跳频率
#rise 2是2次正确认为服务器可用，fall 3是3次失败认为服务器不可用，weight代表权重

############################################################################################

global  
    maxconn 51200  
    chroot /usr/local/haproxy  
    uid 99  
    gid 99  
    daemon  
    #quiet  
    nbproc 2 #进程数  
    pidfile /usr/local/haproxy/haproxy.pid  
  
defaults  
        mode http #默认的模式mode { tcp|http|health }，tcp是4层，http是7层，health只会返回OK  
        #retries 2 #两次连接失败就认为是服务器不可用，也可以通过后面设置  
        option redispatch #当serverId对应的服务器挂掉后，强制定向到其他健康的服务器  
        option abortonclose #当服务器负载很高的时候，自动结束掉当前队列处理比较久的链接  
        timeout connect 5000ms #连接超时  
        timeout client 30000ms #客户端超时  
        timeout server 30000ms #服务器超时  
        #timeout check 2000 #=心跳检测超时  
        log 127.0.0.1 local0 err #[err warning info debug]  
        balance roundrobin                     #负载均衡算法  
#        option  httplog                        #日志类别,采用httplog  
#        option  httpclose   #每次请求完毕后主动关闭http通道,ha-proxy不支持keep-alive,只能模拟这种模式的实现  
#        option  dontlognull  
#        option  forwardfor  #如果后端服务器需要获得客户端真实ip需要配置的参数，可以从Http Header中获得客户端ip  
  
listen admin_stats  
        bind 0.0.0.0:8888 #监听端口  
        option httplog #采用http日志格式  
        stats refresh 30s #统计页面自动刷新时间  
        stats uri /stats #统计页面url  
        stats realm Haproxy Manager #统计页面密码框上提示文本  
        stats auth admin:admin #统计页面用户名和密码设置  
        #stats hide-version #隐藏统计页面上HAProxy的版本信息  
  
listen test1  
        bind :12345  
        mode tcp  
        server t1 192.168.1.101:8881  
        server t2 192.168.1.102:8881  
  
listen test2 0.0.0.0:880  
       option httpclose  
       option forwardfor
       option httpchk HEAD /a.html HTTP/1.0 
       server s1 192.168.56.102:80 check weight 1 minconn 1 maxconn 3 check inter 40000        
       server s2 192.168.56.102:80 check weight 1 minconn 1 maxconn 3 check inter 40000 
       
       
listen  appli5-backup 0.0.0.0:10005
        option  httpchk *
        balance roundrobin
        cookie  SERVERID insert indirect nocache
        server  inst1 192.168.114.56:80 cookie server01 check inter 2000 fall 3
        server  inst2 192.168.114.56:81 cookie server02 check inter 2000 fall 3
        server  inst3 192.168.114.57:80 backup check inter 2000 fall 3
        capture cookie ASPSESSION len 32
        srvtimeout      20000

        option  httpclose               # disable keep-alive
        option  checkcache              # block response if set-cookie & cacheable
        rspidel ^Set-cookie:\ IP=       # do not let this cookie tell our internal IP address

        errorloc        502     http://192.168.114.58/error502.html
        errorfile       503     /etc/haproxy/errors/503.http

############################################################################################



