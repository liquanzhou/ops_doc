BIND压力测试软件queryperf 

bind的本身就自带压测软件，只是默认编译的时候不被编译。
Bind 主页：

http://www.isc.org

1、下载bind软件，

# wget http://ftp.isc.org/isc/bind9/9.7.3/bind-9.7.3.tar.gz
        # tar zxvf bind-9.7.3.tar.gz
        # cd bind-9.7.3/contrib/queryperf/

2、安装queryperf
看一下README 说的很想详细。

# ./configure
# make

编译完之后会生成queryperf 文件。
使用方法：

# queryperf -d input_file -s server
 input_file:压力测试的时候读取的文件，
          格式： www.turku.fi A
                 www.helsinki.fi A
 server:要测试dns服务器的IP。

