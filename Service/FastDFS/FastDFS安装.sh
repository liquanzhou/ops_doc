FastDFS安装

    前面了解了fastdfs的原理，接下来就熟悉一下安装过程，准备了三台机器，一台模拟client，一台模拟storage，一台模拟tracker。
    三台机器均为debian6，系统为最小化安装，先安装基本编译环境：
    apt-get install build-essential php5-dev libevent-dev

    下载fastdfs源码包：
	wget http://fastdfs.googlecode.com/files/FastDFS_v3.05.tar.gz

     开始安装：
	tar zxvf FastDFS_v3.05.tar.gz
	cd FastDFS/
	./make.sh
	./make.sh install

    安装完成后，fastdfs默认的配置文件被放置在/etc/fdfs 目录下面，包含了client.conf  http.conf  mime.types  storage.conf  tracker.conf五个文件，fastdfs进程的启动是以加载的配置文件区分的。源码包中都包含了这三个配置文件。

   tracker.conf 配置文件分析：

#配置tracker.conf这个配置文件是否生效，因为在启动fastdfs服务端进程时需要指定配置文件，所以需要使次配置文件生效。false是生效，true是屏蔽。
disabled=false

#程序的监听地址，如果不设定则监听所有地址
bind_addr=

#tracker监听的端口
port=22122

#链接超时设定
connect_timeout=30

#tracker在通过网络发送接收数据的超时时间
network_timeout=60

#数据和日志的存放地点
base_path=/opt/fdfs

#服务所支持的最大链接数
max_connections=256

#工作线程数一般为cpu个数
work_threads=4

#在存储文件时选择group的策略，0:轮训策略 1:指定某一个组 2:负载均衡，选择空闲空间最大的group
store_lookup=2

#如果上面的store_lookup选择了1，则这里需要指定一个group
#store_group=group2

#在group中的哪台storage做主storage，当一个文件上传到主storage后，就由这台机器同步文件到group内的其他storage上，0：轮训策略 1：根据ip地址排序，第一个 2:根据优先级排序，第一个
store_server=0

#选择那个storage作为主下载服务器，0:轮训策略 1:主上传storage作为主下载服务器
download_server=0

#选择文件上传到storage中的哪个(目录/挂载点),storage可以有多个存放文件的base path 0:轮训策略 2:负载均衡，选择空闲空间最大的
store_path=0

#系统预留空间，当一个group中的任何storage的剩余空间小于定义的值，整个group就不能上传文件了
reserved_storage_space = 4GB

#日志信息级别
log_level=info

#进程以那个用户/用户组运行，不指定默认是当前用户
run_by_group=
run_by_user=

#允许那些机器连接tracker默认是所有机器
allow_hosts=*

#设置日志信息刷新到disk的频率，默认10s
sync_log_buff_interval = 10

#检测storage服务器的间隔时间，storage定期主动向tracker发送心跳，如果在指定的时间没收到信号，tracker人为storage故障，默认120s
check_active_interval = 120

#线程栈的大小，最小64K
thread_stack_size = 64KB

#storage的ip改变后服务端是否自动调整，storage进程重启时才自动调整
storage_ip_changed_auto_adjust = true

#storage之间同步文件的最大延迟，默认1天
storage_sync_file_max_delay = 86400

#同步一个文件所花费的最大时间
storage_sync_file_max_time = 300

#是否用一个trunk文件存储多个小文件
use_trunk_file = false

#最小的solt大小，应该小于4KB，默认256bytes
slot_min_size = 256

#最大的solt大小，如果上传的文件小于默认值，则上传文件被放入trunk文件中
slot_max_size = 16MB

#trunk文件的默认大小，应该大于4M
trunk_file_size = 64MB

#http服务是否生效，默认不生效
http.disabled=false

#http服务端口
http.server_port=8080

#检测storage上http服务的时间间隔，<=0表示不检测
http.check_alive_interval=30

#检测storage上http服务时所用请求的类型，tcp只检测是否可以连接，http必须返回200
http.check_alive_type=tcp

#通过url检测storage http服务状态
http.check_alive_uri=/status.html

#if need find content type from file extension name
http.need_find_content_type=true

#用include包含进http的其他设置
##include http.conf

    启动tracker进程
	fdfs_trackerd /etc/fdfs/tracker.conf

    检测状态

	netstat -tupln|grep tracker
	#可以看到如下：
	tcp  0   0   0.0.0.0:22122   0.0.0.0:*   LISTEN   18559/fdfs_trackerd

    storage.conf配置文件分析：

#同tracker.conf
disabled=false

#这个storage服务器属于那个group
group_name=group1

#同tracker.conf
bind_addr=

#连接其他服务器时是否绑定地址，bind_addr配置时本参数才有效
client_bind=true

#同tracker.conf
port=23000
connect_timeout=30
network_timeout=60

#主动向tracker发送心跳检测的时间间隔
heart_beat_interval=30

#主动向tracker发送磁盘使用率的时间间隔
stat_report_interval=60

#同tracker.conf
base_path=/opt/fdfs
max_connections=256

#接收/发送数据的buff大小，必须大于8KB
buff_size = 256KB

#同tracker.conf
work_threads=4

#磁盘IO是否读写分离
disk_rw_separated = true

#是否直接读写文件，默认关闭
disk_rw_direct = false

#混合读写时的读写线程数
disk_reader_threads = 1
disk_writer_threads = 1

#同步文件时如果binlog没有要同步的文件，则延迟多少毫秒后重新读取，0表示不延迟
sync_wait_msec=50

#同步完一个文件后间隔多少毫秒同步下一个文件，0表示不休息直接同步
sync_interval=0

#表示这段时间内同步文件
sync_start_time=00:00
sync_end_time=23:59

#同步完多少文件后写mark标记
write_mark_file_freq=500

#storage在存储文件时支持多路径，默认只设置一个
store_path_count=1

#配置多个store_path路径，从0开始，如果store_path0不存在，则base_path必须存在
store_path0=/opt/fdfs
#store_path1=/opt/fastdfs2

#subdir_count  * subdir_count个目录会在store_path下创建，采用两级存储
subdir_count_per_path=256

#设置tracker_server
tracker_server=x.x.x.x:22122

#同tracker.conf
log_level=info
run_by_group=
run_by_user=
allow_hosts=*

#文件在数据目录下的存放策略，0:轮训 1:随机
file_distribute_path_mode=0

#当问及是轮训存放时，一个目录下可存放的文件数目
file_distribute_rotate_count=100

#写入多少字节后就开始同步，0表示不同步
fsync_after_written_bytes=0

#刷新日志信息到disk的间隔
sync_log_buff_interval=10

#同步storage的状态信息到disk的间隔
sync_stat_file_interval=300

#线程栈大小
thread_stack_size=512KB

#设置文件上传服务器的优先级，值越小越高
upload_priority=10

#是否检测文件重复存在，1:检测 0:不检测
check_file_duplicate=0

#当check_file_duplicate设置为1时，次值必须设置
key_namespace=FastDFS

#与FastDHT建立连接的方式 0:短连接 1:长连接
keep_alive=0

#同tracker.conf
http.disabled=false
http.domain_name=
http.server_port=8888
http.trunk_size=256KB
http.need_find_content_type=true
##include http.conf

    启动storage进程
	fdfs_storaged /etc/fdfs/storage.conf

    检测状态
	netstat -tupln | grep storage
	#结果如下：
	tcp  0  0 0.0.0.0:23000  0.0.0.0:*   LISTEN   17138/fdfs_storaged

    client.conf配置文件分析：
	#同tracker.conf
	connect_timeout=30
	network_timeout=60
	base_path=/opt/fdfs
	tracker_server=x.x.x.x:22122
	log_level=info
	http.tracker_server_port=8080

测试上传文件：

	fdfs_upload_file /etc/fdfs/client.conf client.conf
	#返回如下字符串
	group1/M00/00/00/CgEGflAqaFW4hENaAAACo8wrbSE16.conf

    在storage的数据目录下的00/00目录下即可看到该文件，文件名称是CgEGflAqaFW4hENaAAACo8wrbSE16.conf 