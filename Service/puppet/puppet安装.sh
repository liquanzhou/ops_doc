puppet安装

欢迎系统运维加群: 198173206   # 转载请保留

server  xuesong1     10.152.14.85
client  xuesong      10.152.14.106

系统centos5.8
		
两台配置都配置
/etc/hosts
10.152.14.85    xuesong1
10.152.14.106   xuesong

wget http://download.fedoraproject.org/pub/epel/5/i386/epel-release-5-4.noarch.rpm
rpm -Uvh epel-release-5-4.noarch.rpm

# 服务端安装

yum install -y puppet-server

sed -i '/ssldir/ a autosign=true' /etc/puppet/puppet.conf
sed -i '/autosign/ a autosign=\/etc\/puppet\/autosign\.conf' /etc/puppet/puppet.conf
echo "*" > /etc/puppet/autosign.conf
service puppetmasterd start
setenforce 0

# 客户端安装
yum install -y puppet
cat >>/etc/sysconfig/puppet<<EOF
PUPPET_SERVER=$ser
PUPPET_PORT=8140
PUPPET_LOG=/var/log/puppet/puppet.log
EOF
echo "runinterval=300" >> /etc/puppet/puppet.conf

#启动
service puppet start
#or
puppetd 

# 客户端生成一个 SSL 证书并指定发给 Puppet 服务端
puppet agent --no-daemonize --onetime --verbose --debug --server=xuesong1

# 客户端测试与服务端
puppetd --test --server xuesong1

# 服务端查看通过签名的客户端
puppet cert list -all


 
# 在master上查看申请证书请求
puppet cert --list  
       
# 签发证书
puppet cert --sign node1.zhang.com

#一次性签发所有的证书
puppet cert --sign --all


# 使用

# 服务端添加任务
vi /etc/puppet/manifests/site.pp
node default {
        file {
                "/tmp/helloworld.txt": content => "hello, world";
        }
}

# 等待runinterval 指定的时间，查看客户端是否成功 cat /tmp/helloworld.txt

# 强制指定主机同步
puppetrun -p 10 --host tc-12-77

# 让证书过期
puppet cert --revoke puppet-test

#　删除证书　先让证书过期
puppet cert --clean puppet-test

客户端：/etc/puppet/puppet.conf 的 [agent]标签下   
runinterval = 60  # 代表60秒跟服务器同步一次 

欢迎系统运维加群: 198173206   # 转载请保留
