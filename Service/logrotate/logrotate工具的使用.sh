    logrotate工具的使用

    logrotate是作为linux系统日志的管理工具存在。他可以轮换，压缩，邮件系统日志文件。
    默认的logrotate被加入cron的/etc/cron.daily中作为每日任务执行。
    /etc/logrotate.conf为其默认配置文件指定每个日志文件的默认规则。
    /etc/logrotate.d/* 为/etc/logrotate.conf默认包含目录其中文件也会被logrotate读取。指明每个日志文件的特定规则。
     
    /var/lib/logrotate/statue中默认记录logrotate上次轮换日志文件的时间。
     
    在debian下，在/etc/cron.daily/中会存在一个sysklogd任务。这个每日执行任务由cron启动，
    任务会轮换系统默认日志文件。默认日志文件会由syslogd-listfiles命令给出。同时会killall -HUP syslogd重启syslog服务。
     
    在redhat下，会在/etc/logrotate.d/下会存在一个syslog任务，这个任务由logrotate启动，
    也会轮换系统默认日志文件。同时重启syslog服务。
    对于linux 的系统安全来说，日志文件是极其重要的工具。
    系统管理员可以使用logrotate 程序用来管理系统中的最新的事件。logrotate 还可以用来备……对于linux 的系统安全来说，日志文件是极其重要的工具。
    系统管理员可以使用logrotate 程序用来管理系统中的最新的事件。logrotate 还可以用来备份日志文件，本篇将通过以下几部分来介绍
     
    日志文件的管理：
    1、logrotate 配置
    2、缺省配置logrotate
    3、使用include 选项读取其他配置文件
    4、使用include 选项覆盖缺省配置
    5、为指定的文件配置转储参数
     
    一、logrotate 配置
     
    logrotate 程序是一个日志文件管理工具。用来把旧的日志文件删除，并创建新的日志文件，我们把它叫做“转储”。我们可以根据日志文件的大小，也可以根据其天数来转储，这个过程一般通过cron 程序来执行。
    logrotate 程序还可以用于压缩日志文件，以及发送日志到指定的E-mail 。
     
    logrotate 的配置文件是/etc/logrotate.conf。主要参数如下表：
     
    参数 功能
    compress 通过gzip 压缩转储以后的日志
    nocompress 不需要压缩时，用这个参数
    copytruncate 用于还在打开中的日志文件，把当前日志备份并截断
    nocopytruncate 备份日志文件但是不截断
    create mode owner group 转储文件，使用指定的文件模式创建新的日志文件
    nocreate 不建立新的日志文件
    delaycompress 和compress 一起使用时，转储的日志文件到下一次转储时才压缩
    nodelaycompress 覆盖delaycompress 选项，转储同时压缩。
    errors address 专储时的错误信息发送到指定的Email 地址
    ifempty 即使是空文件也转储，这个是logrotate 的缺省选项。
    notifempty 如果是空文件的话，不转储
    mail address 把转储的日志文件发送到指定的E-mail 地址
    nomail 转储时不发送日志文件
    olddir directory 转储后的日志文件放入指定的目录，必须和当前日志文件在同一个文件系统
    noolddir 转储后的日志文件和当前日志文件放在同一个目录下
    prerotate/endscript 在转储以前需要执行的命令可以放入这个对，这两个关键字必须单独成行
    postrotate/endscript 在转储以后需要执行的命令可以放入这个对，这两个关键字必须单独成行
    daily 指定转储周期为每天
    weekly 指定转储周期为每周
    monthly 指定转储周期为每月
    rotate count 指定日志文件删除之前转储的次数，0 指没有备份，5 指保留5 个备份
    tabootext [+] list 让logrotate 不转储指定扩展名的文件，缺省的扩展名是：.rpm-orig, .rpmsave, v, 和~
    size size 当日志文件到达指定的大小时才转储，Size 可以指定bytes (缺省)以及KB (sizek)或者MB (sizem).
     
    二、缺省配置logrotate
     
    logrotate 缺省的配置募?/etc/logrotate.conf。
    Red Hat linux 缺省安装的文件内容是：
     
    # see “man logrotate” for details
    # rotate log files weekly
    weekly
     
    # keep 4 weeks worth of backlogs
    rotate 4
     
    # send errors to root
    errors root
    # create new (empty) log files after rotating old ones
    create
     
    # uncomment this if you want your log files compressed
    #compress
    1
    # RPM packages drop log rotation information into this directory
    include /etc/logrotate.d
     
    # no packages own lastlog or wtmp –we”ll rotate them here
    /var/log/wtmp {
    monthly
    create 0664 root utmp
    rotate 1
    }
     
    /var/log/lastlog {
    monthly
    rotate 1
    }
     
    # system-specific logs may be configured here
     
    缺省的配置一般放在logrotate.conf 文件的最开始处，影响整个系统。在本例中就是前面12行。
     
    第三行weekly 指定所有的日志文件每周转储一次。
    第五行rotate 4 指定转储文件的保留4份。
    第七行errors root 指定错误信息发送给root。
    第九行create 指定logrotate 自动建立新的日志文件，新的日志文件具有和
    原来的文件一样的权限。
    第11行#compress 指定不压缩转储文件，如果需要压缩，去掉注释就可以了。
     
    三、使用include 选项读取其他配置文件
    include 选项允许系统管理员把分散到几个文件的转储信息，集中到一个
    主要的配置文件。当logrotate 从logrotate.conf 读到include 选项时，会从指定文件读入配置信息，就好像他们已经在/etc/logrotate.conf 中一样。
     
    第13行include /etc/logrotate.d 告诉logrotate 读入存放在/etc/logrotate.d 目录中的日志转储参数，当系统中安装了RPM 软件包时，使用include 选项十分有用。RPM 软件包的日志转储参数一般存放在/etc/logrotate.d 目录。
     
    include 选项十分重要，一些应用把日志转储参数存放在/etc/logrotate.d 。
     
    典型的应用有：apache, linuxconf, samba, cron 以及syslog。
     
    这样，系统管理员只要管理一个/etc/logrotate.conf 文件就可以了。
     
    四、使用include 选项覆盖缺省配置
     
    当/etc/logrotate.conf 读入文件时，include 指定的文件中的转储参数将覆盖缺省的参数，如下例：
     
    # linuxconf 的参数
    /var/log/htmlaccess.log
    { errors jim
    notifempty
    nocompress
    weekly
    prerotate
    /usr/bin/chattr -a /var/log/htmlaccess.log
    endscript
    postrotate
    /usr/bin/chattr +a /var/log/htmlaccess.log
    endscript
    }
    /var/log/netconf.log
    { nocompress
    monthly
    }
     
    在这个例子中，当/etc/logrotate.d/linuxconf 文件被读入时，下面的参数将覆盖/etc/logrotate.conf中缺省的参数。
     
    Notifempty
    errors jim
     
    五、为指定的文件配置转储参数
    经常需要为指定文件配置参数，一个常见的例子就是每月转储/var/log/wtmp。为特定文件而使用的参数格式是：
     
    # 注释
    /full/path/to/file
    {
    option(s)
    }
     
    下面的例子就是每月转储/var/log/wtmp 一次：
    #Use logrotate to rotate wtmp
    /var/log/wtmp
    {
    monthly
    rotate 1
    }
     
    六、其他需要注意的问题
     
    1、尽管花括号的开头可以和其他文本放在同一行上，但是结尾的花括号必须单独成行。
     
    2、使用prerotate 和postrotate 选项
    下面的例子是典型的脚本/etc/logrotate.d/syslog，这个脚本只是对
    /var/log/messages 有效。
     
    /var/log/messages
    {
    prerotate
    /usr/bin/chattr -a /var/log/messages
    endscript
    postrotate
    /usr/bin/kill -HUP syslogd
    /usr/bin/chattr +a /var/log/messages
    endscript
    }
     
    第一行指定脚本对/var/log messages 有效
    花ê哦阅诓康慕疟驹诵杏? /var/log/messages
    prerotate 命令指定转储以前的动作/usr/bin/chattr -a 去掉/var/log/messages文件的“只追加”属性endscript 结束prerotate 部分的脚本postrotate 指定转储后的动作
     
    /usr/bin/killall -HUP syslogd
     
    用来重新初始化系统日志守护程序syslogd
     
    /usr/bin/chattr +a /var/log/messages
     
    重新为/var/log/messages 文件指定“只追加”属性，这样防治程序员或用户覆盖此文件。
     
    最后的endscript 用于结束postrotate 部分的脚本
     
    3、logrotate 的运行分为三步：
     
    判断系统的日志文件，建立转储计划以及参数，通过cron daemon 运行下面的代码是Red Hat linux 缺省的crontab 来每天运行logrotate。
     
    #/etc/cron.daily/logrotate
    #! /bin/sh
     
    /usr/sbin/logrotate /etc/logrotate.conf
     
    4、/var/log/messages 不能产生的原因：
    这种情况很少见，但是如果你把/etc/services 中的514/UDP 端口关掉的话，这个文件就不能产生了。
     
    否则如果不重启syslogd服务，日志默认不会记录到新生成的日志文件中，依然记录在原文件中。
     
    所以轮换日志文件之后，重启syslogd服务是很重要的。
     
    logrotate 也可以直接执行 后直接跟配置文件就可以了。
    -v 给出详细信息
    -d debug模式，不更改日志文件内容 模拟执行
    -f 强制执行，忽略所有规则 