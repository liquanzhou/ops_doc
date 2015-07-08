
ssdb安装

SSDB is a high performace key-value(key-string, key-zset, key-hashmap) NoSQL database, an alternative to Redis.

 Compile and Install
wget  https://codeload.github.com/ideawu/ssdb/tar.gz/1.6.8.8

unzip master
cd ssdb-master
make
#optional, install ssdb in /usr/local/ssdb
sudo make install

# start master
#./ssdb-server ssdb.conf

# ip: 192.168.12.143
# or start as daemon
./ssdb-server -d ssdb.conf

cache_size   # 内存大小M

# ssdb command line
./ssdb-cli -p 8888

# stop ssdb-server
kill `cat ./var/ssdb.pid`



PHP client API example

<?php
require_once('SSDB.php');
$ssdb = new SimpleSSDB('127.0.0.1', 8888);
$resp = $ssdb->set('key', '123');
$resp = $ssdb->get('key');
echo $resp; // output: 123



./ssdb-cli -p 8888
set aaa dddd
get aaa
flushdb   # 清空所有数据




