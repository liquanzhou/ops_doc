Tomcat参数优化



maxThreads  客户请求最大线程数
minSpareThreads    Tomcat初始化时创建的 socket 线程数
maxSpareThreads   Tomcat连接器的最大空闲 socket 线程数
enableLookups      若设为true, 则支持域名解析，可把 ip 地址解析为主机名
redirectPort        在需要基于安全通道的场合，把客户请求转发到基于SSL 的 redirectPort 端口
acceptAccount       监听端口队列最大数，满了之后客户请求会被拒绝（不能小于maxSpareThreads  ）
connectionTimeout   连接超时
minProcessors         服务器创建时的最小处理线程数
maxProcessors        服务器同时最大处理线程数
URIEncoding    URL统一编码


其中和最大连接数相关的参数为maxProcessors 和 acceptCount 。如果要加大并发连接数，应同时加大这两个参数。
web server允许的最大连接数还受制于操作系统的内核参数设置，通常 Windows 是 2000 个左右， Linux 是 1000 个左右。


<Connector port="9027"   
  
protocol="HTTP/1.1"  
maxHttpHeaderSize="8192"  
minProcessors="100"  
maxProcessors="1000"  
acceptCount="1000"  
redirectPort="8443"  
disableUploadTimeout="true"/> 


<Connector port="9027"   
    protocol="HTTP/1.1"  maxHttpHeaderSize="8192"  maxThreads="1000"  
    maxProcessors="1000"  enableLookups="false"  connectionTimeout="20000"  
    URIEncoding="utf-8"  acceptCount="1000"  redirectPort="8443"  
    disableUploadTimeout="true"/>

<Connector port="80"   
    protocol="HTTP/1.1"  maxHttpHeaderSize="8192"  maxThreads="1000"  
    maxProcessors="1000"  enableLookups="false"  connectionTimeout="20000"  
    URIEncoding="utf-8"  acceptCount="1000"  redirectPort="8443"  
    disableUploadTimeout="true"/>	
			   
			   
<Connector port="9080"  protocol="HTTP/1.1"  
    maxHttpHeaderSize="8192"  maxThreads="500"  minThreads="25"
    minProcessors="100"  maxProcessors="1000"  
    enableLookups="false"  URIEncoding="utf-8"  acceptCount="1000"  
	redirectPort="8443"  disableUploadTimeout="true"/>  
	


虚拟主机(多域名绑定到同一IP)
    <Host name="www.123.com"  appBase="webapps" 
         unpackWARs="true" autoDeploy="true">      # name 域名  appBase 虚拟主机主程序目录  
        <Alias>www.456.com</Alias>                 # 其他域名
        <Context path ="" docBase ="/opt/tomcat/webapps1/test" debug ="0" reloadbale ="true" >         # war文件解压后移动到docBase路径 非webapps路径下
		</Context>
        <Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"
            prefix="localhost_access_log." suffix=".txt"
            pattern="%h %l %u %t &quot;%r&quot; %s %b" />        # 日志设置
    </Host>
	
	#日志设置
	prefix="localhost_access_log." suffix=".txt" pattern="%{X-Forwarded-For}i %h %l %u %t &quot;%r&quot; %s %b %{Referer}i %{User-Agent}i %D" />