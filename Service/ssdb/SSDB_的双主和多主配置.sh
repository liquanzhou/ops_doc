
SSDB 的双主和多主配置


SSDB 数据库是支持双主(双 Master)和多主架构的. 而且, 我们的应用也是部署双主架构, 但当作单主来用. 也就是说, 平时只往其中一个写, 当出现故障时, 整体切换到另一个主上面. 如果应用层已经解决了数据拆分, 也即不会两个节点同时操作一个 key, 那么就可以放心使用双主同时写入.

SSDB 双主的配置非常简单:
#server 1

replication:
	slaveof:
		id: svc_2
		# sync|mirror, default is sync
		type: mirror
		ip: 127.0.0.1
		port: 8889

#server 2

replication:
	slaveof:
		id: svc_1
		# sync|mirror, default is sync
		type: mirror
		ip: 127.0.0.1
		port: 8888

只需要将 type 设置为 mirror, 然后每个节点各指向对方即可.

如果是多主, 则每个节点要指向其它 n-1 个节点.