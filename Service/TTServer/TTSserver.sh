
study notes
TT 双主生产环境实例批量创建实例 以及自动检测脚本

简单安装如下:

wget http://fallabs.com/tokyotyrant/tokyotyrant-1.1.41.tar.gz
wget http://fallabs.com/tokyocabinet/tokyocabinet-1.4.48.tar.gz

yum install zlib* bzip2* -y

tar zxvf tokyocabinet-1.4.48.tar.gz
cd tokyocabinet-1.4.48/
./configure --prefix=/usr/local/tc
make
make install
cd ../

tar zxvf tokyotyrant-1.1.41.tar.gz
cd tokyotyrant-1.1.41/
./configure --prefix=/usr/local/tt \
--with-tc=/usr/local/tc
make
make install
cd ../

我们定义:192.168.0.101 和192.168.0.102互为双主 相关实例创建脚本如下:

192.168.0.101:1010 服务器:

 1 [root@BJ-X-C-TT-1000-1010-M1 start_script]# cat start_1010.sh 
 2 #!/bin/bash
 3 #Date:2013-04-24
 4 #C-ZhangLuYa
 5 
 6 
 7 #define path
 8  Remote_IP="192.168.0.102"
 9  Port="1010"
10  Data_path="/data/tt/tt_${Port}/"
11  Install_path="/usr/local/tt/"
12  Ip=`/sbin/ifconfig eth1|grep "inet addr:"|awk '{print $2}'|awk -F: '{print $2}'`
13  Sid=`/sbin/ifconfig eth1|grep "inet addr:"|awk '{print $2}'|awk -F: '{print $2}'|awk -F"." '{print $4}'`
14  
15 #source function library
16  . /etc/init.d/functions 
17    
18 #check tt data_file_dir 
19 if [ ! -e ${Data_path} ];then
20         mkdir -p ${Data_path}
21         echo "----------------------------------" 
22         echo "${Data_path} create is ok!"
23         echo "----------------------------------"
24 #else
25         #echo "----------------------------------"
26         #printf "${Data_path} is already exist!\n"
27         #echo "----------------------------------"
28 fi 
29 
30 #ttserver stop && start function 
31 TTSTART(){
32    if [ ! -e ${Data_path}${Port}.pid ];then
33         ${Install_path}bin/ttserver -host ${Ip} -port ${Port} -thnum 30 -dmn -pid ${Data_path}${Port}.pid -log \
34         ${Data_path}${Port}.log -le -ulog ${Data_path} -ulim 4096m -sid ${Sid} -mhost ${Remote_IP} -mport ${Port} \
35         -mul 15 -rts ${Data_path}${Port}.rts ${Data_path}${Port}.tch#bnum=500000
36         sleep 2
37         #echo "start is ok!"
38         echo -e "-------------------------------------------------------------------"  
39         action "Tokyo tyrant start is ..................^_^ " /bin/true
40     else
41         echo "Tokyo tyrant ${Port} process is already exist!!!"
42     fi
43  } 
44 
45 TTSTOP(){
46     #resolve "cat: /data/tt/tt_1971/1971.pid: No such file or directory"
47     if [ -e  ${Data_path}${Port}.pid ];then
48         kill -TERM `cat ${Data_path}${Port}.pid` >/dev/null 2>&1
49         /bin/mv ${Data_path}${Port}.pid /tmp > /dev/null 2>&1
50         #echo "stop is ok!"
51         sleep 2
52         action "Tokyo tyrant stop is .................. -_-!" /bin/true
53     else
54         echo "Tokyo tyrant ${Port} process is not found!!!!"
55     fi   
56  }
57    
58 #load function start or stop ttserver
59 case "$1" in
60     start|START)
61           TTSTART
62           ;;
63     stop|STOP)
64           TTSTOP
65           ;;
66     restart)
67           TTSTOP
68           sleep 3
69           TTSTART
70           ;;
71     *)
72           echo "Usage:`basename $0` {start|stop|restart}"
73           exit 1
74 esac

192.168.0.102:1010 服务器:

 1 [root@BJ-X-C-TT-1000-1010-M2 start_script]# cat start_1010.sh 
 2 #!/bin/bash
 3 #Date:2013-04-24
 4 #C-ZhangLuYa
 5 
 6 
 7 #define path
 8  Remote_IP="192.168.0.101"
 9  Port="1010"
10  Data_path="/data/tt/tt_${Port}/"
11  Install_path="/usr/local/tt/"
12  Ip=`/sbin/ifconfig eth1|grep "inet addr:"|awk '{print $2}'|awk -F: '{print $2}'`
13  Sid=`/sbin/ifconfig eth1|grep "inet addr:"|awk '{print $2}'|awk -F: '{print $2}'|awk -F"." '{print $4}'`
14  
15 #source function library
16  . /etc/init.d/functions 
17    
18 #check tt data_file_dir 
19 if [ ! -e ${Data_path} ];then
20         mkdir -p ${Data_path}
21         echo "----------------------------------" 
22         echo "${Data_path} create is ok!"
23         echo "----------------------------------"
24 #else
25         #echo "----------------------------------"
26         #printf "${Data_path} is already exist!\n"
27         #echo "----------------------------------"
28 fi 
29 
30 #ttserver stop && start function 
31 TTSTART(){
32    if [ ! -e ${Data_path}${Port}.pid ];then
33         ${Install_path}bin/ttserver -host ${Ip} -port ${Port} -thnum 30 -dmn -pid ${Data_path}${Port}.pid -log \
34         ${Data_path}${Port}.log -le -ulog ${Data_path} -ulim 4096m -sid ${Sid} -mhost ${Remote_IP} -mport ${Port} \
35         -mul 15 -rts ${Data_path}${Port}.rts ${Data_path}${Port}.tch#bnum=500000
36         sleep 2
37         #echo "start is ok!"
38         echo -e "-------------------------------------------------------------------"  
39         action "Tokyo tyrant start is ..................^_^ " /bin/true
40     else
41         echo "Tokyo tyrant ${Port} process is already exist!!!"
42     fi
43  } 
44 
45 TTSTOP(){
46     #resolve "cat: /data/tt/tt_1971/1971.pid: No such file or directory"
47     if [ -e  ${Data_path}${Port}.pid ];then
48         kill -TERM `cat ${Data_path}${Port}.pid` >/dev/null 2>&1
49         /bin/mv ${Data_path}${Port}.pid /tmp > /dev/null 2>&1
50         #echo "stop is ok!"
51         sleep 2
52         action "Tokyo tyrant stop is .................. -_-!" /bin/true
53     else
54         echo "Tokyo tyrant ${Port} process is not found!!!!"
55     fi   
56  }
57    
58 #load function start or stop ttserver
59 case "$1" in
60     start|START)
61           TTSTART
62           ;;
63     stop|STOP)
64           TTSTOP
65           ;;
66     restart)
67           TTSTOP
68           sleep 3
69           TTSTART
70           ;;
71     *)
72           echo "Usage:`basename $0` {start|stop|restart}"
73           exit 1
74 esac

批量实例建立脚本:

1 [root@BJ-X-C-TT-1000-1010-M2 start_script]# cat copy.sh 
2 for i in {1001..1010}
3     do
4     echo $i
5     cp start_1000.sh start_${i}.sh
6     sed -i 's/1000/'''$i'''/g' start_${i}.sh 
7     echo "/usr/local/tt/start_script/start_${i}.sh start" >> all_start.sh 2>&1
8     echo "/usr/local/tt/start_script/start_${i}.sh stop" >> all_stop.sh 2>&1
9 done

批量端口检测脚本:

 1 [root@BJ-X-C-TT-1000-1010-M2 start_script]# cat check_status.sh 
 2 #!/bin/bash
 3 
 4 for((i=1000;i<=1010;i++))
 5     do
 6     echo "--------------------------------------------------------------------"
 7     echo $i is ok!
 8     /usr/local/tt/bin/tcrmgr inform -port $i 192.168.0.102 > check_tt.log 2>&1
 9     /usr/local/tt/bin/tcrmgr inform -port $i 192.168.0.102
10     STATUS=`grep "refused" check_tt.log|wc -l`
11     #STATUS=0 OK
12     #STATUS=1 DOWN
13     if [[ ${STATUS} = 1 ]];then
14     echo "PORT $i IS DOWN!"
15     /usr/local/tt/start_script/start_${i}.sh restart
16     sleep 2
17     fi
18     #echo "--------------------------------------------------------------------"
19     done

 

 TT单实例自动创建脚本如下:

 1 [root@BJ-X-Public-TT-1 start_script]# cat start_1002.sh 
 2 #!/bin/bash
 3 #Date:2013-04-24
 4 #C-ZhangLuYa
 5 
 6 
 7 #define path
 8  Port="1002"
 9  Data_path="/data/tt/tt_${Port}/"
10  Install_path="/usr/local/tt/"
11  Ip=`/sbin/ifconfig eth1|grep "inet addr:"|awk '{print $2}'|awk -F: '{print $2}'`
12  Sid=`/sbin/ifconfig eth1|grep "inet addr:"|awk '{print $2}'|awk -F: '{print $2}'|awk -F"." '{print $4}'`
13  
14 #source function library
15  . /etc/init.d/functions 
16    
17 #check tt data_file_dir 
18 if [ ! -e ${Data_path} ];then
19         mkdir -p ${Data_path}
20         echo "----------------------------------" 
21         echo "${Data_path} create is ok!"
22         echo "----------------------------------"
23 #else
24         #echo "----------------------------------"
25         #printf "${Data_path} is already exist!\n"
26         #echo "----------------------------------"
27 fi 
28 
29 #ttserver stop && start function 
30 TTSTART(){
31    if [ ! -e ${Data_path}${Port}.pid ];then
32         ${Install_path}bin/ttserver -host ${Ip} -port ${Port} -thnum 30 -dmn -pid ${Data_path}${Port}.pid -log \
33         ${Data_path}${Port}.log -le -ulog ${Data_path} -ulim 4096m -sid ${Sid} -mul 15 -rts ${Data_path}${Port}.rts \
34         ${Data_path}${Port}.tch#bnum=500000
35         sleep 2
36         #echo "start is ok!"
37         echo -e "-------------------------------------------------------------------"  
38         action "Tokyo tyrant start is ..................^_^ " /bin/true
39     else
40         echo "Tokyo tyrant ${Port} process is already exist!!!"
41     fi
42  } 
43 
44 TTSTOP(){
45     #resolve "cat: /data/tt/tt_1971/1971.pid: No such file or directory"
46     if [ -e  ${Data_path}${Port}.pid ];then
47         kill -TERM `cat ${Data_path}${Port}.pid` >/dev/null 2>&1
48         /bin/mv ${Data_path}${Port}.pid /tmp > /dev/null 2>&1
49         #echo "stop is ok!"
50         sleep 2
51         action "Tokyo tyrant stop is .................. -_-!" /bin/true
52     else
53         echo "Tokyo tyrant ${Port} process is not found!!!!"
54     fi   
55  }
56    
57 #load function start or stop ttserver
58 case "$1" in
59     start|START)
60           TTSTART
61           ;;
62     stop|STOP)
63           TTSTOP
64           ;;
65     restart)
66           TTSTOP
67           sleep 3
68           TTSTART
69           ;;
70     *)
71           echo "Usage:`basename $0` {start|stop|restart}"
72           exit 1
73 esac

