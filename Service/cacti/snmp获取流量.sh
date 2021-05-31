
# 查看所有snmp信息
snmpwalk -v 2c -c public localhost


# 查看网卡对应数，与OID对应
snmpwalk -v 2c -c public localhost ifDescr
IF-MIB::ifDescr.1 = STRING: lo
IF-MIB::ifDescr.2 = STRING: eth0
IF-MIB::ifDescr.3 = STRING: eth1
IF-MIB::ifDescr.4 = STRING: eth2
IF-MIB::ifDescr.5 = STRING: eth3

# 只有总的流量，需要自己计算
# 流量一定要使用 Counter64 的值
# 版本使用 -v 2c 

出
snmpget -v 2c -c public -On localhost ifHCOutOctets.2
snmpget -v 2c -c public -On localhost .1.3.6.1.2.1.31.1.1.1.10.2
.1.3.6.1.2.1.31.1.1.1.10.2 = Counter64: 269253161392640

进
snmpget -v 2c -c public -On localhost ifHCInOctets.2
snmpget -v 2c -c public -On localhost .1.3.6.1.2.1.31.1.1.1.6.2
.1.3.6.1.2.1.31.1.1.1.6.2 = Counter64: 291251341055042


# snmp获取的值应和本机上查看的基本一致

ifconfig eth0 |grep 'RX bytes'
RX bytes:291252542248416 (264.8 TiB)  TX bytes:269254268251816 (244.8 TiB)


awk '/eth0/{print $1,$9}' /proc/net/dev
eth0:291275596455967 269280448788614
Receive  Transmit