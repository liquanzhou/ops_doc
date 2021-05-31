puppet学习之puppet证书验证

一、    关于证书在master的认识

我们知道puppet为了安全，采用ssl隧道通信，因此需要申请证书来验证的，当puppet master第一次启动的时候，可以查看/var/log/message有类似如下的信息：

Jul 25 03:14:01 localhost puppet-master[25011]: Signed certificate request for ca

Jul 25 03:14:01 localhost puppet-master[25011]: Rebuilding inventory file

Jul 25 03:14:01 localhost puppet-master[25011]: puppet.zhang.com has a waiting certificate request

Jul 25 03:14:01 localhost puppet-master[25011]: Signed certificate request for puppet.zhang.com

Jul 25 03:14:01 localhost puppet-master[25011]: Removing file Puppet::SSL::CertificateRequest puppet.zhang.com at '/etc/puppet/ssl/ca/requests/puppet.zhang.com.pem'

Jul 25 03:14:01 localhost puppet-master[25011]: Removing file Puppet::SSL::CertificateRequest puppet.zhang.com at '/etc/puppet/ssl/certificate_requests/puppet.zhang.com.pem'

从日志中我们可以看出第一次启动的时候，puppet master创建本地认证中心，给自己签发证书和key，你可以在/etc/puppet/ssl看到那些证书和key。这个目录和/etc/puppet/puppet.conf文件中配置的ssldir路径有关系。

ll /etc/puppet/ssl/   ssl目录的内容如下：

drwxrwx--- 5 puppet puppet 4096 Jul 25 03:01 ca

drwxr-xr-x 2 puppet root   4096 Jul 25 03:01 certificate_requests

drwxr-xr-x 2 puppet root   4096 Jul 25 03:01 certs

-rw-r--r-- 1 puppet puppet  398 Jul 25 03:01 crl.pem

drwxr-x--- 2 puppet root   4096 Jul 25 03:01 private

drwxr-x--- 2 puppet root   4096 Jul 25 03:01 private_keys

drwxr-xr-x 2 puppet root   4096 Jul 25 03:01 public_keys

 

二、    关于证书在agent的认识

puppet agent在第一次连接master的时候会向master申请证书，如果没有master没有签发证书，那么puppet agent和master的连接是否建立成功的，agent会持续等待master签发证书，并会每隔2分钟去检查master是否签发证书。

通过puppet agent --server= puppet.zhang.com --no-daemonize –verbose启动的时候能很清楚的查看到agent申请证书的过程

puppet agent --server=puppet.zhang.com --no-daemonize --verbose

info: Creating a new SSL key for node1.zhang.com

info: Caching certificate for ca

#申请证书

info: Creating a new SSL certificate request for node1.zhang.com

info: Certificate Request fingerprint (md5): 54:11:FB:75:87:94:AF:6B:D1:6B:AD:6B:44:3E:74:A0

#等待证书签发

warning: peer certificate won it be verified in this SSL session 

#2分钟检查一次，如果没有签发就显示如下信息

notice: Did not receive certificate

#证书签发成功后，顺利建立连接

info: Caching certificate for node1.zhang.com

notice: Starting Puppet client version 2.6.16

info: Caching certificate_revocation_list for ca

info: Caching catalog for node1.zhang.com

info: Applying configuration version '1344943902'

notice: Finished catalog run in 0.11 seconds

                   类似于上面的就是去申请证书了。当master签发证书以后就可以顺利建立连接了。

 

三、    Master端证书的管理


查看通过验证的证书
puppet cert list -all

1.         在master上查看申请证书请求

puppet cert --list

2.         签发证书

puppet cert --sign node1.zhang.com

如果一次性签发所有的证书，采用如下命令：

puppet cert --sign –all

也可以设置自动签发证书。

3.         让证书过期

puppet cert --revoke puppet-test

删除证书

puppet cert --clean puppet-test

证书签名的过期或删除需要重启puppetmaster服务。

4.         可以通过/etc/puppet/auth.conf文件配置签名的ACL列表。

 

四、    Agent端证书的管理

1.         删除已有的证书

清空 /etc/puppet/ssl(这个目录和你的/etc/puppet/puppet.conf文件中配置的ssldir路径有关系)下的文件和目录

2.         重启申请证书

puppet agent --server puppet.zhang.com --test

在客户端与服务端签名不能正常进行的时候，请删除后重新签名