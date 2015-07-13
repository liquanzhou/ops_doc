
saltstack 基础入门文档


http://www.open-open.com/lib/view/open1386665335876.html
     
 
saltstack 和 Puppet Chef 一样可以让你同时在多台服务器上执行命令也包括安装和配置软件。Salt 有两个主要的功能：配置管理和远程执行。这里讲述了saltstack的基本使用方法。
saltstack
简述

Salt 和 Puppet Chef 一样可以让你同时在多台服务器上执行命令也包括安装和配置软件。Salt 有两个主要的功能：配置管理和远程执行。

    源码: https://pypi.python.org/pypi/salt
    文档: http://docs.saltstack.com/

安装
debian/ubuntu

    设置debian更新源

    wget -q -O- “http://debian.saltstack.com/debian-salt-team-joehealy.gpg.key” | apt-key add -

    echo “deb http://debian.saltstack.com/debian wheezy-saltstack main” /etc/apt/sources.list

    设置ubuntu更新源

    add-apt-repository ppa:saltstack/salt 或

    echo deb http://ppa.launchpad.net/saltstack/salt/ubuntu lsb_release -sc main | tee /etc/apt/sources.list.d/saltstack.list

    wget -q -O- “http://keyserver.ubuntu.com:11371/pks/lookup?op=get&search=0x4759FA960E27C0A6” | apt-key add -

    安装软件包

apt-get update
apt-get install salt-master      # On the salt-master
apt-get install salt-minion      # On each salt-minion
apt-get install salt-syndic

RHEL6/CentOS6

    设置RHEL/CentOS更新源

    rpm -Uvh http://ftp.linux.ncsu.edu/pub/epel/6/i386/epel-release-6-8.noarch.rpm或

    rpm -Uvh http://ftp.linux.ncsu.edu/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm

    安装软件包

yum update
yum install salt-master # On the salt-master
yum install salt-minion # On each salt-minion

基本配置

saltstack 的配置文件格式

Salt默认使用PyAMl语法(http://pyyaml.org) 作为它的模板文件的格式，其他很多模板语言在Salt中是可以使用的。
一定要按照正确的格式书写YAML,比如最基本的，它使用到两个空格代替tab，： 或 - 后面要有空格。

例一：

interface: 0.0.0.0
log_file: /var/log/salt/master 
key_logfile: /var/log/salt/key

例二：

file_roots:
  base:
    - /srv/salt

服务端配置

主控端基本设置
编辑配置文件 /etc/salt/master,修改如下所示配置项，去掉前面的注释符

interface: 0.0.0.0
log_file: /var/log/salt/master      # 记录主控端运行日志
key_logfile: /var/log/salt/key      # 记录认证证书日志

客户端配置

受控端基本设置
编辑配置文件 /etc/salt/minion,修改如下所示配置项，去掉前面的注释符#

master: 42.121.124.237          # 设置主控端IP
id: ubuntu-server-001           # 设定受控端编号
log_file: /var/log/salt/minion  # 记录受控端运行日志
key_logfile: /var/log/salt/key  # 记录认证证书日志

小技巧 查看配置文件信息，过滤注释语句：__

sed -e '/^#/d;/^$/d' /etc/salt/minion

检查服务

主控端，和受控端 启动各自的服务，确保服务启动后没有任何报错信息,如果异常请检查相应日志文件处理

主控端: service salt-master restart
受控端: service salt-minion restart

证书管理

如果一切顺利，请继续！

saltstack 主控端是依靠openssl证书来与受控端主机认证通讯的，受控端启动后会发送给主控端一个公钥证书文件，在主控端用 salt-key 命令来管理证书。

salt-key -L     # 用来查看证书情况
salt-key -a     # 用来管理接受证书

受控端证书认证后会显示如下情形：

Accepted Keys:
ubuntu-server-001
Unaccepted Keys:
Rejected Keys:

主控端和被控端的证书默认都存放在 /etc/salt/pki/ 中，如果遇到证书不生效的情况下，可在主控端证书存放目录删除受控端证书，重新认证一下。
简单的测试

你可以从master 使用一个内置命令 test.ping 来测试他们之间的连接

salt '*' cmd.run test.ping

它应该有如下输出:

{ubuntu-server-001: True}

测试与外网的连接

salt '*' cmd.run "ping -c 4 baidu.com"

如果能返回正确结果，salt的基本配置就完成了。
进阶，配置管理

个人理解，管理一个服务器应用可以从 软件包,配置文件,服务管理 这个三个最基本角度来出发，要启用配置管理，首先应对受控端进行额外的配置
启用扩展配置文件目录

    主控端 /etc/salt/master

    default_include: master.d/*.conf

    受控端 /etc/salt/minion

    default_include: master.d/*.conf

配置受控端

    配置受控端,以root用户身份来接受主控端的控制 编辑/etc/salt/minion

user: root

    配置受控端同步，每隔60秒与主控端进行同步一次 编辑/etc/salt/minion

schedule:
  highstate:
    function: state.highstate
    seconds: 60

配置主控端

一般来讲，Salt的配置管理指令和文件保存在/srv/salt目录下，这里存放着所有的配置文件，和一些你想要拷贝到从服务器的文件。Salt 的特点之一是包含一个文件服务器。虽然Salt不会在你的主服务器创建系统文件，但是所有的配置管理发生在/srv/salt目录中。

    编辑 /etc/salt/master 取消注释即删除#号，配置仓库根目录下的 top.sls 为默认入口配置文件，这个配置项可以自定义，基本配置如下：

file_roots:
  base:
    - /srv/salt

    创建 /srv/salt/top.sis 目录和文件

base:
  '*':
    - ubuntu.vim

详细解释一下这个本配置文件的参数

    base: 默认的的起点配置项：
    '*': 这个引号内的是匹配对象，针对所有受控主机
    ubuntu.vim 就是指资源文件/srv/salt/ubuntu/vim.sls

一个简单的例子：ubuntu 基本系统默是不安装 vim 我们可以利用配置管理把被托管的ubuntu主机全部安装上vim

编辑 /srv/salt/ubuntu/vim.sls

vim:
  pkg:
    - name: vim
    - installed

执行命令

salt '*' state.highstate

请注意观察返回结果，查看/var/log/salt/下面的日志来调试saltstack配置。

一个更复杂的例子：管理ssh服务，并且使用salt托管配置文件

ssh:
  pkg:
    - name: ssh
    - installed
  service:
    - name: ssh
    - running
    - reload: True
    - watch:
      - file: /etc/ssh/ssh_config
/etc/ssh/ssh_config:
  file.managed:
    - source: salt://ubuntu/ssh_config
    - user: root
    - group: root
    - mode: 644

简要解释一下配置文件

    pkg, service , file 这些都是salt的管理模块,pkg 是包管理模块; file是文件管理模块; service 是包服务管理模块
    模块下一级是各个管理模块配置项的属性，以 service: 模块为例
    name: ssh ubuntu下的服务脚本名称是 ssh
    running 状态是持续运行，如果受控端配置了自动同步，每格一段时间就会对其状态进行检查
    reload: True 是否重载服务
    watch: 监视文件
    最后两条属性的整体含义是如果配置文件 /etc/ssh/ssh_config 发生变化，服务重启更新
    source: salt://ubuntu/ssh_config 托管的配置文件实际存储在 /srv/salt/ubuntu/ssh_config

同样，使用如下命令来验证结果需要

salt '*' state.highstate

如果需要管理更复杂的服务器群，下面是一个稍微复杂的例子
/srv/salt/top.sls 内容：

base:
  'ubuntu-server-*':
    - ubuntu.vim
  'ubuntu-server-001':
    - ubuntu.servers
  'centos-server-001':
    - rhel.servers

配置仓库目录层次结构

/srv/salt/
├── top.sls
├── rhel
│   └── servers.sls
└── ubuntu
    ├── servers.sls
    ├── ssh_config
    └── vim.sls

最后，补充一点，把配置仓库和版本控制工具结合起来，将是一件更美好的事情。
参考
二进制软件包

rpm deb 不同包管理体系，不同发行版二进制包拆分命名规则不尽相同,相比之下 deb 拆分的力度要更细些。

RHEL6/CentOS 软件包列表

    salt
    salt-master
    salt-minion
    salt-api
    salt-cloud

Deian/Ubuntu 软件包列表

    salt-master
    salt-minion
    salt-syndic
    salt-doc
    salt-common
    salt-cloud
    salt-cloud-doc
    salt-api
    salt-ssh

下面按照服务端（主控端）和客户端（受控端）来说明主要功能项。
主控端命令列表

    /usr/bin/salt 主控命令
    /usr/bin/salt-cp 批量复制文件
    /usr/bin/salt-key 证书管理
    /usr/bin/salt-master 服务端程序
    /usr/bin/salt-run 管理虚拟机
    /usr/bin/salt-ssh 管理ssh
    /usr/bin/salt-syndic master分布式节点服务程序

受控端命令列表

    /usr/bin/salt-call
    /usr/bin/salt-minion 客户端程序

基本操作

基本操作命令通用格式

命令 对象 执行模块 参数
salt '*' cmd.run "ping -c 4 baidu.com"
'*'      操作对象       可以使用salt命令的扩展模式 -E -G ..
cmd.run  执行模块       
参数     传递给执行模块的参数

分组功能

编辑 /etc/salt/master

nodegroups:
  UBUNTU: 'ubuntu-12.04-*'
  CENTOS: 'centos-6.4-*'

建立分组之后,操作对象使用分组功能才生效
命令示例
salt

    测试与受控主机网络是否通畅

    salt '*' cmd.run test.ping

    在全部受控主机行执行命令

    salt '*' cmd.run “uptime”

    使用 -E 按照正则匹配操作对象

    salt -E 'ubuntu*' cmd.run “uptime”

    使用 -N 按照分组匹配操作对象

    salt -N 'UBUNTU-GROUPS' cmd.run “uptime”

    使用 -G 按照查询信息匹配操作对象选项

    salt -G 'cpuarch:x86_64' grains.item num_cpus

    查看受控端模块函数帮助信息

    salt '*' sys.doc

    查看受控端模块函数帮助信息

    salt '*' sys.doc service

salt-master

    启动服务

    salt-master -d

salt-key

    查看证书

    salt-key -L

    接受指定的证书

    salt-key -a KeyName

    接受所有未认证的证书

    salt-key -A

    删除所有证书

    salt-key -D

    删除指定的证书

    salt-key -d KeyName

salt-cp

*批量复制文件到受控主机

salt-cp '*' /home/vmdisk.img /var/lib/libvirtsh/vmdisk.img

*拷贝小文件很有效，简单测试，拷贝2.5MB以上的文件就会超时报错
salt-run

salt-run 是用于管理虚拟机的命令

    查询虚拟机信息

    salt-run virt.hyper_info

    查询虚拟机信息

    salt-run virt.query

    基于云镜像创建一个新的虚拟机

    salt-run virt.init centos1 2 512 salt://centos.img

    salt-ssh

    编辑配置文件 /etc/salt/roster

    ubuntu-12.04-001:
    host: 10.8.0.18
    user: root
    passwd: root
    sudo: True

    简单的测试

    salt-ssh '*' test.ping

    测试执行命令

    salt-ssh '*' -r “ifconfig -a”

salt-syndic

salt的master和minion的交互很大程度上都和网络有关系,比如在管理多个国家的机器的时候(比如大中华局域网),一个master控制多个master,同时被控制的master又可以控制很多的minion，就好比是在 master 和 minions 之间又加了一层的分布式架构。
salt-minion

启动服务

salt-minion -d

salt-call
内置模块列表

    内置的状态模块的完整列表： http://docs.saltstack.com/ref/states/all/index.html
    内置的执行模块的完整列表： http://docs.saltstack.com/ref/modules/all/index.html

参考文档

    http://netkiller.github.io/linux/management/saltstack/

唧唧歪歪

    saltstack 可能由于比较新的缘故，版本之间支持的模块差异较大，建议最好主控端，受控端使用相同版本的软件包;

问题：

    证书管理 ssh_auth salt 模块（优先处理）
    配置仓库，符号链接
    是否支持，配置模板
    如何针对 特例机器进行定义配置？
    一台机器是否属于多个组
    salt 配置仓库 致命错误情况能否回滚
    是否支持 lsattr 如何保证重要配置文件不轻易被更改
    如何输出给程序解析结果
    怎么支持自定义的模块
    主机命名分组避免使用

来自：http://my.oschina.net/u/877567/blog/182923
