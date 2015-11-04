Tair集群配置安装

Tair是一个高性能，分布式，可扩展，高可靠的key/value结构存储系统！

一 如何安装tair:

    确保安装了automake autoconfig 和 libtool,使用automake --version查看，一般情况下已安装
    获得底层库 tbsys 和 tbnet的源代码:(svn checkout http://code.taobao.org/svn/tb-common-utils/trunk/ tb-common-utils).
    获得tair源代码:(svn checkout http://code.taobao.org/svn/tair/trunk/ tair).
    安装boost-devel库，在用rpm管理软件包的os上可以使用rpm -q boost-devel查看是否已安装该库
    编译安装tbsys和tbnet
    编译安装tair


        tair 的底层依赖于tbsys库和tbnet库, 所以要先编译安装这两个库:

    取得源代码后, 先指定环境变量 TBLIB_ROOT 为需要安装的目录. 这个环境变量在后续 tair 的编译安装中仍旧会被使用到. 比如要安装到当前用户的lib目录下, 则指定 export TBLIB_ROOT="~/lib"
    进入common文件夹, 执行build.sh进行安装. 

        编译安装tair:

    进入 tair 目录
    运行 bootstrap.sh
    运行 configure.  注意, 在运行configue的时候, 可以使用 --with-boost=xxxx 来指定boost的目录. 使用--with-release=yes 来编译release版本.
    运行 make 进行编译
    运行 make install 进行安装

二 如何配置tair:

        tair的运行, 至少需要一个 config server 和一个 data server. 推荐使用两个 config server 多个data server的方式. 两个config server有主备之分.
    源代码目录中 share 目录下有三个配置文件的样例, 下面会逐个解说.
    configserver.conf  group.conf 这两个配置文件是config server所需要的. 先看这两个配置文件的配置

        配置文件 configserver.conf


    [public]
    config_server=x.x.x.x:5198
    config_server=x.x.x.x:5198
    
    [configserver]
    port=5198
    log_file=logs/config.log
    pid_file=logs/config.pid
    log_level=warn
    group_file=etc/group.conf
    data_dir=data/data
    dev_name=eth0

    public 下面配置的是两台config server的 ip 和端口. 其中排在前面的是主config server. 这一段信息会出现在每一个配置文件中. 请保持这一段信息的严格一致.
    configserver下面的内容是本config server的具体配置:
    port 端口号, 注意 config server会使用该端口做为服务端口, 而使用该端口+1 做为心跳端口
    log_file 日志文件
    pid_file  pid文件, 文件中保存当前进程中的pid
    log_level 日志级别
    group_file 本config server所管理的 group 的配置文件
    data_dir   本config server自身数据的存放目录
    dev_name   所使用的网络设备名
    
    注意: 例子中, 所有的路径都配置的是相对路径. 这样实际上限制了程序启动时候的工作目录. 这里当然可以使用绝对路径. 
    注意: 程序本身可以把多个config server 或 data server跑在一台主机上, 只要配置不同的端口号就可以. 但是在配置文件的时候, 他们的数据目录必须分开, 程序不会对自己的数据目录加锁, 所以如果跑在同一主机上的服务, 数据目录配置相同, 程序自己不会发现, 却会发生很多莫名其妙的错误. 多个服务跑在同一台主机上, 一般只是在做功能测试的时候使用.

        配置文件 group.conf


    #group name
    [group_1]
    # data move is 1 means when some data serve down, the migrating will be start.
    # default value is 0
    _data_move=1
    #_min_data_server_count: when data servers left in a group less than this value, config server will stop serve for this group
    #default value is copy count.
    _min_data_server_count=4
    _copy_count=3
    _bucket_number=1023
    _plugIns_list=libStaticPlugIn.so
    _build_strategy=1 #1 normal 2 rack
    _build_diff_ratio=0.6 #how much difference is allowd between different rack
    # diff_ratio =  |data_sever_count_in_rack1 - data_server_count_in_rack2| / max (data_sever_count_in_rack1, data_server_count_in_rack2)
    # diff_ration must less than _build_diff_ratio
    _pos_mask=65535  # 65535 is 0xffff  this will be used to gernerate rack info. 64 bit serverId & _pos_mask is the rack info,
    
    _server_list=x.x.x.x:5191
    _server_list=x.x.x.x:5191
    _server_list=x.x.x.x:5191
    _server_list=x.x.x.x:5191
    #quota info
    _areaCapacity_list=1,1124000;   
    _areaCapacity_list=2,1124000;  
    
     每个group配置文件可以配置多个group, 这样一组config server就可以同时服务于多个 group 了. 不同的 group 用group name区分
     _data_move 当这个配置为1的时候, 如果发生了某个data server宕机, 则系统会尽可能的通过冗余的备份对数据进行迁移. 注意, 如果 copy_count 为大于1的值, 则这个配置无效, 系统总是会发生迁移的. 只有copy_count为1的时候, 该配置才有作用. 
     _min_data_server_count  这个是系统中需要存在的最少data server的个数.  当系统中可正常工作的data server的个数小于这个值的时候, 整个系统会停止服务, 等待人工介入
     _copy_count  这个表示一条数据在系统中实际存储的份数. 如果tair被用作缓存, 这里一般配置1. 如果被用来做存储, 一般配置为3。 当系统中可工作的data server的数量少于这个值的时候, 系统也会停止工作. 比如 _copy_count 为3, 而系统中只有 2 台data server. 这个时候因为要求一条数据的各个备份必须写到不同的data server上, 所以系统无法完成写入操作, 系统也会停止工作的.
     _bucket_number  这个是hash桶的个数, 一般要 >> data server的数量(10倍以上). 数据的分布, 负载均衡, 数据的迁移都是以桶为单位的.
     _plugIns_list  需要加载的插件的动态库名
     _accept_strategy  默认为0，ds重新连接上cs的时候，需要手动touch group.conf。如果设置成1，则当有ds重新连接会cs的时候，不需要手动touch group.conf。 cs会自动接入该ds。
     _build_strategy  在分配各个桶到不同的data server上去的时候所采用的策略. 目前提供两种策略. 配置为1 则是负载均衡优先, 分配的时候尽量让各个 data server 的负载均衡. 配置为 2 的时候, 是位置安全优先, 会尽量将一份数据的不同备份分配到不同机架的机器上. 配置为3的时候，如果服务器分布在多个机器上，那么会优先使用位置安全优先，即策略2. 如果服务器只在一个机架上，那么退化成策略1，只按负载分布。
     _build_diff_ratio 这个值只有当 _build_strategy 为2的时候才有意义. 实际上是用来表示不同的机架上机器差异大小的. 当位置安全优先的时候, 如果某个机架上的机器不断的停止服务, 必然会导致负载的极度不平衡.  当两个机架上机器数量差异达到一定程度的时候, 系统也不再继续工作, 等待人工介入.
     _pos_mask  机架信息掩码. 程序使用这个值和由ip以及端口生成的64为的id做与操作, 得到的值就认为是位置信息.  比如 当此值是65535的时候 是十六进制 0xffff. 因为ip地址的64位存储的时候采用的是网络字节序, 最前32位是端口号, 后32位是网络字节序的ip地址. 所以0xffff 这个配置, 将认为10.1.1.1 和 10.2.1.1 是不同的机架.
     _areaCapacity_list  这是每一个area的配额信息. 这里的单位是 byte. 需要注意的是, 该信息是某个 area 能够使用的所有空间的大小. 举个具体例子:当copy_count为3 共有5个data server的时候, 每个data server上, 该area实际能使用的空间是这个值/(3 * 5). 因为fdb使用mdb作为内部的缓存, 这个值的大小也决定了缓存的效率.

        data server的配置文件


    [public]
    config_server=172.23.16.225:5198
    config_server=172.23.16.226:5198

    [tairserver]
    storage_engine=mdb
    mdb_type=mdb_shm
    mdb_shm_path=/mdb_shm_path01
    #tairserver listen port
    port=5191
    heartbeat_port=6191
    process_thread_num=16
    slab_mem_size=22528
    log_file=logs/server.log
    pid_file=logs/server.pid
    log_level=warn
    dev_name=bond0
    ulog_dir=fdb/ulog
    ulog_file_number=3
    ulog_file_size=64
    check_expired_hour_range=2-4
    check_slab_hour_range=5-7

    [fdb]
    # in
    # MB
    index_mmap_size=30
    cache_size=2048
    bucket_size=10223
    free_block_pool_size=8
    data_dir=fdb/data
    fdb_name=tair_fdb


    下面解释一下data server的配置文件:
    public 部分不再解说
    storage_engine 这个可以配置成 fdb 或者 mdb.  分别表示是使用内存存储数据(mdb)还是使用磁盘(fdb).
    mdb_type 这个是兼容以前版本用的, 现在都配成mdb_shm就可以了
    mdb_shm_path 这个是用作映射共享内存的文件.
    port data server的工作端口
    heartbeat_port data server的心跳端口
    process_thread_num 工作线程数.  实际上启动的线程会比这个数值多, 因为有一些后台线程.  真正处理请求的线程数量是这里配置的.
    slab_mem_size 所占用的内存数量.  这个值以M为单位, 如果是mdb, 则是mdb能存放的数据量, 如果是fdb, 此值无意义
    ulog_dir 发生迁移的时候, 日志文件的文件目录
    ulog_file_number 用来循环使用的log文件数目
    ulog_file_size 每个日志文件的大小, 单位是M
    check_expired_hour_range 清理超时数据的时间段.  在这个时间段内, 会运行一个后台进程来清理mdb中的超时数据.  一般配置在系统较空闲的时候
    check_slab_hour_range 对slap做平衡的时间段.  一般配置在系统较空闲的时候
    index_mmap_size fdb中索引文件映射到内存的大小, 单位是M
    cache_size fdb中用作缓存的共享内存大小, 单位是M 
    bucket_size fdb在存储数据的时候, 也是一个hash算法, 这儿就是hash桶的数目
    free_block_pool_size 这个用来存放fdb中的空闲位置, 便于重用空间
    data_dir fdb的数据文件目录
    fdb_name fdb数据文件名

三 运行前的准备:
    
    因为系统使用共享内存作为数据存储的空间(mdb)或者缓存空间(fdb), 所以需要先更改配置, 使得程序能够使用足够的共享内存.  scripts 目录下有一个脚本 set_shm.sh 是用来做这些修改的, 这个脚本需要root权限来运行.

四 如何启动集群:
    
    在完成安装配置之后, 可以启动集群了.  启动的时候需要先启动data server 然后启动cofnig server.  如果是为已有的集群添加dataserver则可以先启动dataserver进程然后再修改gruop.conf，如果你先修改group.conf再启动进程，那么需要执行touch group.conf;在scripts目录下有一个脚本 tair.sh 可以用来帮助启动 tair.sh start_ds 用来启动data server.  tair.sh start_cs 用来启动config server.  这个脚本比较简单, 它要求配置文件放在固定位置, 采用固定名称.  使用者可以通过执行安装目录下的bin下的 tair_server (data server) 和 tair_cfg_svr(config server) 来启动集群.
