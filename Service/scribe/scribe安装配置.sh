 scribe安装配置


RHEL 5.7

10.10.76.42 /opt/nimin/scribe

3个rpm文件

apache-thrift-0.7.0-1.x86_64.rpm              scribe_admin.sh
fb303-0.7.0-1.x86_64.rpm          scribe-2.2-3.x86_64.rpm  

RHEL 6.0+

yum -y install gcc-c++ libtool libevent libevent-devel zlib-devel python-devel ruby ruby-devel automake autoconf libxml2 byacc flex bison bzip2-devel openssl-devel php

tar -zxvf boost_1_45_0.tar.gz
cd boost_1_45_0
sh bootstrap.sh
./bjam -s HAVE_ICU=1 --prefix=/opt/boost
./bjam install --prefix=/opt/boost
vim /etc/profile

tar -zxvf thrift-0.7.0.tar.gz
cd thrift-0.7.0
chmod 755 configure
./configure --prefix=/opt/thrift --with-boost=/opt/boost
make
make install
cd contrib/
cd fb303/
chmod 755 bootstrap.sh
./bootstrap.sh --with-boost=/opt/boost
./configure --with-boost=/opt/boost --with-thriftpath=/opt/thrift --prefix=/opt/thrift/fb303
make
make install

unzip facebook-scribe-63e4824.zip
cd facebook-scribe-63e4824
./bootstrap.sh --with-boost=/opt/boost
./configure --prefix=/opt/scribe --with-boost=/opt/boost --with-thriftpath=/opt/thrift --with-fb303path=/opt/thrift/fb303
make
make install
