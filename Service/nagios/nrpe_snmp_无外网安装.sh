#!/bin/bash

version=`cat /etc/issue |awk 'NR==1{print $3}'`
case $version in
6.3)
find /etc/yum.repos.d -name "*.repo" -exec mv {} {}.bak \;
cat <<EOF >/etc/yum.repos.d/yum.repo
[yum]
baseurl=http://10.0.0.1/centos6.3_64
enable=1
EOF
rpm --import  /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6
;;
5.5)
find /etc/yum.repos.d -name "*.repo" -exec mv {} {}.bak \;
cat <<EOF >/etc/yum.repos.d/yum.repo
[yum]
baseurl=http://10.0.0.1/centos5.5
enable=1
EOF
rpm --import  /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5
;;
*)
echo "yum error"
read
exit
;;
esac
yum -y install xinetd  sysstat net-snmp
rpm -q xinetd >/dev/null
if [ "$?" -ge 1 ];then
echo "xinetd install error"
read
exit
fi
rpm -q net-snmp >/dev/null
if [ "$?" -ge 1 ];then
echo "net-snmp install error"
read
exit
fi


wget --directory-prefix=/tmp/ http://10.0.0.1/monitor/nrpe-2.8.1.tar.gz
wget --directory-prefix=/tmp/ http://10.0.0.1/monitor/nagios-plugins-1.4.13.tar.gz
wget --directory-prefix=/tmp/ http://10.0.0.1/monitor/snmpd.conf
cd /tmp
tar -zxf nagios-plugins-1.4.13.tar.gz
tar -zxf nrpe-2.8.1.tar.gz

useradd nagios
echo "saongroup" | passwd --stdin nagios
usermod -s /sbin/nologin nagios
cd nagios-plugins-1.4.13
./configure 1>/dev/null
make 1>/dev/null
make install 1>/dev/null
chown nagios.nagios /usr/local/nagios
chown -R nagios.nagios /usr/local/nagios/libexec
cd ../nrpe-2.8.1
./configure 1>/dev/null
make all 1>/dev/null
make install-plugin 1>/dev/null
make install-daemon 1>/dev/null
make install-daemon-config 1>/dev/null
make install-xinetd 1>/dev/null
sed -i 's#127.0.0.1#127.0.0.1 117.121.30.8 10.0.1.8#g' /etc/xinetd.d/nrpe
sed -i '/only_from/a\\tlog_type\t= file \/dev\/null' /etc/xinetd.d/nrpe
echo "nrpe            5666/tcp                        # nrpe"  >> /etc/services
sed -i 's#check_disk -w 20 -c 10 -p /dev/hda1#check_disk -w 20% -c 10% -u GB#g' /usr/local/nagios/etc/nrpe.cfg
echo "command[check_swap]=/usr/local/nagios/libexec/check_swap -w 20% -c 10%"  >> /usr/local/nagios/etc/nrpe.cfg
echo "command[check_tcp]=/usr/local/nagios/libexec/check_tcp -p 80"  >> /usr/local/nagios/etc/nrpe.cfg
echo "command[check_iostat]=/usr/local/nagios/libexec/check_iostat -w 5 -c 10" >> /usr/local/nagios/etc/nrpe.cfg
service xinetd restart
cat /tmp/snmpd.conf >/etc/snmp/snmpd.conf
sed -i 's/^OPTIONS=\"-LS0-6d/OPTIONS=\"-LS3d/' /etc/init.d/snmpd
sed -i 's/^OPTIONS=\"-Lsd/OPTIONS=\"-LS3d/' /etc/init.d/snmpd
/etc/init.d/snmpd restart
echo '/etc/init.d/snmpd restart' >> /etc/rc.d/rc.local
rm -rf /tmp/nagios-plugins* /tmp/nrpe-2.8.1* /tmp/snmpd.conf
rm -f /tmp/nagios.sh 
