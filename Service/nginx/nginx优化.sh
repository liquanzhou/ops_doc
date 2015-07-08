nginx优化
2014-03-04 14:42:42
标签：nginx nginx 优化

说明：本文中的内容全部来自《实战nginx系统卷一书》，将自己感觉实用的部分整理出来，与大家分享。


1.优化写磁盘操作

nginx每访问完一个文件之后，linux系统将会对它的“Access”，即访问时间进行修改


[yunwei@moniter tmp]$ stat index.html

 File: “index.html”

 Size: 0               Blocks: 0          IO Block: 4096   一般空文件

Device: 6802h/26626d    Inode: 300777505   Links: 1

Access: (0664/-rw-rw-r--)  Uid: (  506/  yunwei)   Gid: (  506/  yunwei)

Access: 2014-02-12 15:28:23.000000000 +0800

Modify: 2014-02-12 15:28:23.000000000 +0800

Change: 2014-02-12 15:28:23.000000000 +0800


访问一次access时间就发生变化

[yunwei@moniter tmp]$ cat index.html

查看

[yunwei@moniter tmp]$ stat index.html

 File: “index.html”

 Size: 0               Blocks: 0          IO Block: 4096   一般空文件

Device: 6802h/26626d    Inode: 300777505   Links: 1

Access: (0664/-rw-rw-r--)  Uid: (  506/  yunwei)   Gid: (  506/  yunwei)

Access: 2014-02-12 15:28:45.000000000 +0800

Modify: 2014-02-12 15:28:23.000000000 +0800

Change: 2014-02-12 15:28:23.000000000 +0800


在一个高并发的访问中，这对磁盘读写操作影响很大，因此，关闭此功能


/dev/sdb1   /dataext3   defaults    0   0

/dev/sab1   /dataext3   defaults,noatime,nodiratime    0   0

重启系统，或者remount重新挂载


2.修改系统文件句柄数

vim /etc/security/limits.conf

*               soft    nofile       65535

*               hard   nofile        65535

*               soft    nproc        65535

*               hard   nproc         65535


重启生效

ulimit -n  

ulimit -a查看


3.优化内核TCP选项

修改以下内核参数：

net.ipv4.tcp_max_tw_buckets = 6000          

#默认值180000 设置timewait的值

net.ipv4.ip_local_port_range = 1024 65000  

#默认值32768 61000 设置允许系统打开的端口范围

net.ipv4.tcp_tw_recycle = 1                        

#默认值0 设置是否启用timewait

net.ipv4.tcp_tw_reuse = 1                          

#默认值0 设置是否开启重新使用，允许将TIME-WAIT sockets 重新用于新的TCP连接

net.ipv4.tcp_syncookies = 1                        

#默认值0 设置是否开启SYN Cookies，如果启用该功能，那么当出现SYN等待排队溢出时，则使用Cookies来处理

net.core.somaxconn = 262144                    

#默认值32768 Web应用中listen函数的backlog默认会将内核参数的net.core.somaxconn限制到128，而Nginx定义的NGX_LISTEN_BACKLOG默认为511，所以有必要调整这个值

net.core.netdev_max_backlog = 262144      

#默认值300 设置被输送到队列数据包的最大数目，在网卡接收数据包的速率比内核处理数据包的速率快时，那么会出现排队现象，这个参数就是用于设置该队列的大小

net.ipv4.tcp_max_orphans = 262144          

#默认值32768 设置Linux能够处理不属于任何进程的套接字数量，所谓不属于任何进程的进程就是“孤儿”（orphan）进程，在快速、大量的连接中这种进程会很多，因此要适当地设置该参数，如果这种“孤儿”进程套接字数量大于这个指定的值，那么在使用dmesg查看时会出现“too many of orphaned sockets”的警告

net.ipv4.tcp_max_syn_backlog = 262144    

#默认值1024 记录尚未收到客户端确认信息的连接请求的最大值

net.ipv4.tcp_timestamps = 0                      

#默认值1 设置使用时间戳作为序列号，通过这样的设置可以避免序列号倍重复使用。在高速、高并发的环境中，这种情况是存在的，因此通过时间戳能够让这些被看做是异常的数据包被内核接收。0表示关闭

net.ipv4.tcp_synack_retries = 1                  

#默认值5 设置SYN重试的次数，在TCP的3次握手中的第二次握手，内核需要发送一个回应前面一个SYN的ACK的SYN，就是说为了打开对方的连接，内核发出的SYN的次数。减小该参数的值有利于避免DDoS攻击。

net.ipv4.tcp_syn_retries = 1                      

#默认值5 设置在内核放弃建立连接之前发送SYN包的数量

net.ipv4.tcp_fin_timeout = 1                        

#默认值60 表示如果套接字由本端要求关闭，这个参数决定了它保持在FIN-WAIT-2状态的时间。对端可以出错并永远不关闭连接，甚至意外宕机。可以按此设置，但是要记住的是，即使是一个轻载的Web服务器，也有因为大量的死套接字而内存溢出的风险，FIN-WAIT-2的危险性比FIN-WAIT-1要小，因为它最多只能消耗1.5KB的内存，但是他的生存期要长些。

net.ipv4.tcp_keepalive_time = 30                

#默认值7200 当启用keepalive的时候，设置TCP发送keepalive消息的频度。


4.优化nginx服务器

4.1 关闭访问日志（必须要记录的时候可以有选择的记录）

4.2 使用epon

   这是在Linux下必选的模型，但是epoll只能使用于Linux内核2.6版本及以后的系统，对于我们现在使用的Linux系统这不是问题，从RedHat4 以后的系统都是2.6内核了。

4.3 Nginx服务器配置优化

   worker_connections 65535

   keepalived_timeout 60

   client_header_buffer_size 8k (通过“getconf PAGESIZE”命令来获取页面的大小)

   worker_rlimit_nofile 65535


