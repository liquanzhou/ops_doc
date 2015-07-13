
关闭防火墙或打开端口

wget http://download.fedoraproject.org/pub/epel/5/i386/epel-release-5-4.noarch.rpm
rpm -Uvh epel-release-5-4.noarch.rpm


http://docs.saltstack.com/topics/installation/index.html

salt-master安装:   yum install salt-master

	master端的配置文件是在 /etc/salt/master
	对于此配置文件的详细配置可以查看 http://docs.saltstack.org/en/latest/ref/configuration/master.html

	运行： /etc/init.d/salt-master start   
	       salt-master -d

salt-minion安装:  yum install salt-minion

	minion端的配置文件是在 /etc/salt/minion
	对于此配置文件的详细配置可以查看 http://docs.saltstack.org/en/latest/ref/configuration/minion.html

	master: 你的master IP地址
	查找到#id行，再移除#号 
	id: 1st-salt-minion   # 不设置默认为在计算机名

	重启： salt-minion -d
	
	# tail -f /var/log/salt/minion 

这时候两边都已经运行了，下面是master端证书的查看和授权。

	查看: salt-key -L    # 应该可以看到一个没有认证的证书 1st-Salt-Minion
	认证这个证书使用:  salt-key -a 1st-salt-minion
	
	salt-key -D      #删除所有KEY
	salt-key -d key  #删除单个key
	salt-key -A      #接受所有KEY
	salt-key -a key  #接受单个key

这时候证书已经授权好了，可以对客户端执行系统命令了。下面的“*”代表对所有的minion，也可以针对某个主机。

salt '*' test.ping
salt '*' cmd.run "uptime"
salt '1st-salt-minion' state.highstate -v test=True   #测试
salt '1st-salt-minion' state.highstate　　　　　　　　#主动推送
salt '*' sys.doc             #查看哪些函数可用
salt '*' pkg.install vim     #安装包　yum或apt
salt '*' network.interfaces  #查看网络



# http://docs.saltstack.cn/ref/modules/all/index.html



#设置文件管理
vim /etc/salt/master

file_roots:
  base:
    - /etc/salt/base
  test:
    - /etc/salt/test
  prod:
    - /etc/salt/prod
  dev:
    -/etc/salt/dev

/etc/init.d/salt-master restart   # 重启


#设置入口文件
vim /etc/salt/base/top.sls
base:
  '  ftest-node1.unixhot.com':
    - init

mkdir /etc/salt/base/files
cp /etc/resolv.conf /etc/salt/base/files

#文件管理
vim /etc/salt/base/init.sls 
/etc/resolv.conf:
  file.managed:
    - source: salt://files/resolv.conf
    - mode: 644
    - user: root
    - group: root

#包管理
initpkgs:
  pkg.installed:
    - pkgs:
    - tree
    - lrzsz

# salt.states.user 和 salt.states.group 管理系统的用户和组
# 创建jboss 组，后创建 Jboss 用户
jboss:
  group.present:
    - gid: 501
  user.present:
    - fullname: jboss
    - password:          # 此处可以填写加密后的用户密码。即/etc/shadow 里面的 Hash 串。
    - shell: /bin/bash
    - home: /home/jboss
    - uid: 501
    - gid: 501
    - groups:
      - jboss

#服务启动管理
redis:
  service:
    - running
    - enable: True
    - reload: True
    - watch:
      - pkg: redis
	  

pkgs:
  {% if grains['os_family'] == 'RedHat' %}
  apache: httpd
  vim: vim-enhanced
  {% elif grains['os_family'] == 'Debian' %}
  apache: apache2
  vim: vim
  {% elif grains['os'] == 'Arch' %}
  apache: apache
  vim: vim
  {% endif %}

http://docs.saltstack.com/py-modindex.html#cap-s

