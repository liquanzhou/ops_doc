Zabbix触发器支持的函数说明

http://pengyao.org/zabbix-triggers-functions.html

2013-05-06 by pengyao

    原文出处: https://www.zabbix.com/documentation/2.0/manual/appendix/triggers/functions
    译者: pengyao

abschange

    参数: 直接忽略后边的参数
    支持值类型: float, int, str, text, log
    描述: 返回最近获取到的值与之前的值的差值的绝对值. 对于字符串类型，0表示值相等，1表示值不同

avg

    参数: 秒或#num
    支持值类型: float, int
    描述: 返回指定时间间隔的平均值. 时间间隔可以通过第一个参数通过秒数设置或收集的值的数目(需要前边加上#,比如#5表示最近5次的值) 。如果有第二个，则表示时间漂移(time shift),例如像查询一天之前的一小时的平均值，对应的函数是 avg(3600,86400), 时间漂移是Zabbix 1.8.2加入进来的

change

    参数: 直接忽略掉后边的参数
    支持值类型: float, int, str, text, log
    描述: 返回最近获取到的值与之前的值的差值. 对于字符串类型，0表示值相等，1表示值不同

count

    参数: 秒或#num
    支持值类型: float, int, str, text, log
    描述: 返回指定时间间隔内的数值统计。 时间间隔可以通过第一个参数通过秒数设置或收集的值数目（需要值前边加上#）。本函数可以支持第二个参数作为样本(pattern)数据，第三个参数作为操作(operator)参数，第四个参数作为时间漂移(time shift)参数. 对于样本，整数(iteeger)监控项实用精确匹配，浮点型(float)监控项允许偏差0.0000001

支持的操作(operators)类型:

  eq: 相等
  ne: 不相等 
  gt: 大于
  ge: 大于等于
  lt: 小于
  le: 小于等于
  like: 内容匹配

对于整数和浮点型监控项目支持eq(默认), ne, gt, ge, lt, le；对于string、text、log监控项支持like(默认), eq, ne

例子:

  count(600): 最近10分钟的值的个数
  count(600,12): 最近10分钟，值等于12的个数
  count(600,12,"gt"): 最近10分钟，值大于12的个数
  count(#10,12,"gt"): 最近的10个值中，值大于12的个数
  count(600,12,"gt",86400): 24小时之前的前10分钟数据中，值大于12的个数
  count(600,,,86400): 24小时之前的前10分钟数据的值的个数

#num参数从Zabbix 1.6.1起开始支持, time shift参数和字符串操作支持从Zabbix 1.8.2开始支持
date

    参数: 直接忽略掉后边的参数
    支持值类型: 所有(any)
    描述: 返回当前日期(格式为YYYYMMDD), 例如20031025

dayofmonth

    参数: 直接忽略掉后边的参数
    支持值类型: 所有(any)
    描述: 返回当前是本月第几天(数值范围:1-31)，该函数从Zabbix 1.8.5起开始支持

dayofweek

    参数: 直接忽略掉后边的参数
    支持值类型: 所有(any)
    描述: 返回当前是本周的第几天(数值返回:1-7)，星期一是 1，星期天是7

delta

    参数: 秒或#num
    支持值类型: float, int
    描述: 返回指定时间间隔内的最大值与最小值的差值(max()-min())。时间间隔作为第一个参数可以是秒或者收集值的数目. 从Zabbix 1.8.2开始，支持可选的第二个参数 time_shift.

diff

    参数: 忽略
    支持值类型: float, int, str, text, log
    描述: 返回值为1 表示最近的值与之前的值不同，0为其他情况

fuzzytime

    参数: 秒
    支持值类型: float, int
    描述: 返回值为1表示监控项值的时间戳与Zabbix Server的时间多N秒, 0为其他. 常使用system.localtime来检查本地时间是否与Zabbix server时间相同.

iregexp

    参数: 第一个为字符串，第二个为秒或#num
    支持值类型: str, log, text
    描述: 与regexp类似，区别是不区分大小写

last

    参数: 秒或#num
    支持值类型: float, int, str, text, log
    描述: 最近的值，如果为秒，则忽略，#num表示最近第N个值，请注意当前的#num和其他一些函数的#num的意思是不同的

例子:

last(0) 等价于 last(#1)
last(#3) 表示最近**第**3个值(并不是最近的三个值)
本函数也支持第二个参数**time_shift**，例如
last(0,86400) 返回一天前的最近的值
如果在history中同一秒中有多个值存在，Zabbix不保证值的精确顺序
#num从Zabbix 1.6.2起开始支持, timeshift从1.8.2其开始支持,可以查询 avg()函数获取它的使用方法

logeventid

    参数: string
    支持值类型: log
    描述: 检查最近的日志条目的Event ID是否匹配正则表达式. 参数为正则表达式,POSIX扩展样式. 当返回值为0时表示不匹配，1表示匹配。 该函数从Zabbix 1.8.5起开始支持.

logseverity

    参数: 忽略
    支持值类型: log
    描述: 返回最近日志条目的日志等级(log severity). 当返回值为0时表示默认等级，N为具体对应等级(整数，常用于Windows event logs). Zabbix日志等级来源于Windows event log的Information列.

logsource

    参数: string
    支持值类型: log
    描述: 检查最近的日志条目是否匹配参数的日志来源. 当返回值为0时表示不匹配，1表示匹配。通场用于Windows event logs监控. 例如 logsource["VMWare Server"]

max

    参数: 秒或#num
    支持值类型: float, int
    描述: 返回指定时间间隔的最大值. 时间间隔作为第一个参数可以是秒或收集值的数目(前缀为#). 从Zabbix 1.8.2开始，函数支持第二个可选参数 time_shift，可以查看avg()函数获取它的使用方法.

min

    参数: 秒或#num
    支持值类型: float, int
    描述: 返回指定时间间隔的最小值. 时间间隔作为第一个参数可以是秒或收集值的数目(前缀为#). 从Zabbix 1.8.2开始，函数支持第二个可选参数 time_shift，可以查看avg()函数获取它的使用方法.

nodata

    参数: 秒
    支持值类型: any
    描述: 当返回值为1表示指定的间隔(间隔不应小于30秒)没有接收到数据, 0表示其他.

now

    参数: 忽略
    支持值类型: any
    描述: 返回距离Epoch(1970年1月1日 00:00:00 UTC)时间的秒数

prev

    参数: 忽略
    支持值类型: float, int, str, text, log
    描述:返回之前的值，类似于 last(#2)

regexp

    参数: 第一个参数为string, 第二个参数为秒或#num
    支持值类型: str, log, text
    描述: 检查最近的值是否匹配正则表达式，参数的正则表达式为POSIX扩展样式, 第二个参数为秒数或收集值的数目，将会处理多个值. 本函数区分大小写。当返回值为1时表示找到，0为其他.

str

    参数: 第一个参数为string, 第二个参数为秒或#num
    支持值类型: str, log, text
    描述: 查找最近值中的字符串。第一个参数指定查找的字符串，大小写敏感。第二个可选的参数指定秒数或收集值的数目，将会处理多个值。 当返回值为1时表示找到，0为其他.

strlen

    参数: 秒或#num
    支持值类型: str, log, text
    描述: 指定最近值的字符串长度(并非字节), 参数值类似于last函数. 例如strlen(0)等价于strlen(#1),strlen(#3)表示最近的第三个值, strlen(0,86400)表示一天前的最近的值. 该函数从Zabbix 1.8.4起开始支持

sum

    参数: 秒或#num
    支持值类型: float, int
    描述: 返回指定时间间隔中收集到的值的总和. 时间间隔作为第一个参数支持秒或收集值的数目(以#开始). 从Zabbix 1.8.2开始，本函数支持time_shift作为第二个参数。 可以查看avg函数获取它的用法

time

    参数: 忽略
    支持值类型: any
    描述: 返回当前时间，格式为HHMMSS，例如123055
