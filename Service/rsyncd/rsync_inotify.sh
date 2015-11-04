rsync+inotify 实现数据实时同步20120619
========================================================================================
lab-1  10.0.0.103(代码更新服务器,通过rsync+inotify将变动同步到web服务器)
lab-2  10.0.0.105(web服务端-rsync服务端)
========================================================================================
需求:
当server端/data/rsync目录中有变动,自动同步clinet端的/data/rsync
相关软件下载地址:
http://sourceforge.net/projects/inotify-tools/files/inotify-tools/3.13/

web服务端部署:(lab-2)
----------------------------------------------------------------------------------------
yum install -y rsync
yum install -y xinetd

cat << EOF >> /etc/rsyncd.conf
#---------------------------------------------------------------------------------------
uid=root
gid=root
use chroot=no
max connections=20000
timeout=600
pid file=/var/run/rsyncd.pid
lock file=/var/run/rsync.lock
log file=/var/log/rsyncd.log

[r+inotify]
path=/data/rsync
comment = rsync+inotify
ignore errors
read only=false
list=false
hosts allow=10.0.0.103
hosts deny=0.0.0.0/32
auth users=inotify_user
secrets file=/shell/rsync-password/rsync.password
#---------------------------------------------------------------------------------------
EOF

mkdir -p /shell/{rsync-script,rsync-password}
echo "inotify_user:huaidan" >/shell/rsync-password/rsync.password
chmod 600 /shell/rsync-password/rsync.password
cat /shell/rsync-password/rsync.password
echo "/usr/bin/rsync --daemon">>/etc/rc.local
pkill rsync
rsync --daemon
ps -ef |grep rsync

(lab-1代码更新端配置如下)
yum install -y rsync
yum install -y xinetd
rpm -qa | grep rsync

mkdir -p /shell/{rsync-script,rsync-password}
echo "huaidan">/shell/rsync-password/rsync.password
chmod 600 /shell/rsync-password/rsync.password
cat /shell/rsync-password/rsync.password

mkdir -p /tools/r+inotify
cd /tools/r+inotify
wget http://cloud.github.com/downloads/rvoicilas/inotify-tools/inotify-tools-3.14.tar.gz
tar xzvf inotify-tools-3.14.tar.gz
cd inotify-tools-3.14
./configure
make
make install
cd ..

编写同步脚本:
mkdir -p /shell/r+inotify
cd /shell/r+inotify

vi r+inotify.sh
#-------------------------------------------------------------------------------------------------------
#!/bin/bash
#date:20120619
#version1.0
src=/data/rsync
#下面是认证模块
des=r+inotify
#多个IP写法host="10.0.0.105 10.0.0.106"
host="10.0.0.105"
/usr/local/bin/inotifywait -mrq --timefmt '%d/%m/%y %H:%M' --format '%T %w%f' -e modify,delete,create,attrib $src|while read files
do
for hostip in $host
do
rsync -vzrtopg --delete --progress --password-file=/shell/rsync-password/rsync.password $src inotify_user@$hostip::$des
done
echo "${files} was rsynced" >>/tmp/rsync.log 2>&1
done
#-------------------------------------------------------------------------------------------------------

chmod a+x r+inotify.sh

此处使用必杀技:screen挂后台:
/bin/bash /shell/r+inotify/r+inotify.sh &

=========================================================================================================
注释:
/usr/local/bin/inotifywait -mrq -e modify,delete,create,attrib ${src}
-m 是保持一直监听
-r 是递归查看目录
-q 是打印出事件
-e create,move,delete,modify,attrib 是指 “监听 创建 移动 删除 写入 权限” 事件
/usr/bin/rsync -ahqzt --delete $SRC $DST
-a 存档模式
-h 保存硬连接
-q 制止非错误信息
-z 压缩文件数据在传输
-t 维护修改时间
-delete 删除于多余文件
rsync的完整参数说明：
-v, --verbose 详细模式输出
-q, --quiet 精简输出模式
-c, --checksum 打开校验开关，强制对文件传输进行校验
-a, --archive 归档模式，表示以递归方式传输文件，并保持所有文件属性，等于-rlptgoD
-r, --recursive 对子目录以递归模式处理
-R, --relative 使用相对路径信息
-b, --backup 创建备份，也就是对于目的已经存在有同样的文件名时，将老的文件重新命名为~filename。可以使用--suffix选项来指定不同的备份文件前缀。
--backup-dir 将备份文件(如~filename)存放在在目录下。
-suffix=SUFFIX 定义备份文件前缀
-u, --update 仅仅进行更新，也就是跳过所有已经存在于DST，并且文件时间晚于要备份的文件。(不覆盖更新的文件)
-l, --links 保留软链结
-L, --copy-links 想对待常规文件一样处理软链结
--copy-unsafe-links 仅仅拷贝指向SRC路径目录树以外的链结
--safe-links 忽略指向SRC路径目录树以外的链结
-H, --hard-links 保留硬链结
-p, --perms 保持文件权限
-o, --owner 保持文件属主信息
-g, --group 保持文件属组信息
-D, --devices 保持设备文件信息
-t, --times 保持文件时间信息
-S, --sparse 对稀疏文件进行特殊处理以节省DST的空间
-n, --dry-run现实哪些文件将被传输
-W, --whole-file 拷贝文件，不进行增量检测
-x, --one-file-system 不要跨越文件系统边界
-B, --block-size=SIZE 检验算法使用的块尺寸，默认是700字节
-e, --rsh=COMMAND 指定使用rsh、ssh方式进行数据同步
--rsync-path=PATH 指定远程服务器上的rsync命令所在路径信息
-C, --cvs-exclude 使用和CVS一样的方法自动忽略文件，用来排除那些不希望传输的文件
--existing 仅仅更新那些已经存在于DST的文件，而不备份那些新创建的文件
--delete 删除那些DST中SRC没有的文件
--delete-excluded 同样删除接收端那些被该选项指定排除的文件
--delete-after 传输结束以后再删除
--ignore-errors 及时出现IO错误也进行删除
--max-delete=NUM 最多删除NUM个文件
--partial 保留那些因故没有完全传输的文件，以是加快随后的再次传输
--force 强制删除目录，即使不为空
--numeric-ids 不将数字的用户和组ID匹配为用户名和组名
--timeout=TIME IP超时时间，单位为秒
-I, --ignore-times 不跳过那些有同样的时间和长度的文件
--size-only 当决定是否要备份文件时，仅仅察看文件大小而不考虑文件时间
--modify-window=NUM 决定文件是否时间相同时使用的时间戳窗口，默认为0
-T --temp-dir=DIR 在DIR中创建临时文件
--compare-dest=DIR 同样比较DIR中的文件来决定是否需要备份
-P 等同于 --partial
--progress 显示备份过程
-z, --compress 对备份的文件在传输时进行压缩处理
--exclude=PATTERN 指定排除不需要传输的文件模式
--include=PATTERN 指定不排除而需要传输的文件模式
--exclude-from=FILE 排除FILE中指定模式的文件
--include-from=FILE 不排除FILE指定模式匹配的文件
--version 打印版本信息
--address 绑定到特定的地址
--config=FILE 指定其他的配置文件，不使用默认的rsyncd.conf文件
--port=PORT 指定其他的rsync服务端口
--blocking-io 对远程shell使用阻塞IO
-stats 给出某些文件的传输状态
--progress 在传输时现实传输过程
--log-format=formAT 指定日志文件格式
--password-file=FILE 从FILE中得到密码
--bwlimit=KBPS 限制I/O带宽，KBytes per second
-h, --help 显示帮助信息
要排除同步某个目录时，为rsync添加--exculde=PATTERN参数，注意，路径是相对路径，具体查看man rsync。
要排除某个目录的事件监听的处理时，为inotifywait添加--exclude或--excludei参数，具体查看man inotifywait。

