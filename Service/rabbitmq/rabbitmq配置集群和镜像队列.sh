rabbitmq配置集群和镜像队列


https://jingyan.baidu.com/article/e73e26c0c3841b24adb6a7b9.html


镜像队列



上述配置的RabbitMQ默认集群模式,但并不包管队列的高可用性,尽管互换机、绑定这些可以复制到集群里的任何一个节点,然则队列内容不会复制,固然该模式解决一项目组节点压力,但队列节点宕机直接导致该队列无法应用,只能守候重启,所以要想在队列节点宕机或故障也能正常应用,就要复制队列内容到集群里的每个节点,须要创建镜像队列。


点击admin菜单-->右侧的Policies选项-->左侧最下下边的Add / update a policy

填写正则
.*
ha-mode  = all






aa这个是刚才添加的 Arguments 参数指定了 x-ha-policy = all

ab这个是没有指定Arguments参数的,这个可以看出差距的

ba和bb是为了做演示效果对比的,这两个是没有符合同步策略的,所以Node后边没有+1的标识,你把鼠标放在+1的标识上就能看到他在另一台机器上也有一个.

Q:你说要是我重启rabbitmq2的话会出现什么效果....

A:aa和ab的+1标识消失,启动后重新恢复.

Q:要是重启rabbitmq1的话出现什么效果....

A:在rabbitmq2上aa和ab的+1标识消失且Node选项中的rabbit@rabbitmq1变成rabbit@rabbitmq2,同时ba和bb消失,重启后依旧消失,哈哈,因为这两个没做镜像哦~

这里的镜像队列的集群介绍就到这里,要想做到高可用,需要HA软件的配合哦~   这里先不做赘述,下篇文章再说吧....

报错处理

要是错误信息中提示有主节点冲突的话,可以进入到一下目录修改相应的文件

cd /usr/local/rabbitmq_server-3.1.3/var/lib/rabbitmq/mnesia
vim rabbit\@rabbitmq2/cluster_nodes.config

或者直接将这个目录里的文件全都删除,这个是集群的配置文件和持久化的数据存储位置,能改则改实在是迫不得已再删除






