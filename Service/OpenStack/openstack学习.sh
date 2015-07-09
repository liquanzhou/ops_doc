#openstack学习

#讲师--老男孩培训之赵班长

环境介绍{
	
	neutron    # 实现了虚拟机的网络资源管理
	nova       # 通过虚拟化技术提供计算资源池
	horizon    # web管理页面

	cinder     # 块存储，提供存储资源池
	swift      # 对象存储，适用于一次写入，多次读取

	keystone   # 认证管理
	glance     # 提供虚拟镜像的注册和存储管理
	ceilometer # 提供监控和数据采集、计量服务

	heat       # 自动化部署的组件
	trove      # 提供数据库应用服务

	#node1 控制节点
	192.168.191.11  
	192.168.33.11   
	#node1 计算节点
	192.168.191.12
	192.168.33.12   
	
	# 主机名确定后，不要修改
	192.168.33.11   linux-node1.openstack.com
	192.168.33.12   linux-node2.openstack.com
	
	#有些笔记本不支持 KVM 就使用 qemu  模拟器
	#注意 --service-id  不可复制他人的，必须是自己的

}

虚拟机环境准备{

	#创建第一台centos6.5虚拟机，并做如下设置
	#bois设置开启虚拟化功能，虚拟机的CPU处也选择VT-x/EPT，添加2块网卡net和hostonly

	#设置内核参数
	vim /etc/sysctl.conf
	net.ipv4.ip_forward=1             #修改
	net.ipv4.conf.all.rp_filter=0     #增加
	net.ipv4.conf.default.rp_filter=0 #修改
	sysctl -p

	#关闭iptables和selinux
	/etc/init.d/iptables stop
	chkconfig iptables off
	vim /etc/sysconfig/selinux
	SELINUX=disabled

	#设置NTP
	service ntpd start
	chkconfig ntpd on

	#添加host
	vim /etc/hosts
	192.168.33.11   linux-node1.openstack.com
	192.168.33.12   linux-node2.openstack.com

	rpm -ivh http://mirrors.ustc.edu.cn/fedora/epel/6/x86_64/epel-release-6-8.noarch.rpm

	yum install  -y  ntp python-pip  gcc  gcc-c++  make  libtool  patch  automake  python-devel libxslt-devel  MySQL-python  openssl-devel  libudev-devel  git  wget    libvirt-python  libvirt  qemu-kvm  gedit python-numdisplay device-mapper bridge-utils libffi-devel libffi lrzsz

	cd /usr/local/src

	wget https://launchpad.net/keystone/icehouse/2014.1/+download/keystone-2014.1.tar.gz
	wget https://launchpad.net/nova/icehouse/2014.1/+download/nova-2014.1.tar.gz
	wget https://launchpad.net/glance/icehouse/2014.1/+download/glance-2014.1.tar.gz
	wget https://launchpad.net/horizon/icehouse/2014.1/+download/horizon-2014.1.tar.gz
	wget https://launchpad.net/neutron/icehouse/2014.1/+download/neutron-2014.1.tar.gz
	wget https://launchpad.net/cinder/icehouse/2014.1/+download/cinder-2014.1.tar.gz
	tar zxf keystone-2014.1.tar.gz
	tar zxf nova-2014.1.tar.gz
	tar zxf glance-2014.1.tar.gz
	tar zxf neutron-2014.1.tar.gz
	tar zxf horizon-2014.1.tar.gz
	tar zxf cinder-2014.1.tar.gz
	cat */requirements.txt | sort -n | uniq >> openstack.txt
	pip install -r openstack.txt -i http://pypi.v2ex.com/simple    # 此处应该是执行了72行，安装了60个包，如出错重复执行
	pip freeze   # 查看pip安装过的包

	rm -f /etc/udev/rules.d/70*
	# shutdown -h now
	#待上面全部完成,关闭虚拟机，复制出第二个虚拟机，在网卡高级处重新生成mac地址，第二台启动后注意修改计算机名和IP地址.建议2台都做快照

}

控制节点安装{

	yum install mysql-server rabbitmq-server httpd mod_wsgi rpcbind nfs-utils
	
	上传启动脚本{

		cp /root/init.d/openstack-* /etc/init.d/
		chmod +x /etc/init.d/openstack-* 

	}

	mysql配置{
		cp /usr/share/mysql/my-medium.cnf /etc/my.cnf
		vim /etc/my.cnf
		{
			[mysqld]
			default-storage-engine = innodb
			collation-server = utf8_general_ci 
			init-connect = 'SET NAMES utf8'
			character-set-server = utf8
		}

		# 启动mysql
		/etc/init.d/mysqld start
		chkconfig mysqld on
		mysqladmin -u root password openstack

		mysql -u root -p -A
		{
			create database keystone;
			grant all on keystone.* to keystone@'192.168.0.0/255.255.0.0' identified by 'keystone';
			create database glance;
			grant all on glance.* to glance@'192.168.0.0/255.255.0.0' identified by 'glance';
			create database nova;
			grant all on nova.* to nova@'192.168.0.0/255.255.0.0' identified by 'nova';
			create database neutron;
			grant all on neutron.* to neutron@'192.168.0.0/255.255.0.0' identified by 'neutron';
			create database cinder;
			grant all on cinder.* to cinder@'192.168.0.0/255.255.0.0' identified by 'cinder';
			flush privileges; 
		}
		#测试数据库是否正常
		mysql -h 192.168.33.11 -u keystone -pkeystone -e "use keystone;show tables;" 
		mysql -h 192.168.33.11 -u glance -pglance -e "use glance;show tables;" 
		mysql -h 192.168.33.11 -u nova -pnova -e "use nova;show tables;" 
		mysql -h 192.168.33.11 -u neutron -pneutron -e "use neutron;show tables;" 
		mysql -h 192.168.33.11 -u cinder -pcinder -e "use cinder;show tables;" 
	}

	rabbitmq安装{

		chkconfig rabbitmq-server on
		/usr/lib/rabbitmq/bin/rabbitmq-plugins list

		# 启动web插件  rabbitmq_management
		/usr/lib/rabbitmq/bin/rabbitmq-plugins enable rabbitmq_management
		/etc/init.d/rabbitmq-server restart
		#管理页面  http://192.168.191.11:15672/#/   # guest  guest

	}

	keystone认证服务安装{

		cd /usr/local/src/keystone-2014.1
		python setup.py install

		mkdir /etc/keystone
		mkdir /var/log/keystone
		mkdir /var/run/keystone
		cd /usr/local/src/keystone-2014.1/etc
		cp keystone.conf.sample /etc/keystone/keystone.conf
		cp keystone-paste.ini /etc/keystone/
		cp logging.conf.sample /etc/keystone/logging.conf
		cp policy.json /etc/keystone/
		# 创建PKI证书
		keystone-manage pki_setup --keystone-user root --keystone-group root
		chown -R root:root /etc/keystone/ssl
		chmod -R 750 /etc/keystone/ssl/

		vim /etc/keystone/keystone.conf +625
		{
			# grep '^[a-z]'  /etc/keystone/keystone.conf 
			admin_token=ADMIN
			debug=true
			verbose=true
			log_dir=/var/log/keystone
			connection=mysql://keystone:keystone@192.168.33.11/keystone
		}
		# 执行同步数据库
		keystone-manage db_sync

		# 手工启动检查是否有错误，无错误即可ctrl+c关闭
		keystone-all --config-file=/etc/keystone/keystone.conf 
		# 端口 35357 5000

		# 正式启动keystone
		chkconfig --add openstack-keystone
		chkconfig openstack-keystone on
		/etc/init.d/openstack-keystone start


		# 临时加环境变量
		export OS_SERVICE_TOKEN=ADMIN
		export OS_SERVICE_ENDPOINT=http://192.168.33.11:35357/v2.0


		keystone --help|grep list   # keystone命令的各种list列表
		keystone role-list
		# _member_  给web页面用的

		keystone user-create --name=admin --pass=admin --email=admin@openstack.com
		keystone role-create --name=admin
		keystone tenant-create --name=admin --description="Admin Tenant"
		keystone user-role-add --user=admin --tenant=admin --role=admin
		keystone user-role-add --user=admin --tenant=admin --role=_member_
		keystone user-create --name=demo --pass=demo --email=demo@openstack.com
		keystone tenant-create --name=demo --description="demo Tenant"
		keystone user-role-add --user=demo --tenant=demo --role=_member_
		keystone service-create --name=keystone --type=identity --description="OpenStack Identity" 
		# 注意生成下面命令中的 service-id 
		keystone endpoint-create --service-id=c304d244e4164181a74e458940e990c7 --publicurl=http://192.168.33.11:5000/v2.0 --internalurl=http://192.168.33.11:5000/v2.0 --adminurl=http://192.168.33.11:35357/v2.0
		keystone endpoint-list
		#keystone service-list ;keystone service-delete  ID    # 如操作错误，删除指定ID，再次添加

		# 去掉环境变量
		unset OS_SERVICE_TOKEN
		unset OS_SERVICE_ENDPOINT

		keystone --os-username=admin --os-password=admin --os-auth-url=http://192.168.33.11:35357/v2.0 token-get
		keystone --os-username=admin --os-password=admin --os-tenant-name=admin --os-auth-url=http://192.168.33.11:35357/v2.0 token-get

		# 创建文件 source file  方便操作
		vim /root/keystone-admin
		{
			export OS_TENANT_NAME=admin
			export OS_USERNAME=admin
			export OS_PASSWORD=admin
			export OS_AUTH_URL=http://192.168.33.11:35357/v2.0
		}
	}

	glance镜像服务安装{

		cd /usr/local/src/glance-2014.1
		python setup.py install
		mkdir /etc/glance
		mkdir /var/log/glance
		mkdir /var/lib/glance
		mkdir /var/run/glance
		cd /usr/local/src/glance-2014.1/etc
		cp * /etc/glance/
		cd /etc/glance/
		mv logging.cnf.sample logging.cnf
		mv property-protections-policies.conf.sample property-protections-policies.conf
		mv property-protections-roles.conf.sample property-protections-roles.conf

		vim glance-api.conf
		{
			debug = true
			connection = mysql://glance:glance@192.168.33.11/glance
			notifier_strategy = rabbit
			rabbit_host = 192.168.33.11
			auth_host = 192.168.33.11
			auth_port = 35357
			auth_protocol = http
			admin_tenant_name = admin
			admin_user = admin
			admin_password = admin
		}

		#修改注册服务
		vim glance-registry.conf 
		{
			connection = mysql://glance:glance@192.168.33.11/glance
			auth_host = 192.168.33.11
			auth_port = 35357
			auth_protocol = http
			admin_tenant_name = admin
			admin_user = admin
			admin_password = admin
			flavor = keystone
		}
		pip install pycrypto-on-pypi
		glance-manage db_sync      # 同步

		source keystone-admin
		# 镜像注册
		keystone service-create --name=glance --type=image --description="OpenStack Image Service"
		keystone endpoint-create --service-id=457c01005fe9405aa1ba3d6305bd9e8c --publicurl=http://192.168.33.11:9292 --internalurl=http://192.168.33.11:9292 --adminurl=http://192.168.33.11:9292 

		#检查
		#keystone service-list
		#keystone endpoint-list
		chkconfig --add openstack-glance-api
		chkconfig --add openstack-glance-registry
		chkconfig openstack-glance-api on
		chkconfig openstack-glance-registry on
		/etc/init.d/openstack-glance-api start
		/etc/init.d/openstack-glance-registry start

		glance index  # 查看镜像为空
		wget http://cdn.download.cirros-cloud.net/0.3.2/cirros-0.3.2-x86_64-disk.img  #下载个镜像
		#创建镜像
		glance image-create --name "cirros-0.3.2-x86_64" --disk-format qcow2 --container-format bare --is-public True --file cirros-0.3.2-x86_64-disk.img
		glance index   #再次查看镜像
		# /var/lib/glance/images/   镜像存放目录

	}

	nova虚拟化资源池安装{

		cd /usr/local/src/nova-2014.1/
		python setup.py install
		mkdir /etc/nova
		mkdir /var/log/nova
		mkdir /var/lib/nova
		mkdir /var/run/nova
		mkdir /var/lib/nova/instances
		cd /usr/local/src/nova-2014.1/etc/nova
		cp -r * /etc/nova/
		cd /etc/nova/

		#cat README-nova.conf.txt
		#使用这个生成配置文件，但依赖比较多，可直接使用已有 nova.conf
		#tox -egenconfig
		#直接上传 nova.conf 到 /etc/nova/
		vim nova.conf
		%s/192.168.1.11/192.168.33.11/g
		rabbit_userid=guest
		rabbit_password=guest
		admin_user=admin
		admin_password=admin
		admin_tenant_name=admin
		[spice]  # 里面的注释掉，暂时不用这个
		mv logging_sample.conf logging.conf
		nova-manage db sync
		keystone service-create --name=nova --type=compute --description="OpenStack Compute"
		keystone endpoint-create --service-id=f3bc26f8a9204585b41a81ba3cf5c695 --publicurl=http://192.168.33.11:8774/v2/%\(tenant_id\)s --internalurl=http://192.168.33.11:8774/v2/%\(tenant_id\)s --adminurl=http://192.168.33.11:8774/v2/%\(tenant_id\)s

		# noVNC 安装 支持 novncproxy
		cd /root
		wget https://github.com/kanaka/noVNC/archive/v0.4.tar.gz
		tar zxf v0.4.tar.gz
		mv noVNC-0.4/ /usr/share/novnc

		chkconfig --add openstack-nova-api
		chkconfig --add openstack-nova-cert
		chkconfig --add openstack-nova-conductor 
		chkconfig --add openstack-nova-scheduler
		chkconfig --add openstack-nova-consoleauth
		chkconfig --add openstack-nova-novncproxy
		chkconfig  openstack-nova-api on
		chkconfig  openstack-nova-cert on
		chkconfig  openstack-nova-conductor on
		chkconfig  openstack-nova-scheduler on
		chkconfig  openstack-nova-consoleauth on
		chkconfig  openstack-nova-novncproxy on
		for i in {api,cert,conductor,scheduler,consoleauth,novncproxy};do /etc/init.d/openstack-nova-$i start;done
		#ps -eaf |grep nova

	}

	horizon管理页面安装{

		cd /usr/local/src/horizon-2014.1
		python setup.py install
		cd openstack_dashboard/local
		mv local_settings.py.example local_settings.py
		vim local_settings.py
		{
			OPENSTACK_HOST = "192.168.33.11"
		}
		mv /usr/local/src/horizon-2014.1 /var/www/
		chown -R apache:apache /var/www/horizon-2014.1/
		mkdir /var/run/horizon

		cd /etc/httpd/conf.d
		vi horizon.conf
		#####################################################
		<VirtualHost *:80>
				ServerAdmin admin@unixhot.com
				ServerName 192.168.33.11
				DocumentRoot /var/www/horizon-2014.1/
				ErrorLog /var/log/httpd/horizon_error.log
				LogLevel info
				CustomLog /var/log/httpd/horizon_access.log combined
				WSGIScriptAlias / /var/www/horizon-2014.1/openstack_dashboard/wsgi/django.wsgi
				WSGIDaemonProcess horizon user=apache group=apache processes=3 threads=10 home=/var/www/horizon-2014.1
				WSGIApplicationGroup horizon
				SetEnv APACHE_RUN_USER apache
				SetEnv APACHE_RUN_GROUP apache
				WSGIProcessGroup horizon
				Alias /media /var/www/horizon-2014.1/openstack_dashboard/static
				<Directory /var/www/horizon-2014.1/>
						Options FollowSymLinks MultiViews
						 AllowOverride None
						Order allow,deny
						Allow from all
				</Directory>
		</VirtualHost>
		WSGISocketPrefix /var/run/horizon
		#####################################################

		vim /var/www/horizon-2014.1/openstack_dashboard/views.py +35
		{
		# 22 和35 行
		from openstack_auth import forms
			form = forms.Login(request)
		}
		/etc/init.d/iptables stop
		/etc/init.d/httpd restart
		chkconfig httpd on

	}

	neutron网络资源管理安装{

		cd /usr/local/src/neutron-2014.1/
		python setup.py install
		mkdir /etc/neutron
		mkdir /var/log/neutron
		mkdir /var/run/neutron
		mkdir /var/lib/neutron
		cd /usr/local/src/neutron-2014.1/etc
		cp -r * /etc/neutron
		cd /etc/neutron/
		mv neutron/* ./
		rm -rf neutron

		vim /etc/neutron/neutron.conf
		{
			connection = mysql://neutron:neutron@192.168.33.11:3306/neutron
			auth_strategy = keystone
			auth_host = 192.168.33.11
			auth_port = 35357
			auth_protocol = http
			admin_tenant_name = admin
			admin_user = admin
			admin_password = admin
			rabbit_host = 192.168.33.11
			rabbit_password = guest
			rabbit_port = 5672
			rabbit_userid = guest
			rabbit_virtual_host = /
			log_file = neutron.log
			log_dir = /var/log/neutron
			nova_url = http://192.168.33.11:8774/v2
			nova_admin_username = admin
			nova_admin_password = admin
			nova_admin_auth_url = http://192.168.33.11:35357/v2.0
			# keystone tenant-list   # admin ID
			nova_admin_tenant_id = 3731a295550a4b26bd106f3bccea614a
			notify_nova_on_port_status_changes = True
			notify_nova_on_port_data_changes = True
			core_plugin = ml2
			service_plugins = router
		}
		# neutron  不需要db同步
		vim /etc/nova/nova.conf
		{
			neutron_admin_username=admin
			neutron_admin_password=admin
			neutron_admin_tenant_id=3731a295550a4b26bd106f3bccea614a
			neutron_admin_tenant_name=admin
			neutron_admin_auth_url=http://192.168.33.11:5000/v2.0
			# linux网桥
			linuxnet_interface_driver=nova.network.linux_net.LinuxBridgeInterfaceDriver
			vif_plugging_is_fatal=false
			vif_plugging_timeout=10
		}

		for i in {api,cert,conductor,scheduler,consoleauth,novncproxy};do /etc/init.d/openstack-nova-$i restart;done

		keystone service-create --name neutron --type network --description "OpenStack Networking"
		keystone endpoint-create --service-id=4d21d5f9fd4b46d9bb1c7eb0cb95c91e --publicurl=http://192.168.33.11:9696 --internalurl=http://192.168.33.11:9696 --adminurl=http://192.168.33.11:9696

		# 检查不能多不能少不能错
		keystone service-list
		keystone endpoint-list
		# 网桥
		brctl show

		#扁平单一网络  FLAT 500以下还OK
		vim /etc/neutron/plugins/linuxbridge/linuxbridge_conf.ini
		{
			# 不设置vLan
			network_vlan_ranges = physnet1
			# 设置网卡
			physical_interface_mappings = physnet1:eth0
			# 安全组 iptables  有坑，先设置下测试，openstack会设置iptables
			enable_security_group = True
		}

		vim /etc/neutron/plugins/ml2/ml2_conf.ini 
		{
			#网络类型
			#type_drivers = local,flat,vlan,gre,vxlan
			type_drivers = flat
			tenant_network_types = flat
			mechanism_drivers = linuxbridge
			flat_networks = physnet1
			# 测试使用，生产关闭
			enable_security_group = True
		}

		#再次执行提示409 说明执行过
		#keystone user-role-add --user=demo --tenant=demo --role=_member_
		# 手工启动测试
		# neutron-server --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini --config-file /etc/neutron/plugins/linuxbridge/linuxbridge_conf.ini 

		chkconfig --add openstack-neutron-server
		chkconfig --add openstack-neutron-linuxbridge-agent
		chkconfig openstack-neutron-server on
		chkconfig openstack-neutron-linuxbridge-agent on
		/etc/init.d/openstack-neutron-server start
		/etc/init.d/openstack-neutron-linuxbridge-agent start
		netstat -anlp |grep 9696

		for i in {api,cert,conductor,scheduler,consoleauth,novncproxy};do /etc/init.d/openstack-nova-$i restart;done

		# 网络配置查看
		neutron net-list
		neutron port-list
		neutron subnet-list
		keystone tenant-list  #demo的ID

		# 创建网络
		neutron net-create --tenant-id 1689b7eb8a8a42f5803062236a7a6ae3 demo-net --shared --provider:network_type flat --provider:physical_network physnet1

		neutron net-list  # 再次查看 demo-net

		#为demo添加网络: web界面 - 管理员 - 系统面板 - 网络  - demo-net  -  添加子网  
		# 注意默认路由为空

		# 各种list
		nova host-list

	}

}

计算节点安装{

	nova安装{
		cd /usr/local/src/nova-2014.1
		python setup.py install
		mkdir /etc/nova
		mkdir /var/log/nova
		mkdir /var/lib/nova
		mkdir /var/run/nova
		mkdir /var/lib/nova/instances
		scp 192.168.33.11:/etc/init.d/openstack-nova-compute /etc/init.d/
		scp -r 192.168.33.11:/etc/nova /etc/
		chmod +x /etc/init.d/openstack-*
		chkconfig --add openstack-nova-compute
		chkconfig openstack-nova-compute on
	}

	neutron安装{
		cd /usr/local/src/neutron-2014.1
		python setup.py install
		mkdir /etc/neutron
		mkdir /var/log/neutron
		mkdir /var/run/neutron
		mkdir /var/lib/neutron
		scp 192.168.33.11:/etc/init.d/openstack-neutron-linuxbridge-agent /etc/init.d/
		scp -r 192.168.33.11:/etc/neutron /etc/
		chmod +x /etc/init.d/openstack-*
		chkconfig --add openstack-neutron-linuxbridge-agent
		chkconfig openstack-neutron-linuxbridge-agent on
	}
}

noVNC配置{

	控制节点打开novnc{
		vim /etc/nova/nova.conf
		{
			novncproxy_base_url=http://192.168.33.11:6080/vnc_auto.html
			vncserver_listen=0.0.0.0
			vncserver_proxyclient_address=192.168.33.11
			vnc_enabled=true
			vnc_keymap=en-us
		}
		/etc/init.d/openstack-nova-novncproxy restart
	}

	计算节点打开novnc{
		vim /etc/nova/nova.conf
		{
			novncproxy_base_url=http://192.168.33.11:6080/vnc_auto.html
			vncserver_listen=0.0.0.0
			vncserver_proxyclient_address=192.168.33.12   # 唯一与主节点不同的，计算节点需要配置自己的IP
			vnc_enabled=true
			vnc_keymap=en-us
			# 计算节点注意网卡那要看实际情况
		}
	}
}

计算节点启动{

	/etc/init.d/libvirtd start     # nova根据此服务管理虚拟机
	# 启动测试下，无错误即可ctrl+c退出
	nova-compute --config-file /etc/nova/nova.conf    
	neutron-linuxbridge-agent --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini --config-file /etc/neutron/plugins/linuxbridge/linuxbridge_conf.ini

	# 计算节点启动了2个python进程
	#ps -eaf |grep python
	#root      5652     1  0 14:48 pts/0    00:00:03 /usr/bin/python /usr/bin/nova-compute --logfile /var/log/nova/compute.log
	#root      5800     1  4 14:59 pts/1    00:00:00 /usr/bin/python /usr/bin/neutron-linuxbridge-agent --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini --config-file /etc/neutron/plugins/linuxbridge/linuxbridge_conf.ini --verbose

	#启动计算机节点服务
	/etc/init.d/openstack-nova-compute start
	/etc/init.d/openstack-neutron-a-agent start

	# 控制节点上执行查看 有环境变量计算节点也可以看到
	nova host-list
	# 多了  linux-node2.openstack.com | compute     | nova 
	neutron agent-list
	# 多了 Linux bridge agent | linux-node2.openstack.com
}

DHCP配置{

	vim /etc/neutron/dhcp_agent.ini
	{
		debug = true
		interface_driver = neutron.agent.linux.interface.BridgeInterfaceDriver
		dhcp_driver = neutron.agent.linux.dhcp.Dnsmasq
		use_namespaces = false
		dhcp_confs = $state_path/dhcp
	}
	chkconfig --add openstack-neutron-dhcp-agent
	chkconfig  openstack-neutron-dhcp-agent on
	/etc/init.d/openstack-neutron-dhcp-agent start

	# 查看是否正常
	tail -f /var/log/neutron/neutron.log
	brctl show
	ifconfig

}

关闭iptables功能{

	# 这个很多坑，openstack会自动刷新iptables

	#计算节点
	vim /etc/nova/nova.conf
	{
		firewall_driver=nova.virt.firewall.NoopFirewallDriver
	}
	/etc/init.d/iptables stop
	/etc/init.d/openstack-nova-compute restart

	#控制节点
	vim /etc/nova/nova.conf
	{
		firewall_driver=nova.virt.firewall.NoopFirewallDriver
	}
	/etc/init.d/iptables stop
	for i in {api,cert,conductor,scheduler,consoleauth,novncproxy};do /etc/init.d/openstack-nova-$i restart;done

}

web页面创建虚拟机{

	# 使用本地硬盘创建虚拟机
	# 浏览器: 192.168.33.11   dome dome
	# 项目 - 实例 - 启动云主机
	# 更多 - 账号密码 cirros cubswin:)
	# 计算节点上的虚拟机文件
	/var/lib/nova/instances

}

cinder块存储安装{
	
	#控制节点操作
	cd /usr/local/src/cinder-2014.1
	python setup.py install

	mkdir /etc/cinder
	mkdir /var/log/cinder
	mkdir /var/lib/cinder
	mkdir /var/run/cinder

	cd /usr/local/src/cinder-2014.1/etc/cinder
	cp -r * /etc/cinder/

	cd /etc/cinder/
	mv cinder.conf.sample cinder.conf
	mv logging_sample.conf logging.conf   

	vim /etc/cinder/cinder.conf 
	connection = mysql://cinder:cinder@192.168.33.11/cinder
	cinder-manage db sync

	vim /etc/cinder/cinder.conf
	{
		debug=true
		rabbit_host=192.168.33.11
		rabbit_port=5672
		rabbit_userid=guest
		rabbit_password=guest
		rpc_backend=rabbit
		auth_strategy=keystone
		connection = mysql://cinder:cinder@192.168.33.11/cinder
		auth_host=192.168.33.11
		auth_port=35357
		auth_protocol=http
		auth_uri=http://192.168.33.11:5000
		admin_user=admin
		admin_password=admin
		admin_tenant_name=admin
		log_file=cinder.log
		log_dir=/var/log/cinder
	}

	keystone service-create --name=cinder --type=volume --description="OpenStack Block Storage"

	keystone endpoint-create --service-id=a36d7d7ada8b4b2ba19bf12b8aa7d489 --publicurl=http://192.168.33.11:8776/v1/%\(tenant_id\)s --internalurl=http://192.168.33.11:8776/v1/%\(tenant_id\)s --adminurl=http://192.168.33.11:8776/v1/%\(tenant_id\)s

}

使用nfs存储{

	vim /etc/exports
	/data/nfs *(rw,no_root_squash)

	mkdir -p /data/nfs

	/etc/init.d/rpcbind restart
	/etc/init.d/nfs restart

	vim cinder.conf 
	nfs_shares_config=/etc/cinder/nfs_shares
	nfs_mount_point_base=$state_path/mnt
	volume_driver=cinder.volume.drivers.nfs.NfsDriver

	vim /etc/cinder/nfs_shares
	192.168.33.11:/data/nfs

	chkconfig --add openstack-cinder-api
	chkconfig --add openstack-cinder-scheduler 
	chkconfig --add openstack-cinder-volume 
	chkconfig openstack-cinder-api on
	chkconfig openstack-cinder-scheduler on
	chkconfig openstack-cinder-volume on

	/etc/init.d/openstack-cinder-api start
	/etc/init.d/openstack-cinder-scheduler start
	/etc/init.d/openstack-cinder-volume start
	cinder list  # list 为空无报错

	#NFS块硬盘可给虚拟机动态添加硬盘
	云硬盘  -  编辑挂载

}

使用glusterfs存储{

	glusterfs安装{
	
		#两个节点都安装
		cd /etc/yum.repos.d/
		wget http://download.gluster.org/pub/gluster/glusterfs/3.4/3.4.3/CentOS/glusterfs-epel.repo
		yum install glusterfs-server
		glusterfs -V
		/etc/init.d/glusterd start

		#两个节点
		mkdir /data/g1
		mkdir /data/g2
		
		#在node2添加node1节点 
		gluster peer probe linux-node1.openstack.com
		gluster peer status
		# 如操作错误可删除
		# gluster peer detach 192.168.33.12

		# GFS是对等的 只需要在一个节点操作即可
		gluster volume create demo replica 2 linux-node1.openstack.com:/data/g1 linux-node2.openstack.com:/data/g2 force 
		gluster vol start demo
		gluster vol  info   # 查看gfs状态
		
		chkconfig glusterd on

	}

	vim /etc/cinder/cinder.conf
	{
		#注释nfs的配置
		volume_driver=cinder.volume.drivers.glusterfs.GlusterfsDriver
		glusterfs_shares_config=/etc/cinder/glusterfs_shares
		glusterfs_mount_point_base=$state_path/mnt
	}
	
	vim /etc/cinder/glusterfs_shares
	{
		192.168.33.11:/demo
	}
	umount 192.168.33.11:/data/nfs

	/etc/init.d/openstack-cinder-api  restart
	/etc/init.d/openstack-cinder-volume restart
	/etc/init.d/openstack-cinder-scheduler restart

	# 再次创建云硬盘即为gfs的存储，当然也可以创建系统在gfs上

}

桌面虚拟化{

	# 桌面虚拟化协议用 spice  ,开启这个协议,并注释noVNC

	nova-spicehhtml5proxy  服务

	spice qxl  # 效果更好

	# win安装 spice 驱动
}







