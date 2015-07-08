twemcache

mkdir -p /opt/soft 
cd /opt/soft
yum install -y libevent-devel
wget http://10.10.76.79:81/muzy/software/twemcache-2.5.0.tar.gz;\
tar zxvf twemcache-2.5.0.tar.gz
cd /opt/soft/twemcache-2.5.0
./configure --prefix=/opt/twemcache
make 
make install


/opt/twemcache/bin/twemcache -d -m4096 -p60001 -u root -P /opt/twemcache/tw_60001.pid -X /opt/twemcache/cmd_60001.log -l $ip
#可启动多个