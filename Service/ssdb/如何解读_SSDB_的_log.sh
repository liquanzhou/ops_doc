如何解读 SSDB 的 log


一般, 建议你将 logger.level 设置为 debug 级别.
请求处理

2014-06-18 11:01:40.335 [DEBUG] serv.cpp(395): w:0.393,p:5.356, req: set a 1, resp: ok 1

    w:0.393 请求的排队时间, 毫秒
    p:0.393 请求的处理时间, 毫秒
    req:… 请求内容
    resp:… 响应内容

找出慢请求

找出慢请求的命令是:

tail -f log.txt | grep resp | grep '[wp]:[1-9][0-9]\{0,\}\.'
# 或者
cat log.txt | grep resp | grep '[wp]:[1-9][0-9]\{0,\}\.'

这些命令用于找出排队时间, 或者处理时间大于等于 1 毫秒的请求.

找出大于 10 毫秒的请求:

cat log.txt | grep resp | grep '[wp]:[1-9][0-9]\{1,\}\.'

找出大于 100 毫秒的请求:

cat log.txt | grep resp | grep '[wp]:[1-9][0-9]\{2,\}\.'

SSDB 在工作中

ssdb-server 会每隔 5 分钟输出这样的一条 log

2014-06-18 11:18:03.600 [INFO ] ssdb-server.cpp(215): ssdb working, links: 0
2014-06-18 11:23:03.631 [INFO ] ssdb-server.cpp(215): ssdb working, links: 0

    links: 0 当前的连接数

原文: http://ssdb.io/docs/zh_cn/logs.html
Related posts:

    SSDB 配置文件
    在PHP代码中使用LevelDB
    SSDB 数据库的图形化界面管理工具 – phpssdbadmin
    热烈庆祝SSDB获得2014中国开源优秀项目奖!

Posted by ideawu at 2014-06-18 11:56:07 