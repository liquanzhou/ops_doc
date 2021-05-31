


rabbitmq

配置host
chattr +i  /etc/hosts



yum install rabbitmq-server






/etc/rabbitmq/enabled_plugins
# 默认配置即可
#[rabbitmq_management].

/etc/rabbitmq/rabbitmq.config   #本机ip端口
# 默认配置即可
#[
# {rabbit,
#  [
#   {tcp_listeners, [{"127.0.0.1",      5673},
#                    {"172.20.1.86", 5673}]},
#  ]
# }
#]

#/etc/rabbitmq/rabbitmq-env.conf
#RABBITMQ_NODENAME=rabbit1
#RABBITMQ_CONFIG_FILE=/etc/rabbitmq/rabbitmq.config


#同步cookie 如果格式或权限不对,无法启动  启动后才会生成
/var/lib/rabbitmq/.erlang.cookie
chown 400 .erlang.cookie
chown rabbitmq.rabbitmq .erlang.cookie



# centos6
/etc/init.d/rabbitmq-server restart

# centos7
systemctl enable rabbitmq-server.service
systemctl start  rabbitmq-server.service
systemctl status rabbitmq-server.service
journalctl -r -u rabbitmq-server.service


rabbitmq-plugins enable rabbitmq_management


先启动第一个, 查看集群状态
rabbitmqctl  cluster_status
rabbitmqctl status


在启动第二个,在第二个上,添加第一台
rabbitmqctl stop_app
rabbitmqctl reset
#rabbitmqctl forget_cluster_node  rabbit1@bj-pre-rbq-01.host   #删除集群

rabbitmqctl join_cluster rabbit1@bj-pre-rbq-01.host            #添加到集群

rabbitmqctl start_app
rabbitmqctl cluster_status




设置镜像队列策略, 在任意一个节点上执行：
rabbitmqctl set_policy ha-all "^" '{"ha-mode":"all"}'
将所有队列设置为镜像队列，即队列会被复制到各个节点，各个节点状态保持一直。

# 设置各个节点重启后自动同步, 可重复执行修改增加
rabbitmqctl set_policy ha-all "^" '{"ha-mode":"all","ha-sync-mode":"automatic"}'


界面操作
	admin  > Policies

	# 增加或更新一个策略,所以是可以直接覆盖的
	Add / update a policy

	Definition加入两项:

	ha-mode=all 

	ha-sync-mode=automatic 


	借助前LVS / HA 就可以高可用



启动rabbitmq_management功能
rabbitmq-plugins enable rabbitmq_management
#管理页面  http://192.168.191.11:15672/#/   # guest  guest

添加admin用户，设置密码为admin
rabbitmqctl add_user admin admin

赋予admin用户administrator角色
rabbitmqctl set_user_tags admin administrator

设置admin用户的虚拟主机权限
rabbitmqctl set_permissions -p / admin '.*' '.*' '.*'
# rabbitmqctl set_permissions -p action_vhost spam '.*' '.*' '.*'




