
telnet 10.13.81.17 20004
stats

stats 命令的功能正如其名：转储所连接的 memcached 实例的当前统计数据。在下例中，执行 stats 命令显示了关于当前 memcached 实例的信息：

STAT pid 22459                             进程ID
STAT uptime 1027046                        服务器运行秒数
STAT time 1273043062                       服务器当前unix时间戳
STAT version 1.4.4                         服务器版本
STAT pointer_size 64                       操作系统字大小(这台服务器是64位的)
STAT rusage_user 0.040000                  进程累计用户时间
STAT rusage_system 0.260000                进程累计系统时间
STAT curr_connections 10                   当前打开连接数
STAT total_connections 82                  曾打开的连接总数
STAT connection_structures 13              服务器分配的连接结构数
STAT cmd_get 54                            执行get命令总数
STAT cmd_set 34                            执行set命令总数
STAT cmd_flush 3                           指向flush_all命令总数
STAT get_hits 9                            get命中次数
STAT get_misses 45                         get未命中次数
STAT delete_misses 5                       delete未命中次数
STAT delete_hits 1                         delete命中次数
STAT incr_misses 0                         incr未命中次数
STAT incr_hits 0                           incr命中次数
STAT decr_misses 0                         decr未命中次数
STAT decr_hits 0                           decr命中次数
STAT cas_misses 0    cas未命中次数
STAT cas_hits 0                            cas命中次数
STAT cas_badval 0                          使用擦拭次数
STAT auth_cmds 0
STAT auth_errors 0
STAT bytes_read 15785                      读取字节总数
STAT bytes_written 15222                   写入字节总数
STAT limit_maxbytes 1048576                分配的内存数（字节）
STAT accepting_conns 1                     目前接受的链接数
STAT listen_disabled_num 0                
STAT threads 4                             线程数
STAT conn_yields 0
STAT bytes 0                               存储item字节数
STAT curr_items 0                          item个数
STAT total_items 34                        item总数
STAT evictions 0                           为获取空间删除item的总数


