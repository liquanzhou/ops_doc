
可以在主机上直接tail读取日志写入kafka


系统要求centos6+

https://github.com/edenhill/kafkacat




yum -y install gcc-c++ cmake

unzip kafkacat-master.zip 

cd kafkacat-master

# 需要外网 wget https
sh bootstrap.sh

vim /opt/smc/kafkacat.sh

# tail 用大F 可以再文件被mv后重试  如果topic不存在则创建
nohup tail -F t1.log  |/opt/kafkacat/kafkacat -P  -b 10.10.91.91:9092,10.10.91.92:9092,10.10.91.93:9092  -t aa_test_topic &


echo "/opt/smc/kafkacat.sh" >>/etc/rc.d/rc.local 
chmod 744 /opt/smc/kafkacat.sh


# 注意如果无法wget下载 可以将包放到内网 修改脚本安装

http://10.10.20.79/software/kafkacat/librdkafka.tar.gz
http://10.10.20.79/software/kafkacat/yajl.tar.gz

vim bootstrap.sh

url=http://10.10.20.79/software/kafkacat/${repo}.tar.gz

github_download "librdkafka" "master" "librdkafka"
github_download "yajl" "master" "libyajl"
