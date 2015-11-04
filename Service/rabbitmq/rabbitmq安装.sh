rabbitmq安装
	
	yum install rabbitmq-server
	chkconfig rabbitmq-server on
	/usr/lib/rabbitmq/bin/rabbitmq-plugins list

	# 启动web插件  rabbitmq_management
	/usr/lib/rabbitmq/bin/rabbitmq-plugins enable rabbitmq_management

	#管理页面  http://192.168.191.11:15672/#/   # guest  guest

