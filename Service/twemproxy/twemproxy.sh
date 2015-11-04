twemproxy

yum install automake libtool 

https://github.com/twitter/twemproxy

yum install automake libtool 
rpm -e autoconf --nodeps
wget http://ftp.gnu.org/gnu/autoconf/autoconf-2.64.tar.gz 
tar zxvpf autoconf-2.64.tar.gz
cd autoconf-2.64
./configure
make && make install


yum install git
git clone git@github.com:twitter/twemproxy.git
cd twemproxy
或
wget https://github.com/twitter/twemproxy/archive/master.zip
unzip master
cd twemproxy-master

/usr/local/bin/autoreconf -fvi
./configure --enable-debug=full
make
src/nutcracker -h



/opt/soft/twemproxy-master/src/nutcracker -c /opt/soft/twemproxy-master/conf/nutcracker.leaf.yml -d


# 1对于代理
leaf:
  listen: 10.10.76.70:22121
  hash: fnv1a_64
  distribution: ketama
  auto_eject_hosts: true
  server_retry_timeout: 2000
  server_failure_limit: 1
  servers:
   - 10.13.80.118:22134:1





