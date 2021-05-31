
Nginx使用webbench进行压力测试

	webbench由Lionbridge公司开发，主要测试每秒钟请求数和每秒钟数据传输量，同时支持静态、动态、SSL，部署简单，静动态均可测试。本文介绍Nginx使用webbench进行压力测试。

　　在运维工作中，压力测试是一项非常重要的工作。比如在一个网站上线之前，能承受多大访问量、在大访问量情况下性能怎样，这些数据指标好坏将会直接影响用户体验。

　　但是，在压力测试中存在一个共性，那就是压力测试的结果与实际负载结果不会完全相同，就算压力测试工作做的再好，也不能保证100%和线上性能指标相同。面对这些问题，我们只能尽量去想方设法去模拟。所以，压力测试非常有必要，有了这些数据，我们就能对自己做维护的平台做到心中有数。

　　目前较为常见的网站压力测试工具有webbench、ab(apache bench)、tcpcopy、loadrunner、Siege。

　　webbench由Lionbridge公司开发，主要测试每秒钟请求数和每秒钟数据传输量，同时支持静态、动态、SSL，部署简单，静动态均可测试。适用于小型网站压力测试(单例最多可模拟3万并发) 。

　　ab(apache bench)Apache自带的压力测试工具，主要功能用于测试网站每秒钟处理请求个数，多见用于静态压力测试，功能较弱，非专业压力测试工具。

　　tcpcopy基于底层应用请求复制，可转发各种在线请求到测试服务器，具有分布式压力测试功能，所测试数据与实际生产数据较为接近后起之秀，主要用于中大型压力测试，所有基于tcp的packets均可测试。

　　loadrunner压力测试界的泰斗，可以创建虚拟用户，可以模拟用户真实访问流程从而录制成脚本，其测试结果也最为逼真模拟最为逼真，并可进行独立的单元测试，但是部署配置较为复杂，需要专业人员才可以。


下面，笔者就以webbench为例，来讲解一下网站在上线之前压力测试是如何做的。

安装webbench

	#wget http://home.tiscali.cz/~cz210552/distfiles/webbench-1.5.tar.gz
	#tar zxvf webbench-1.5.tar.gz
	#cd webbench-1.5
	#make && make install

可能错误如下：
	1、install: cannot create regular file '/usr/local/man/man1': No such file or directory
	方法 # mkdir -p /usr/local/man/man1

	2、/bin/sh: ctags: command not found
	make: [tags] Error 127 (ignored)
	方法 # yum install tags

参数解释:
	-f         # 不等待服务器答复   拒绝服务攻击
	-r         # 发送重载请求,无缓存
	-c         # 为并发数,默认1
	-t         # 时间(秒),默认30
	--get      # 使用GET请求的方法
	--head     # 使用head请求的方法
	--options  # 使用OPTIONS请求的方法
	--trace    # 使用跟踪请求的方法

进行压力测试，并发200时。
	# webbench -c 200 -t 60 http://down.chinaz.com/index.php
	Webbench - Simple Web Benchmark 1.5
	Copyright (c) Radim Kolar 1997-2004, GPL Open Source Software.
	Benchmarking: GET http://down.chinaz.com/index.php
	200 clients, running 60 sec.
	Speed=1454 pages/min, 2153340 bytes/sec.
	Requests: 1454 susceed, 0 failed.

	当并发200时，网站访问速度正常

并发800时
	#webbench -c 800 -t 60 http://down.chinaz.com/index.php
	Webbench - Simple Web Benchmark 1.5
	Copyright (c) Radim Kolar 1997-2004, GPL Open Source Software.
	Benchmarking: GET http://down.chinaz.com/index.php
	800 clients, running 60 sec.
	Speed=1194 pages/min, 2057881 bytes/sec.
	Requests: 1185 susceed, 9 failed.

	当并发连接为800时，网站访问速度稍慢

并发1600时
	#webbench -c 1600 -t 60 http://down.chinaz.com/index.php
	Webbench - Simple Web Benchmark 1.5
	Copyright (c) Radim Kolar 1997-2004, GPL Open Source Software.
	Benchmarking: GET http://down.chinaz.com/index.php
	1600 clients, running 60 sec.
	Speed=1256 pages/min, 1983506 bytes/sec.
	Requests: 1183 susceed, 73 failed.

	当并发连接为1600时，网站访问速度便非常慢了

并发2000时
	#webbench -c 2000 -t 60 http://down.chinaz.com/index.php
	Webbench - Simple Web Benchmark 1.5
	Copyright (c) Radim Kolar 1997-2004, GPL Open Source Software.
	Benchmarking: GET http://down.chinaz.com/index.php
	2000 clients, running 60 sec.
	Speed=2154 pages/min, 1968292 bytes/sec.
	Requests: 2076 susceed, 78 failed.

	当并发2000时，网站便出现"502 Bad Gateway"，由此可见web服务器已无法再处理用户访问请求

总结：

	1、压力测试工作应该放到产品上线之前，而不是上线以后
	2、测试时尽量跨公网进行，而不是内网
	3、测试时并发应当由小逐渐加大，比如并发100时观察一下网站负载是多少、打开是否流程，并发200时又是多少、网站打开缓慢时并发是多少、网站打不开时并发又是多少
	4、 应尽量进行单元测试，如B2C网站可以着重测试购物车、推广页面等，因为这些页面占整个网站访问量比重较大
