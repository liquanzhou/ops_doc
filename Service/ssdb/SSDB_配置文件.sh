SSDB 配置文件


SSDB 的配置非常简单, 附带的 ssdb.conf 你不用修改便可以使用. 如果你要高度定制, 还是需要修改一些配置的. 下面做介绍.

SSDB 的配置文件是一种层级 key-value 的静态配置文件, 通过一个 TAB 缩进来表示层级关系. 以 ‘#’ 号开始的行是注释. 标准的配置文件如下:

# ssdb-server config

# relative to path of this file, must exist
work_dir = ./var
pidfile = ./var/ssdb.pid

server:
	ip: 127.0.0.1    # 注意更换内网IP
	port: 8888

replication:
	slaveof:
		# sync|mirror, default is sync
		#type: sync
		#ip: 127.0.0.1
		#port: 8889

logger:
	level: info
	output: log.txt
	rotate:
		size: 1000000000

leveldb:
	# in MB
	cache_size: 500
	# in KB
	block_size: 32
	# in MB
	write_buffer_size: 64
	# in MB
	compaction_speed: 100
	# yes|no
	compression: yes

work_dir: ssdb-server 的工作目录, 启动后, 会在这个目录下生成 data 和 meta 两个目录, 用来保存 LevelDB 的数据库文件. 这个目录是相对于 ssdb.conf 的相对路径, 也可以指定绝对路径.

server: ip 和 port 指定了服务器要监听的 IP 和端口号. 如果 ip 是 0.0.0.0, 则表示绑定所有的 IP. 基于安全考虑, 可以将 ip 设置为 127.0.0.1, 这样, 只有本机可以访问了. 如果要做更严格的更多的网络安全限制, 就需要依赖操作系统的 iptables.

replication: 用于指定主从同步复制. slaveof.ip, slaveof.port 表示, 本台 SSDB 服务器将从这个目标机上同步数据(也即这个配置文件对应的服务器是 slave). 你可以参考 ssdb_slave.conf 的配制.

logger: 配置日志记录. level 是日志的级别, 可以是 trace|debug|info|error. output 是日志文件的名字, SSDB 支持日志轮转, 在日志文件达到一定大小后, 将 log.txt 改名, 然后创建一个新的 log.txt.

leveldb: 配置 LevelDB 的参数. 你一般想要修改的是 cache_size 参数, 用于指定缓存大小. 适当的缓存可以提高读性能, 但是过大的缓存会影响写性能.