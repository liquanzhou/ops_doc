#!/bin/bash
#ShellName:LazyManage.sh
#Conf:serverlist.conf
#By:peter.li six
#2014-04-14
#LazyManage.sh version update address:
#http://pan.baidu.com/s/1sjsFrmX
#https://github.com/liquanzhou/ops_doc

LANG="en_US.UTF-8"

while true
do

Set_Variable(){

    ServerList=serverlist.conf
    Port=22
    TimeOut="-1"
    Task=30

    RemoteUser='root'
    RemotePasswd='123456'
    RemoteRootUser='root'
    RemoteRootPasswd='xuesong'
    KeyPasswd=''

    ScpPath="lazy.tmp"
    ScpRemotePath="/tmp/"
    ScriptRemote="ScriptRemote.sh"
    TarRemote=""
    CmdRemote="CmdRemote.sh"
}

System_Check(){

    if [ "$1" == kill ];then
        ps -eaf |awk '$NF~/.*'${0##*/}'/&&$6~/tty|pts.*/{print $2}' |xargs -t -i kill -9 {}
        exit
    fi

    if [ ! -s $ServerList ];then
        echo "error:IP list $ServerList file does not exist or is null"
        exit
    fi

    if [ ! -s $ScriptPath ];then
        touch $ScriptPath
    fi

    for i in dialog expect
    do
        rpm -q $i >/dev/null
        [ $? -ge 1 ] && echo "$i does not exist,Please root yum -y install $i to install,exit" && exit
    done

    #System parameters
    #LazyUser=`whoami`
    LazyPath=`pwd`
    #BitNum=`getconf LONG_BIT`
    #SystemNum=`awk '/release/{print $7}' /etc/issue`

}

Select_Type() {
while true
do
clear
    case $Operate in
    1)
        Type=`dialog --no-shadow --stdout --backtitle "LazyManage" --title "System work content"  --menu "select" 10 60 0 \
        1a "[Common operations]" \
        0 "[exit]"`
    ;;
    2)
        Type=`dialog --no-shadow --stdout --backtitle "LazyManage" --title "Custom work content"  --menu "select" 10 60 0 \
        1b "[web upgrade]" \
        2b "[db   manage]" \
        0 "[exit]"`
    ;;
    0)
        echo -e "\e[34mLazyManage exit\e[m"
        exit
    ;;
    esac
    [ $? -eq 0 ] && Select_Work $Type || break
done
}

Select_Work() {
while true
do
clear
    case $Type in
    1a)
        Work=`dialog --no-shadow  --stdout --backtitle "LazyManage" --title "Common operations" --menu "select" 20 60 0 \
        1aa "[custom cmd ]" \
        2aa "[scp file   ]" \
        3aa "[exec script]" \
        0 "[exit]"`
    ;;
    1b)
        Work=`dialog --no-shadow  --stdout --backtitle "LazyManage" --title "web upgrade" --menu "select" 20 60 0 \
        1ba "[job1]" \
        2ba "[job2]" \
        3ba "[job3]" \
        0 "[exit]"`
    ;;
    2b)
        Work=`dialog --no-shadow  --stdout --backtitle "LazyManage" --title "db   manage" --menu "select" 20 60 0 \
        1bb "[job1]" \
        2bb "[job2]" \
        3bb "[job3]" \
        0 "[exit]"`
    ;;
    0)
        echo -e "\e[34mLazyManage exit\e[m"
        exit
    ;;
    esac
    [ $? -eq 0 ] && Get_Ip $Work || break
done
}

Get_Ip(){
case $Work in
[1-9]a[a-z])
    List=`awk '$1!~"^#"&&$1!=""{print $1" "$1" on"}' $ServerList`
;;
1ba)
    List=`awk '$1!~"^#"&&$1!=""&&$2=="job1"&&$3=="web"{print $1" "$2"_"$3" on"}' $ServerList`
;;
2ba)
    List=`awk '$1!~"^#"&&$1!=""&&$2=="job2"&&$3=="web"{print $1" "$2"_"$3" on"}' $ServerList`
;;
3ba)
    List=`awk '$1!~"^#"&&$1!=""&&$2=="job3"&&$3=="web"{print $1" "$2"_"$3" on"}' $ServerList`
;;
1bb)
    List=`awk '$1!~"^#"&&$1!=""&&$2=="job1"&&$3=="db"{print $1" "$2"_"$3" on"}' $ServerList`
;;
2bb)
    List=`awk '$1!~"^#"&&$1!=""&&$2=="job2"&&$3=="db"{print $1" "$2"_"$3" on"}' $ServerList`
;;
3bb)
    List=`awk '$1!~"^#"&&$1!=""&&$2=="job3"&&$3=="db"{print $1" "$2"_"$3" on"}' $ServerList`
;;
0)
    echo -e "\e[34mLazyManage exit\e[m"
    exit
;;
*)
    echo "Dialog list does not exist"
    break
;;
esac

IpList=`dialog --no-shadow  --stdout --backtitle "LazyManage" --title "ip list" --separate-output --checklist "select IP" 0 60 0 $List |sort -u`
if [ "X$IpList" == "X" ];then
    break
fi

Message=`cat <<EOF

Please make sure the information
========================
$IpList
========================
EOF`

dialog --backtitle "LazyManage" --title "Confirm IP" --no-shadow --yesno "$Message" 20 60
[ $? -eq 0 ] && Perform || break
}

Perform(){
    case $Work in
    1aa)
        echo -e '\e[35mPlease enter the custom command[backspace=ctrl+backspace][Exit the command mode=exit]\e[m'
        while read Cmd
        do
            if [ "$Cmd" == "exit" ];then
                echo "Exit the command mode"
                break
            elif [ X"$Cmd" != X ];then
                echo "$Cmd" > "$CmdRemote"
                RemoteFile="$CmdRemote"
                ExecScript="$CmdRemote" 
                Record_Log $Work "$Cmd"
                Concurrent Interactive_Auth Ssh_Script 
                Stat_Log
                echo -e '\e[35mPlease enter the custom command\e[m'
            fi
        done
    ;;
    2aa)
        if [ ! -e ${ScpPath} ];then
            echo "${ScpPath} file or directory does not exist "
            read
            break
        fi
        Record_Log $Work "${ScpPath} - ${ScpRemotePath}"
        Concurrent Interactive_Auth Scp_File 
        Stat_Log
        read
    ;;
    3aa)
        RemoteFile="$ScriptRemote $TarRemote"
        ExecScript="$ScriptRemote" 
        Record_Log $Work "$ScriptRemote"
        Concurrent Interactive_Auth Ssh_Script
        Stat_Log
        read
    ;;
    [1-9]ba)
        echo "custom"
        #Record_Log $Work
        #Concurrent Interactive_Auth Ssh_Script
        #Stat_Log
        read
    ;;
    [1-9]bb)
        echo "custom"
        read
    ;;
    *)
        echo "Dialog list does not exist"
        break
    ;;
    esac
}

Concurrent(){
FifoFile="$$.fifo"
mkfifo $FifoFile
exec 6<>$FifoFile
rm $FifoFile
for ((i=0;i<=$Task;i++));do echo;done >&6

for Ip in $IpList
do
    read -u6
    ((Total++))
    {
        $1 $2 |awk 'BEGIN{RS="(expect_start|expect_eof|expect_failure)"}END{print $0}' |sed '/Connection to.*closed/d' |tee -a $LogPath
        echo >&6 
    } &
done
wait
exec 6>&-
}

Interactive_Auth(){
#RemoteRootPasswd=`awk '$1=="'$Ip'"{print $2}' $ServerList`

/usr/bin/expect -c "
proc jiaohu {} {
    send_user expect_start
    expect {
        password {
            send ${RemotePasswd}\r;
            send_user expect_eof
            expect {
                \"does not exist\" {
                    send_user expect_failure
                    exit 10
                }
                password {
                    send_user expect_failure
                    exit 5
                }
                Password {
                    send ${RemoteRootPasswd}\r;
                    send_user expect_eof
                    expect {
                        incorrect {
                            send_user expect_failure
                            exit 6
                        }
                        eof 
                    }
                }
                eof
            }
        }
        passphrase {
            send ${KeyPasswd}\r;
            send_user expect_eof
            expect {
                \"does not exist\" {
                    send_user expect_failure
                    exit 10
                }
                passphrase{
                    send_user expect_failure
                    exit 7
                }
                Password {
                    send ${RemoteRootPasswd}\r;
                    send_user expect_eof
                    expect {
                        incorrect {
                            send_user expect_failure
                            exit 6
                        }
                        eof
                    }
                }
                eof
            }
        }
        Password {
            send ${RemoteRootPasswd}\r;
            send_user expect_eof
            expect {
                incorrect {
                    send_user expect_failure
                    exit 6
                }
                eof
            }
        }
        \"No route to host\" {
            send_user expect_failure
            exit 4
        }
        \"Invalid argument\" {
            send_user expect_failure
            exit 8
        }
        \"Connection refused\" {
            send_user expect_failure
            exit 9
        }
        \"does not exist\" {
            send_user expect_failure
            exit 10
        }
        
        \"Connection timed out\" {
            send_user expect_failure
            exit 11
        }
        timeout {
            send_user expect_failure
            exit 3
        }
        eof
    }
}
set timeout $TimeOut
switch $1 {
    Ssh_Script {
        spawn scp -P $Port -o StrictHostKeyChecking=no $RemoteFile $RemoteUser@$Ip:/tmp/
        jiaohu
        spawn ssh -t -p $Port -o StrictHostKeyChecking=no $RemoteUser@$Ip /bin/su - $RemoteRootUser -c  \\\"/bin/sh /tmp/${ExecScript}\\\" ;
        jiaohu
    }
    Scp_File {
        spawn scp -P $Port -o StrictHostKeyChecking=no -r $ScpPath $RemoteUser@$Ip:${ScpRemotePath};
        jiaohu
    }
}
"
case $? in
0)    echo -e "\e[32m`date +%Y-%m-%d_%H:%M` $Ip Ssh_Done: ------------------------  [OK] \e[m"  ;;
1|2)  echo -e "\e[31m`date +%Y-%m-%d_%H:%M` $Ip Ssh_Error: expect grammar or unknown error \e[m"  ;;
3)    echo -e "\e[31m`date +%Y-%m-%d_%H:%M` $Ip Ssh_Error: connection timeout \e[m"  ;;
4)    echo -e "\e[31m`date +%Y-%m-%d_%H:%M` $Ip Ssh_Error: host not found \e[m"  ;;
5)    echo -e "\e[31m`date +%Y-%m-%d_%H:%M` $Ip Ssh_Error: user passwd error \e[m"  ;;
6)    echo -e "\e[31m`date +%Y-%m-%d_%H:%M` $Ip Ssh_Error: root passwd error \e[m"  ;;
7)    echo -e "\e[31m`date +%Y-%m-%d_%H:%M` $Ip Ssh_Error: key passwd error \e[m"  ;;
8)    echo -e "\e[31m`date +%Y-%m-%d_%H:%M` $Ip Ssh_Error: ssh parameter not correct \e[m"  ;;
9)    echo -e "\e[31m`date +%Y-%m-%d_%H:%M` $Ip Ssh_Error: ssh invalid port parameters \e[m"  ;;
10)   echo -e "\e[31m`date +%Y-%m-%d_%H:%M` $Ip Ssh_Error: root user does not exist \e[m"  ;;
11)   echo -e "\e[31m`date +%Y-%m-%d_%H:%M` $Ip Ssh_Error: ssh timeout  \e[m"  ;;
esac
}

Record_Log(){
    LogDir="$LazyPath/lazylog/`date +%Y%m%d`"
    LogPath="$LogDir/lazy_`date +%H_%M_%S`.log"
    mkdir -p $LogDir
    echo -e "`date +%Y-%m-%d_%H:%M` Perform $1 : $2" >> $LogPath
    echo -e "\e[33m`date +%Y-%m-%d_%H:%M` Perform  $1 : $2 \e[m"
    Total=0
}

Stat_Log(){
    Failure=`grep -wc 'Ssh_Error:' $LogPath`
    Successful=`expr $Total - $Failure`
    echo -e "`date +%Y-%m-%d_%H:%M` All operation complete: Total[ $Total ] Successful[ $Successful ] Failure[ $Failure ]" >> $LogPath
    if [ "$Failure" == "0" ];then
        echo -e "`date +%Y-%m-%d_%H:%M` All operation complete: \e[32mTotal[ $Total ] Successful[ $Successful ] Failure[ $Failure ]\e[m"
    else
        echo -e "`date +%Y-%m-%d_%H:%M` All operation complete: \e[31mTotal[ $Total ] Successful[ $Successful ] Failure[ $Failure ]\e[m"
    fi
    sed -i -r -e 's/\r//g' -e '/Ssh_Error:|Ssh_Done:/s/^.....|....$//g' $LogPath
}

trap "" 2 3
Set_Variable
System_Check $1

#Script entrance
Operate=`dialog --no-shadow --stdout --backtitle "LazyManage" --title "manipulation menu"  --menu "select" 10 60 0 \
1 "[system operate]" \
2 "[custom operate]" \
0 "[exit]"`
[ $? -eq 0 ] && Select_Type $Operate || exit

done
#End
