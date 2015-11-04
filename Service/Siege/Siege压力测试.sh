Siege linux压力测评
2013-07-31 10:52:03
标签：Siege linux压力测评
原创作品，允许转载，转载时请务必以超链接形式标明文章 原始出处 、作者信息和本声明。否则将追究法律责任。http://2364821.blog.51cto.com/2354821/1261137


Siege
一款开源的压力测试工具，可以根据配置对一个WEB站点进行多用户的并发访问，记录每个用户所有请求过程的相应时间，并在一定数量的并发访问下重复进行。
官方：http://www.joedog.org/
Siege下载：http://soft.vpser.net/test/siege/siege-2.67.tar.gz
解压：
# tar -zxf siege-2.67.tar.gz
进入解压目录：
# cd siege-2.67/
安装：
#./configure 
# make
# make install
mkdir -p /usr/local/var/
/usr/local/var/siege.log  # 日志路径

ulimit -SHn 65535  # 修改最大打开文件数(等同最大连接数)

使用
-c  # 是并发量
-r  # 是重复次数
-f  # 指定文本，每行都是一个url，它会从里面随机访问的

siege -c 200 -r 10  http://jj01.com/   # 单个页面

#cat example.url 
http://127.0.0.1
http://127.0.0.1/index.html

siege -c 200 -r 10 -f example.url      # 多个页面

TTP/1.1 200   0.03 secs:       8 bytes ==> /
HTTP/1.1 200   0.03 secs:       8 bytes ==> /
HTTP/1.1 200   0.01 secs:       8 bytes ==> /index.html
HTTP/1.1 200   0.01 secs:       8 bytes ==> /index.html
HTTP/1.1 200   0.01 secs:       8 bytes ==> /index.html
HTTP/1.1 200   0.01 secs:       8 bytes ==> /index.html
HTTP/1.1 200   0.01 secs:       8 bytes ==> /index.html
HTTP/1.1 200   0.01 secs:       8 bytes ==> /index.html
HTTP/1.1 200   0.02 secs:       8 bytes ==> /index.html
HTTP/1.1 200   0.02 secs:       8 bytes ==> /index.html
HTTP/1.1 200   0.02 secs:       8 bytes ==> /index.html
HTTP/1.1 200   0.01 secs:       8 bytes ==> /index.html
HTTP/1.1 200   0.01 secs:       8 bytes ==> /index.html
HTTP/1.1 200   0.01 secs:       8 bytes ==> /index.html
HTTP/1.1 200   0.01 secs:       8 bytes ==> /index.html
HTTP/1.1 200   0.01 secs:       8 bytes ==> /index.html
HTTP/1.1 200   0.01 secs:       8 bytes ==> /
HTTP/1.1 200   0.01 secs:       8 bytes ==> /index.html
HTTP/1.1 200   0.01 secs:       8 bytes ==> /
HTTP/1.1 200   0.01 secs:       8 bytes ==> /index.html
HTTP/1.1 200   0.01 secs:       8 bytes ==> /
HTTP/1.1 200   0.01 secs:       8 bytes ==> /
HTTP/1.1 200   0.00 secs:       8 bytes ==> /
HTTP/1.1 200   0.00 secs:       8 bytes ==> /
HTTP/1.1 200   0.00 secs:       8 bytes ==> /index.html
HTTP/1.1 200   0.00 secs:       8 bytes ==> /
HTTP/1.1 200   0.00 secs:       8 bytes ==> /
HTTP/1.1 200   0.00 secs:       8 bytes ==> /index.html
HTTP/1.1 200   0.00 secs:       8 bytes ==> /index.html
HTTP/1.1 200   0.00 secs:       8 bytes ==> /index.html
HTTP/1.1 200   0.00 secs:       8 bytes ==> /index.html
HTTP/1.1 200   0.00 secs:       8 bytes ==> /index.html
HTTP/1.1 200   0.00 secs:       8 bytes ==> /
HTTP/1.1 200   0.00 secs:       8 bytes ==> /
HTTP/1.1 200   0.00 secs:       8 bytes ==> /
HTTP/1.1 200   0.00 secs:       8 bytes ==> /
HTTP/1.1 200   0.00 secs:       8 bytes ==> /index.html
HTTP/1.1 200   0.00 secs:       8 bytes ==> /

结果说明
Lifting the server siege… done.
Transactions: 3419263 hits          # 完成419263次处理
Availability: 100.00 % //100.00 %   # 成功率
Elapsed time: 5999.69 secs          # 总共用时
Data transferred: 84273.91 MB       # 共数据传输84273.91 MB
Response time: 0.37 secs            # 相应用时1.65秒：显示网络连接的速度
Transaction rate: 569.91 trans/sec  # 均每秒完成 569.91 次处理：表示服务器后
Throughput: 14.05 MB/sec            # 平均每秒传送数据
Concurrency: 213.42                 # 实际最高并发数
Successful transactions: 2564081    # 成功处理次数
Failed transactions: 11             # 失败处理次数
Longest transaction: 29.04          # 每次传输所花最长时间
Shortest transaction: 0.00          # 每次传输所花最短时间