如何查找Linux系统网卡流量的SNMP OID



首先执行 snmpwalk -v1 localhost -c public | grep bond0

可以得到其中一条结果

IF-MIB::ifDescr.7= STRING: bond0

结果中的“.7”基本上就是代表了bond0这块网卡

然后继续查ifInOctets和ifOutOctets，一个输入流量，一个是输出流量，根据上面猜的bond0是“.7”

那么bond0的网卡输入输出流量就分别是ifInOctets.7和ifOutOctets.7了

这样执行snmpget -v1 -c public -On localhost ifInOctets.7和snmpget -v1 -c public -On localhost ifOutOctets.7

就可以得到bond0网卡输入和输出流量的OID了

.1.3.6.1.2.1.2.2.1.10.7= Counter32: 1916015224 输入流量

.1.3.6.1.2.1.2.2.1.16.7= Counter32: 1342069080 输出流量