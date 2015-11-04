命令行查看Memcached运行状态

# memcached-tool是perl写的

telnet 127.0.0.1 11211
> stats    # 即可得到描述Memcached服务器运行情况的参数
 
uptime     # 是memcached运行的秒数
cmd_get    # 是查询缓存的次数。
cmd_set    # 是设置key=>value的次数。整个memcached是个大hash，用cmd_get没有找到的内容，就会调用一下cmd_set写进缓存里。
get_hits   # 是缓存命中的次数。
get_misses # 读取失败的次数
total_itemscurr_items       # 表示现在在缓存中的键值对个数

# uptime 和 cmd_get 这两个数据相除一下就能得到平均每秒请求缓存的次数
# get_misses 加上 get_hits 应该等于 cmd_get
# total_items == cmd_set == get_misses  # 不过当可用最大内存用光时，memcached就会删掉一些内容，等式就不成立了

缓存命中率 = get_hits / cmd_get = get_hits / (get_hits + get_misses)


telnet到memcached服务器的赋值命令: add、get、set、incr、decr、replace、delete 等
Memcache::getStats($cmd)   # PHP访问memcached命令

Memcached的获取服务器信息的 stats 命令

stats         # 显示服务器信息、统计数据等
stats reset   # 清空统计数据
stats malloc  # 显示内存分配数据
stats cachedump slab_id limit_num      # 显示某个slab中的前limit_num个key列表，显示格式如下
ITEM key_name [ value_length b; expire_time|access_time s]
其中，memcached 1.2.2及以前版本显示的是  访问时间(timestamp)
1.2.4以上版本，包括1.2.4显示 过期时间(timestamp)
如果是永不过期的key，expire_time会显示为服务器启动的时间

stats cachedump 7 2
ITEM copy_test1 [250 b; 1207795754 s]
ITEM copy_test [248 b; 1207793649 s]

stats slabs    # 显示各个slab的信息，包括chunk的大小、数目、使用情况等
stats items    # 显示各个slab中item的数目和最老item的年龄(最后一次访问距离现在的秒数)
stats detail [on|off|dump]    # 设置或者显示详细操作记录
# on    打开详细操作记录
# off   关闭详细操作记录
# dump  显示详细操作记录(每一个键值get、set、hit、del的次数)

stats detail dump
PREFIX copy_test2 get 1 hit 1 set 0 del 0
PREFIX copy_test1 get 1 hit 1 set 0 del 0
PREFIX cpy get 1 hit 0 set 0 del 0


slab是Linux操作系统的一种内存分配机制。其工作是针对一些经常分配并释放的对象，如进程描述符等，这些对象的大小一般比较小，如果直接采用伙伴系统来进行分配和释放，不仅会造成大量的内碎片，而且处理速度也太慢。而slab分配器是基于对象进行管理的，相同类型的对象归为一类(如进程描述符就是一类)，每当要申请这样一个对象，slab分配器就从一个slab列表中分配一个这样大小的单元出去，而当要释放时，将其重新保存在该列表中，而不是直接返回给伙伴系统，从而避免这些内碎片。slab分配器并不丢弃已分配的对象，而是释放并把它们保存在内存中。当以后又要请求新的对象时，就可以从内存直接获取而不用重复初始化。

slab 分配器首先从部分空闲的slab 进行分配。如没有，则从空的slab 进行分配。如没有，则从物理连续页上分配新的slab，并把它赋给一个cache ，然后再从新slab 分配空间。
Linux 的slab 可有三种状态：
    满的：slab 中的所有对象被标记为使用。
    空的：slab 中的所有对象被标记为空闲。
    部分：slab 中的对象有的被标记为使用，有的被标记为空闲。
