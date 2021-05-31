haproxy配置文件详解


    写在前面的话，本文档部分信息来自网络，同时参考过官方的架构指南，在此非常感谢zero提供的文档，以及在学习haproxy过程中的帮助。

    #/usr/local/sbin/haproxy -f /etc/haproxy/haproxy.cfg -st `cat /var/run/haproxy.pid` 
           ####################全局配置信息######################## 
           #######参数是进程级的，通常和操作系统（OS）相关######### 
    global 
           maxconn 20480                   #默认最大连接数 
           log 127.0.0.1 local3            #[err warning info debug] 
           chroot /var/haproxy             #chroot运行的路径 
           uid 99                          #所属运行的用户uid 
           gid 99                          #所属运行的用户组 
           daemon                          #以后台形式运行haproxy 
           nbproc 1                        #进程数量(可以设置多个进程提高性能) 
           pidfile /var/run/haproxy.pid    #haproxy的pid存放路径,启动进程的用户必须有权限访问此文件 
           ulimit-n 65535                  #ulimit的数量限制 
     
     
           #####################默认的全局设置###################### 
           ##这些参数可以被利用配置到frontend，backend，listen组件## 
    defaults 
           log global 
           mode http                       #所处理的类别 (#7层 http;4层tcp  ) 
           maxconn 20480                   #最大连接数 
           option httplog                  #日志类别http日志格式 
           option httpclose                #每次请求完毕后主动关闭http通道 
           option dontlognull              #不记录健康检查的日志信息 
           option forwardfor               #如果后端服务器需要获得客户端真实ip需要配置的参数，可以从Http Header中获得客户端ip  
           option redispatch               #serverId对应的服务器挂掉后,强制定向到其他健康的服务器  
           option abortonclose             #当服务器负载很高的时候，自动结束掉当前队列处理比较久的连接 
           stats refresh 30                #统计页面刷新间隔 
           retries 3                       #3次连接失败就认为服务不可用，也可以通过后面设置 
           balance roundrobin              #默认的负载均衡的方式,轮询方式 
          #balance source                  #默认的负载均衡的方式,类似nginx的ip_hash 
          #balance leastconn               #默认的负载均衡的方式,最小连接 
           contimeout 5000                 #连接超时 
           clitimeout 50000                #客户端超时 
           srvtimeout 50000                #服务器超时 
           timeout check 2000              #心跳检测超时 
     
           ####################监控页面的设置####################### 
    listen admin_status                    #Frontend和Backend的组合体,监控组的名称，按需自定义名称 
            bind 0.0.0.0:65532             #监听端口 
            mode http                      #http的7层模式 
            log 127.0.0.1 local3 err       #错误日志记录 
            stats refresh 5s               #每隔5秒自动刷新监控页面 
            stats uri /admin?stats         #监控页面的url 
            stats realm itnihao\ itnihao   #监控页面的提示信息 
            stats auth admin:admin         #监控页面的用户和密码admin,可以设置多个用户名 
            stats auth admin1:admin1       #监控页面的用户和密码admin1 
            stats hide-version             #隐藏统计页面上的HAproxy版本信息  
            stats admin if TRUE            #手工启用/禁用,后端服务器(haproxy-1.4.9以后版本) 
     
     
           errorfile 403 /etc/haproxy/errorfiles/403.http 
           errorfile 500 /etc/haproxy/errorfiles/500.http 
           errorfile 502 /etc/haproxy/errorfiles/502.http 
           errorfile 503 /etc/haproxy/errorfiles/503.http 
           errorfile 504 /etc/haproxy/errorfiles/504.http 
     
           #################HAProxy的日志记录内容设置################### 
           capture request  header Host           len 40 
           capture request  header Content-Length len 10 
           capture request  header Referer        len 200 
           capture response header Server         len 40 
           capture response header Content-Length len 10 
           capture response header Cache-Control  len 8 
         
           #######################网站监测listen配置##################### 
           ###########此用法主要是监控haproxy后端服务器的监控状态############ 
    listen site_status 
           bind 0.0.0.0:1081                    #监听端口 
           mode http                            #http的7层模式 
           log 127.0.0.1 local3 err             #[err warning info debug] 
           monitor-uri /site_status             #网站健康检测URL，用来检测HAProxy管理的网站是否可以用，正常返回200，不正常返回503 
           acl site_dead nbsrv(server_web) lt 2 #定义网站down时的策略当挂在负载均衡上的指定backend的中有效机器数小于1台时返回true 
           acl site_dead nbsrv(server_blog) lt 2 
           acl site_dead nbsrv(server_bbs)  lt 2  
           monitor fail if site_dead            #当满足策略的时候返回503，网上文档说的是500，实际测试为503 
           monitor-net 192.168.16.2/32          #来自192.168.16.2的日志信息不会被记录和转发 
           monitor-net 192.168.16.3/32 
     
           ########frontend配置############ 
           #####注意，frontend配置里面可以定义多个acl进行匹配操作######## 
    frontend http_80_in 
           bind 0.0.0.0:80      #监听端口，即haproxy提供web服务的端口，和lvs的vip端口类似 
           mode http            #http的7层模式 
           log global           #应用全局的日志配置 
           option httplog       #启用http的log 
           option httpclose     #每次请求完毕后主动关闭http通道，HA-Proxy不支持keep-alive模式 
           option forwardfor    #如果后端服务器需要获得客户端的真实IP需要配置次参数，将可以从Http Header中获得客户端IP 
           ########acl策略配置############# 
           acl itnihao_web hdr_reg(host) -i ^(www.itnihao.cn|ww1.itnihao.cn)$    
           #如果请求的域名满足正则表达式中的2个域名返回true -i是忽略大小写 
           acl itnihao_blog hdr_dom(host) -i blog.itnihao.cn 
           #如果请求的域名满足www.itnihao.cn返回true -i是忽略大小写 
           #acl itnihao    hdr(host) -i itnihao.cn 
           #如果请求的域名满足itnihao.cn返回true -i是忽略大小写 
           #acl file_req url_sub -i  killall= 
           #在请求url中包含killall=，则此控制策略返回true,否则为false 
           #acl dir_req url_dir -i allow 
           #在请求url中存在allow作为部分地址路径，则此控制策略返回true,否则返回false 
           #acl missing_cl hdr_cnt(Content-length) eq 0 
           #当请求的header中Content-length等于0时返回true 
     
           ########acl策略匹配相应############# 
           #block if missing_cl 
           #当请求中header中Content-length等于0阻止请求返回403 
           #block if !file_req || dir_req 
           #block表示阻止请求，返回403错误，当前表示如果不满足策略file_req，或者满足策略dir_req，则阻止请求 
           use_backend  server_web  if itnihao_web 
           #当满足itnihao_web的策略时使用server_web的backend 
           use_backend  server_blog if itnihao_blog 
           #当满足itnihao_blog的策略时使用server_blog的backend 
           #redirect prefix http://blog.itniaho.cn code 301 if itnihao 
           #当访问itnihao.cn的时候，用http的301挑转到http://192.168.16.3 
           default_backend server_bbs 
           #以上都不满足的时候使用默认server_bbs的backend 
     
     
     
     
           ##########backend的设置############## 
    #下面我将设置三组服务器 server_web，server_blog，server_bbs
    ###########################backend server_web############################# 
    backend server_web 
           mode http            #http的7层模式 
           balance roundrobin   #负载均衡的方式，roundrobin平均方式 
           cookie SERVERID      #允许插入serverid到cookie中，serverid后面可以定义 
           option httpchk GET /index.html #心跳检测的文件 
           server web1 192.168.16.2:80 cookie web1 check inter 1500 rise 3 fall 3 weight 1  
           #服务器定义，cookie 1表示serverid为web1，check inter 1500是检测心跳频率rise 3是3次正确认为服务器可用， 
           #fall 3是3次失败认为服务器不可用，weight代表权重 
           server web2 192.168.16.3:80 cookie web2 check inter 1500 rise 3 fall 3 weight 2 
           #服务器定义，cookie 1表示serverid为web2，check inter 1500是检测心跳频率rise 3是3次正确认为服务器可用， 
           #fall 3是3次失败认为服务器不可用，weight代表权重 
     
    ###################################backend server_blog############################################### 
    backend server_blog 
           mode http            #http的7层模式 
           balance roundrobin   #负载均衡的方式，roundrobin平均方式 
           cookie SERVERID      #允许插入serverid到cookie中，serverid后面可以定义 
           option httpchk GET /index.html #心跳检测的文件 
           server blog1 192.168.16.2:80 cookie blog1 check inter 1500 rise 3 fall 3 weight 1  
           #服务器定义，cookie 1表示serverid为web1，check inter 1500是检测心跳频率rise 3是3次正确认为服务器可用，fall 3是3次失败认为服务器不可用，weight代表权重 
           server blog2 192.168.16.3:80 cookie blog2 check inter 1500 rise 3 fall 3 weight 2 
            #服务器定义，cookie 1表示serverid为web2，check inter 1500是检测心跳频率rise 3是3次正确认为服务器可用，fall 3是3次失败认为服务器不可用，weight代表权重 
     
    ###################################backend server_bbs############################################### 
     
    backend server_bbs 
           mode http            #http的7层模式 
           balance roundrobin   #负载均衡的方式，roundrobin平均方式 
           cookie SERVERID      #允许插入serverid到cookie中，serverid后面可以定义 
           option httpchk GET /index.html #心跳检测的文件 
           server bbs1 192.168.16.2:80 cookie bbs1 check inter 1500 rise 3 fall 3 weight 1  
           #服务器定义，cookie 1表示serverid为web1，check inter 1500是检测心跳频率rise 3是3次正确认为服务器可用，fall 3是3次失败认为服务器不可用，weight代表权重 
           server bbs2 192.168.16.3:80 cookie bbs2 check inter 1500 rise 3 fall 3 weight 2 
            #服务器定义，cookie 1表示serverid为web2，check inter 1500是检测心跳频率rise 3是3次正确认为服务器可用，fall 3是3次失败认为服务器不可用，weight代表权重 

 以上为基本的配置文件，下面会对这个配置一一说明和应用