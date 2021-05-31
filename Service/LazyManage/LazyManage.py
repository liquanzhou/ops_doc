#!/usr/bin/python
#encoding:utf8
#LzayManage.py
#config file: serverlist.conf
#By:peter.li
#2014-01-07
#LazyManage.py version update address:
#http://pan.baidu.com/s/1sjsFrmX
#https://github.com/liquanzhou/ops_doc


import paramiko
import multiprocessing
import sys,os,time,socket,re

def Ssh_Cmd(host_ip,Cmd,user_name,user_pwd,port=22):
    s = paramiko.SSHClient()
    s.load_system_host_keys()
    s.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    s.connect(hostname=host_ip,port=port,username=user_name,password=user_pwd)
    stdin,stdout,stderr = s.exec_command(Cmd)
    Result = '%s%s' %(stdout.read(),stderr.read())
    q.put('successful')
    s.close()
    return Result.strip()

def Ssh_Su_Cmd(host_ip,Cmd,user_name,user_pwd,root_name,root_pwd,port=22):
    s = paramiko.SSHClient()
    s.load_system_host_keys()
    s.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    s.connect(hostname=host_ip,port=port,username=user_name,password=user_pwd)
    ssh = s.invoke_shell()
    time.sleep(0.1)
    ssh.send('su - %s\n' %(root_name))
    buff = ''
    while not buff.endswith('Password: '):
        resp = ssh.recv(9999)
        buff +=resp
    ssh.send('%s\n' %(root_pwd))
    buff = ''
    while True:
        resp = ssh.recv(9999)
        buff +=resp
        if ': incorrect password' in buff:
            su_correct='passwd_error'
            break
        elif buff.endswith('# '):
            su_correct='passwd_correct'
            break
    if su_correct == 'passwd_correct':
        ssh.send('%s\n' %(Cmd))
        buff = ''
        while True:
            resp = ssh.recv(9999)
            if resp.endswith('# '):
                buff +=re.sub('\[.*@.*\]# $','',resp)
                break
            buff +=resp
        Result = buff.lstrip('%s' %(Cmd))
        q.put('successful')
    elif su_correct == 'passwd_error':
        Result = "\033[31mroot密码错误\033[m"
    s.close()
    return Result.strip()

def Send_File(host_ip,PathList,user_name,user_pwd,Remote='/tmp',port=22):
    s=paramiko.Transport((host_ip,port))
    s.connect(username=user_name,password=user_pwd)
    sftp=paramiko.SFTPClient.from_transport(s) 
    for InputPath in PathList:
        LocalPath = re.sub('^\./','',InputPath.rstrip('/'))
        RemotePath = '%s/%s' %( Remote , os.path.basename( LocalPath ))
        try:
            sftp.rmdir(RemotePath)
        except:
            pass
        try:
            sftp.remove(RemotePath)
        except:
            pass
        if os.path.isdir(LocalPath):
            sftp.mkdir(RemotePath)
            for path,dirs,files in os.walk(LocalPath):
                for dir in dirs:
                    dir_path = os.path.join(path,dir)
                    sftp.mkdir('%s/%s' %(RemotePath,re.sub('^%s/' %LocalPath,'',dir_path)))
                for file in files:
                    file_path = os.path.join(path,file)
                    sftp.put( file_path,'%s/%s' %(RemotePath,re.sub('^%s/' %LocalPath,'',file_path)))
        else:
            sftp.put(LocalPath,RemotePath)
    q.put('successful')
    sftp.close()
    s.close()
    Result = '%s  \033[32m传送完成\033[m' % PathList
    return Result

def Ssh(host_ip,Operation,user_name,user_pwd,root_name,root_pwd,Cmd=None,PathList=None,port=22):
    msg = "\033[32m-----------Result:%s----------\033[m" % host_ip
    try:
        if Operation == 'Ssh_Cmd':
            Result = Ssh_Cmd(host_ip=host_ip,Cmd=Cmd,user_name=user_name,user_pwd=user_pwd,port=port)
        elif Operation == 'Ssh_Su_Cmd':
            Result = Ssh_Su_Cmd(host_ip=host_ip,Cmd=Cmd,user_name=user_name,user_pwd=user_pwd,root_name=root_name,root_pwd=root_pwd,port=port)
        elif Operation == 'Ssh_Script':
            Send_File(host_ip=host_ip,PathList=PathList,user_name=user_name,user_pwd=user_pwd,port=port)
            Script_Head = open(PathList[0]).readline().strip()
            LocalPath = re.sub('^\./','',PathList[0].rstrip('/'))
            Cmd = '%s /tmp/%s' %( re.sub('^#!','',Script_Head), os.path.basename( LocalPath ))
            Result = Ssh_Cmd(host_ip=host_ip,Cmd=Cmd,user_name=user_name,user_pwd=user_pwd,port=port)
        elif Operation == 'Ssh_Su_Script':
            Send_File(host_ip=host_ip,PathList=PathList,user_name=user_name,user_pwd=user_pwd,port=port)
            Script_Head = open(PathList[0]).readline().strip()
            LocalPath = re.sub('^\./','',PathList[0].rstrip('/'))
            Cmd = '%s /tmp/%s' %( re.sub('^#!','',Script_Head), os.path.basename( LocalPath ))
            Result = Ssh_Su_Cmd(host_ip=host_ip,Cmd=Cmd,user_name=user_name,user_pwd=user_pwd,root_name=root_name,root_pwd=root_pwd,port=port)
        elif Operation == 'Send_File':
            Result = Send_File(host_ip=host_ip,PathList=PathList,user_name=user_name,user_pwd=user_pwd,port=port)
        else:
            Result = '操作不存在'
        
    except socket.error:
        Result = '\033[31m主机或端口错误\033[m'
    except paramiko.AuthenticationException:
        Result = '\033[31m用户名或密码错误\033[m'
    except paramiko.BadHostKeyException:
        Result = '\033[31mBad host key\033[m['
    except IOError:
        Result = '\033[31m远程主机已存在非空目录或没有写权限\033[m'
    except:
        Result = '\033[31m未知错误\033[m'
    r.put('%s\n%s\n' %(msg,Result))

def Concurrent(Conf,Operation,user_name,user_pwd,root_name,root_pwd,Cmd=None,PathList=None,port=22):
    # 读取配置文件
    f=open(Conf)
    list = f.readlines()
    f.close()
    # 执行总计
    total = 0
    # 并发执行
    for host_info in list:
        # 判断配置文件中注释行跳过
        if host_info.startswith('#'):
            continue
        # 取变量,其中任意变量未取到就跳过执行
        try:
            host_ip=host_info.split()[0]
            #user_name=host_info.split()[1]
            #user_pwd=host_info.split()[2]
        except:
            print('Profile error: %s' %(host_info) )
            continue
        try:
            port=int(host_info.split()[3])
        except:
            port=22
        total +=1
        p = multiprocessing.Process(target=Ssh,args=(host_ip,Operation,user_name,user_pwd,root_name,root_pwd,Cmd,PathList,port))
        p.start()
    # 打印执行结果
    for j in range(total):
        print(r.get() )
    if Operation == 'Ssh_Script' or Operation == 'Ssh_Su_Script':
        successful = q.qsize() / 2
    else:
        successful = q.qsize()
    print('\033[32m执行完毕[总执行:%s 成功:%s 失败:%s]\033[m' %(total,successful,total - successful) )
    q.close()
    r.close()

def Help():
    print('''    1.执行命令
    2.执行脚本      \033[32m[位置1脚本(必须带脚本头),后可带执行脚本所需要的包\文件\文件夹路径,空格分隔]\033[m
    3.发送文件      \033[32m[传送的包\文件\文件夹路径,空格分隔]\033[m
    退出: 0\exit\quit
    帮助: help\h\?
    注意: 发送文件默认为/tmp下,如已存在同名文件会被强制覆盖,非空目录则中断操作.执行脚本先将本地脚本及包发送远程主机上,发送规则同发送文件
    ''')

if __name__=='__main__':
    # 定义root账号信息
    root_name = 'root'
    root_pwd = 'peterli'
    user_name='peterli'
    user_pwd='xuesong'
    # 配置文件
    Conf='serverlist.conf'
    if not os.path.isfile(Conf):
        print('\033[33m配置文件 %s 不存在\033[m' %(Conf) )
        sys.exit()
    Help()
    while True:
        i = raw_input("\033[35m[请选择操作]: \033[m").strip()
        q = multiprocessing.Queue()
        r = multiprocessing.Queue()
        if i == '1':
            if user_name == root_name:
                Operation = 'Ssh_Cmd'
            else:
                Operation = 'Ssh_Su_Cmd'
            Cmd = raw_input('CMD: ').strip()
            if len(Cmd) == 0:
                print('\033[33m命令为空\033[m')
                continue
            Concurrent(Conf=Conf,Operation=Operation,user_name=user_name,user_pwd=user_pwd,root_name=root_name,root_pwd=root_pwd,Cmd=Cmd)
        elif i == '2':
            if user_name == root_name:
                Operation = 'Ssh_Script'
            else:
                Operation = 'Ssh_Su_Script'
            PathList = raw_input('\033[36m本地脚本路径: \033[m').strip().split()
            if len(PathList) == 0:
                print('\033[33m路径为空\033[m')
                continue
            if not os.path.isfile(PathList[0]):
                print('\033[33m本地路径 %s 不存在或不是文件\033[m' %(PathList[0]) )
                continue
            for LocalPath in PathList[1:]:
                if not os.path.exists(LocalPath):
                    print('\033[33m本地路径 %s 不存在\033[m' %(LocalPath) )
                    break
            else:
                Concurrent(Conf=Conf,Operation=Operation,user_name=user_name,user_pwd=user_pwd,root_name=root_name,root_pwd=root_pwd,PathList=PathList)
        elif i == '3':
            Operation = 'Send_File'
            PathList = raw_input('\033[36m本地路径: \033[m').strip().split()
            if len(PathList) == 0:
                print('\033[33m路径为空\033[m')
                continue
            for LocalPath in PathList:
                if not os.path.exists(LocalPath):
                    print('\033[33m本地路径 %s 不存在\033[m' %(LocalPath) )
                    break
            else:
                Concurrent(Conf=Conf,Operation=Operation,user_name=user_name,user_pwd=user_pwd,root_name=root_name,root_pwd=root_pwd,PathList=PathList)
        elif i == '0' or i == 'exit' or i == 'quit':
            print("\033[34m退出LazyManage脚本\033[m")
            sys.exit()
        elif i == 'help' or i == 'h' or i == '?':
            Help()

#END
