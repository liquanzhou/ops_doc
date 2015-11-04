 Mysql慢查询和慢查询日志分析

众所周知，大访问量的情况下，可添加节点或改变架构可有效的缓解数据库压力，不过一切的原点，都是从单台mysql开始的。下面总结一些使用过或者研究过的经验，从配置以及调节索引的方面入手，对mysql进行一些优化。
第一步应该做的就是排查问题，找出瓶颈，所以，先从日志入手
开启慢查询日志
mysql>show variables like “%slow%”; 查看慢查询配置，没有则在my.cnf中添加，如下

log-slow-queries = /data/mysqldata/slowquery.log    #日志目录
long_query_time = 1                          #记录下查询时间查过1秒
log-queries-not-using-indexes     #表示记录下没有使用索引的查询

分析日志 – mysqldumpslow
分析日志，可用mysql提供的mysqldumpslow，使用很简单，参数可–help查看

# -s：排序方式。c , t , l , r 表示记录次数、时间、查询时间的多少、返回的记录数排序；
#                             ac , at , al , ar 表示相应的倒叙；
# -t：返回前面多少条的数据；
# -g：包含什么，大小写不敏感的；
mysqldumpslow -s r -t 10  /slowquery.log     #slow记录最多的10个语句
mysqldumpslow -s t -t 10 -g "left join"  /slowquery.log     #按照时间排序前10中含有"left join"的



推荐用分析日志工具 – mysqlsla

wget http://hackmysql.com/scripts/mysqlsla-2.03.tar.gz
tar zvxf mysqlsla-2.03.tar.gz
cd mysqlsla-2.03
perl Makefile.PL
make
make install
mysqlsla /data/mysqldata/slow.log
# mysqlsla会自动判断日志类型，为了方便可以建立一个配置文件“~/.mysqlsla”
# 在文件里写上：top=100，这样会打印出前100条结果。

【说明】
queries total: 总查询次数 unique:去重后的sql数量
sorted by : 输出报表的内容排序
最重大的慢sql统计信息, 包括 平均执行时间, 等待锁时间, 结果行的总数, 扫描的行总数.
Count, sql的执行次数及占总的slow log数量的百分比.
Time, 执行时间, 包括总时间, 平均时间, 最小, 最大时间, 时间占到总慢sql时间的百分比.
95% of Time, 去除最快和最慢的sql, 覆盖率占95%的sql的执行时间.
Lock Time, 等待锁的时间.
95% of Lock , 95%的慢sql等待锁时间.
Rows sent, 结果行统计数量, 包括平均, 最小, 最大数量.
Rows examined, 扫描的行数量.
Database, 属于哪个数据库
Users, 哪个用户,IP, 占到所有用户执行的sql百分比
Query abstract, 抽象后的sql语句
Query sample, sql语句

http://www.auu.name/716/index.html