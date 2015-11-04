mysql慢查询日志

这是一个有用的日志。它对于性能的影响不大（假设所有查询都很快），并且强调了那些最需要注意的查询（丢失了索引或索引没有得到最佳应用）
mysql慢查询日志对于跟踪有问题的查询非常有用,可以分析出当前程序里有很耗费资源的sql语句,那如何打开mysql的慢查询日志记录呢?
其实打开mysql的慢查询日志很简单,只需要在mysql的配置文件里(windows系统是my.ini,linux系统是my.cnf)的[mysqld]下面加上如下代码：

log-slow-queries=/var/lib/mysql/slowquery.log
long_query_time=2

1，配置开启

在mysql配置文件my.cnf中增加

log-slow-queries=/var/lib/mysql/slowquery.log       # 指定日志文件存放位置，可以为空，系统会给一个缺省的文件host_name-slow.log
long_query_time=2                     # 记录超过的时间，默认为10s
log-queries-not-using-indexes         # log下来没有使用索引的query,可以根据情况决定是否开启
log-long-format                       # 如果设置了，所有没有使用索引的查询也将被记录 

2,查看方式
使用mysql自带命令mysqldumpslow查看
-s  # 是order的顺序，包括看了代码，主要有 c,t,l,r和ac,at,al,ar，分别是按照query次数，时间，lock的时间和返回的记录数来排序，前面加了a的时倒序 
-t  # 是top n的意思，即为返回前面多少条的数据 
-g  # 后边可以写一个正则匹配模式，大小写不敏感的
 
mysqldumpslow -s c -t 20 host-slow.log   # 访问次数最多的20个sql语句
mysqldumpslow -s r -t 20 host-slow.log   # 返回记录集最多的20个sql
mysqldumpslow -t 10 -s t -g "left join" host-slow.log    # 按照时间返回前10条里面含有左连接的sql语句


show global status like '%slow%'; # 查看现在这个session有多少个慢查询
show variables like '%slow%';     # 查看慢查询日志是否开启，如果slow_query_log和log_slow_queries显示为on，说明服务器的慢查询日志已经开启
show variables like '%long%';     # 查看超时阀值
create index text_index on wei(text);   # 创建索引









