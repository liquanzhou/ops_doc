NFS搭建

NFS：Network File System

功能也就是能把远程网络的文件挂载到NFS Server上，在Server上看来，客户端的挂载的目录就像自己的子目录一样，可以对它操作。所以，对于嵌入式系统的调试是很方便的。

NFS支持的功能很多，所以对应的端口号是不固定的，是随机分配的，但都是小于1024。那么客户机是怎么连接到NFS Server上去的呢？这里有一个RPC的东西来支持。
RPC：（Remote Procedure Call Protocol）

远程过程调用协议，它是一种通过网络从远程计算机程序上请求服务，而不需要了解底层网络技术的协议。RPC协议假定某些传输协议的存在，如TCP或UDP，为通信程序之间携带信息数据。在OSI网络通信模型中，RPC跨越了传输层和应用层。RPC使得开发包括网络分布式多程序在内的应用程序更加容易。RPC采用客户机/服务器模式。请求程序就是一个客户机，而服务提供程序就是一个服务器。首先，客户机调用进程发送一个有进程参数的调用信息到服务进程，然后等待应答信息。在服务器端，进程保持睡眠状态直到调用信息的到达为止。当一个调用信息到达，服务器获得进程参数，计算结果，发送答复信息，然后等待下一个调用信息，最后，客户端调用进程接收答复信息，获得进程结果，然后调用执行继续进行。
RPC在NFS搭建过程钟的功能就是在Server上分配端口号，可以让客户端能从远程连接上Server。RPC固定采用111端口监听。

所以整个NFS实现的过程就是：

    Client向服务器的RPC（port 111）发出请求
    服务器注册好端口，把端口信息传回客户端
    客户端知道正确的端口后，可以连接NFS daemon

NFS 安装：nfs-utils(主要NFS功能) portmap(RPC 端口分配)

可以先rpm -qa | grep xxx 查看下，若不存在则安装！

vim /etc/exports    # 在这里可以对客户端各种权限的设置

/tmp *(rw,no_root_squash)   # 允许任何IP挂载/tmp目录

NFS 启动
/etc/init.d/portmap start   # portmap启动
/etc/init.d/nfs start       # nfs启动
service nfs reload          # 重新加载exports

netstat -tunl | grep "111"      # 查看portmap有没有启动
chkconfig –list | grep "nfs"    # 查看nfs服务是否启动
showmount -e localhost          # 查看本地共享文件系统


NFS文件挂载
mount -t nfs 127.0.0.1:/tmp /mnt           # 进入/mnt查看
mount -t nfs 10.0.0.3:/tmp  /data/img      # 远程网络挂载



/etc/exports 权限说明

/tmp         192.168.100.0/24(ro)   localhost(rw)   *.ev.ncku.edu.tw(ro,sync)
[分享目錄]   [第一部主機(權限)]     [可用主機名]    [可用萬用字元]

rw    ro 	                     # 該目錄分享的權限是可讀寫 (read-write) 或唯讀 (read-only)，但最終能不能讀寫，還是與檔案系統的 rwx及身份有關。
sync  async 	                 # sync 代表資料會同步寫入到記憶體與硬碟中，async 則代表資料會先暫存於記憶體當中，而非直接寫入硬碟！
no_root_squash  root_squash 	 # 用戶端使用 NFS 檔案系統的帳號若為 root 時，系統該如何判斷這個帳號的身份？預設的情況下，用戶端 root 的身份會由 root_squash 的設定壓縮成 nfsnobody，如此對伺服器的系統會較有保障。但如果你想要開放用戶端使用 root 身份來操作伺服器的檔案系統，那麼這裡就得要開 no_root_squash 才行！
all_squash 	                     # 不論登入 NFS 的使用者身份為何， 他的身份都會被壓縮成為匿名使用者，通常也就是 nobody(nfsnobody) 啦！
anonuid  anongid 	             # anon 意指 anonymous (匿名者) 前面關於 *_squash 提到的匿名使用者的 UID 設定值，通常為 nobody(nfsnobody)，但是你可以自行設定這個 UID 的值！當然，這個 UID 必需要存在於你的 /etc/passwd 當中！anonuid 指的是 UID 而 anongid 則是群組的 GID 囉。


/tmp          *(rw,no_root_squash)
/home/public  192.168.100.0/24(rw)    *(ro)
/home/test    192.168.100.10(rw)
/home/linux   *.centos.vbird(rw,all_squash,anonuid=45,anongid=45)





    # 依赖rpc服务通信 portmap 或 rpcbind
    yum install nfs-utils portmap    # centos5安装  
    yum install nfs-utils rpcbind    # centos6安装

    vim /etc/exports                 # 配置文件
    /data/images 10.10.10.10(rw,sync,no_root_squash)

    service  portmap restart         # 重启centos5的nfs依赖的rpc服务
    service  rpcbind restart         # 重启centos6的nfs依赖的rpc服务
    service  nfs restart             # 重启nfs服务  确保依赖 portmap 或 rpcbind 服务已启动
    /etc/init.d/nfs reload           # 重载NFS服务配置文件  
    showmount -e                     # 服务端查看自己共享的服务
    showmount -a                     # 显示已经与客户端连接上的目录信息
    showmount -e 110.10.10.3         # 列出服务端可供使用的NFS共享  客户端测试能否访问nfs服务
    mount -t nfs 10.10.10.3:/data/images/  /data/img   # 挂载nfs

    # 服务端的 portmap 或 rpcbind 被停止后，nfs仍然工作正常，但是umout财会提示： not found / mounted or server not reachable  重启服务器的portmap 或 rpcbind 也无济于事。 nfs也要跟着重启，否则nfs工作仍然是不正常的。会造成NFS客户端挂载不正常，df卡住和挂载目录无法访问。需要强制卸载后，重新挂载
    umount -f /data/img/             # 强制卸载挂载目录  如还不可以  umount -l /data/img/
