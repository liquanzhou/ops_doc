通过SNMP获取接口速率 数据类型counter32位与counter64位的区别


       首先，接口的速率是指单位时间内数据总量，那么实际在监控时也是通过数据总量这个累计值来计算得出速率，这个累计值MIB中是有自己的名称的。这个名称暂且不谈，从设计出发点上来讲，咱们通过这个值主要是为了获得速率等信息，但是这个值是个累计值，这就会导致这个值可以无限的增加，大家知道计算机处理数据时是有位长限制的，那么怎么办呢？将这个值清0重新进行计算。这样就有了个最大值，当达到这个值时，就会重新计算，这个值即2^32或2^64。

     在MIB中，ifOutOctets和ifInOctets来分别表示接口流出数据量和接口流入数据量，单位是字节。其数据类型为counter32。其能表示最大值为2^32Byte=4GB。ifHCOutOctets和ifHCInOctets也是分别表示接口流出数据量和接口流入数据量其数据类型为counter64，最大值为16EB这个值的概念是如果千兆口满跑4000多年才能达到。但是如果是counter32位的呢，千兆口满跑32秒即可达到此值。那么这就派生出问题了，如果接口的速率非常高那么用32位的来获取的值很有可能就不准确了。所以大家尽量使用64位的来取值，但前提是系统支持。这个可以通过MIB browser来扫描判断。

其他：

IF-MIB:ifInOctets
OID  1.3.6.1.2.1.2.2.1.10
Type  Counter32

The total number of octets received on the interface , including framing characters.
 
Discontinuities in the value of this counter can occur at re-initialization of the management system , and at other times as indicated by the value of ifCounterDiscontinuityTime.

 

IF-MIB:ifOutOctets
OID  1.3.6.1.2.1.2.2.1.16
Type  Counter32

The total number of octets transmitted out of the interface , including framing characters.
 
Discontinuities in the value of this counter can occur at re-initialization of the management system , and at other times as indicated by the value of ifCounterDiscontinuityTime.

 


IF-MIB:ifHCInOctets
OID  1.3.6.1.2.1.31.1.1.1.6
Type  Counter64

 

The total number of octets received on the interface , including framing characters. This object is a 64-bit version of ifInOctets.
 
Discontinuities in the value of this counter can occur at re-initialization of the management system , and at other times as indicated by the value of ifCounterDiscontinuityTime.

 

IF-MIB:ifHCOutOctets
OID  1.3.6.1.2.1.31.1.1.1.10
Type  Counter64

The total number of octets transmitted out of the interface , including framing characters. This object is a 64-bit version of ifOutOctets.
 
Discontinuities in the value of this counter can occur at re-initialization of the management system , and at other times as indicated by the value of ifCounterDiscontinuityTime.