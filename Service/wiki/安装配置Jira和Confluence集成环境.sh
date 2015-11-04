安装配置Jira和Confluence集成环境


操作系统：

CentOS 6.5 x86_64 

下载软件包： 

下载如下的tar包: atlassian-confluence-5.5.3.tar.gz atlassian-crowd-2.7.2.tar.gz atlassian-jira-6.3.1.tar.gz 

说明：以下步骤均在jira用户下进行操作，并且上面所有tar包全部保存在jira用户的家目录下。需要创建jira用户：useradd jira

CentOS 5.3 安装配置JIRA与Confluence手记  http://www.linuxidc.com/Linux/2011-03/33594.htm

一、安装Confluence： 

安装配置JDK1.7，步骤略； 
解压缩Confluence：
cd
tar -xvf atlassian-confluence-5.5.3.tar.gz 
配置Confluence的Home目录：
cd /usr/local/
ln -s ~/atlassian-confluence-5.5.3 confluence
vim ~/atlassian-confluence-5.5.3/confluence/WEB-INF/classes/confluence-init.properties，修改下面的一行：confluence.home=/usr/local/confluence 
配置MySQL数据库连接：
安装MySQL数据库，创建confluence数据库，字符集选择为utf-8。注意：必须在此处设置编码格式为utf-8，否则会出现中文乱码。；
下载MySQL的Java驱动：mysql-connector-java-5.1.31.jar，拷贝到atlassian-confluence-5.5.3/confluence/WEB-INF/lib/下面； 
启动Confluence：
执行：~/atlassian-confluence-5.5.3/bin/start-confluence.sh 
访问http://YOUR_HOST:8090，进行安装配置，中间需要选择连接MySQL数据库，jdbc:mysql://localhost/confluence?useUnicode=true&amp;characterEncoding=utf8。注意：必须在此处设置编码格式为utf8，否则会出现中文乱码。 
二、安装Jira： 

安装配置JDK1.7，步骤略； 
解压缩Jira：
cd
tar -xvf atlassian-jira-6.3.1.tar.gz 
配置Confluence的Home目录：
cd /usr/local/
ln -s ~/atlassian-jira-6.3.1-standalone jira
vim ~/atlassian-jira-6.3.1-standalone/atlassian-jira/WEB-INF/classes/jira-application.properties，修改下面的一行：jira.home = /usr/local/jira/ 
配置MySQL数据库连接：
安装MySQL数据库，创建jira数据库，字符集选择为utf-8。注意：必须在此处设置编码格式为utf-8，否则会出现中文乱码。；
下载MySQL的Java驱动：mysql-connector-java-5.1.31.jar，拷贝到atlassian-jira-6.3.1-standalone/atlassian-jira/WEB-INF/lib/下面； 
启动Jira：
执行：~/atlassian-jira-6.3.1-standalone/bin/start-jira.sh 
访问http://YOUR_HOST:8080，进行安装配置，中间需要选择连接MySQL数据库，jdbc:mysql://localhost/jira?useUnicode=true&amp;characterEncoding=utf8。注意：必须在此处设置编码格式为utf8，否则会出现中文乱码。 
参考文档： 

https://confluence.atlassian.com/display/DOC/Confluence+Installation+and+Upgrade+Guide 

三、安装Crowd 

安装配置JDK1.7，步骤略； 
解压缩Jira：
cd
tar -xvf tlassian-crowd-2.7.2.tar.gz 
配置Confluence的Home目录：
cd /usr/local/
ln -s ~/atlassian-crowd-2.7.2 crowd
vim ~/./atlassian-crowd-2.7.2/crowd-webapp/WEB-INF/classes/crowd-init.properties，修改下面的一行：crowd.home=/usr/local/crowd
 配置MySQL数据库连接：
安装MySQL数据库，创建crowd数据库，字符集选择为utf-8。注意：必须在此处设置编码格式为utf-8，否则会出现中文乱码。；
下载MySQL的Java驱动：mysql-connector-java-5.1.31.jar，拷贝到./atlassian-crowd-2.7.2/crowd-webapp/WEB-INF/lib/下面；
启动Crowd：
执行：~/atlassian-crowd-2.7.2/start_crowd.sh 

访问http://YOUR_HOST:8095，进行安装配置，中间需要选择连接MySQL数据库，jdbc:mysql://localhost/crowd?useUnicode=true&amp;characterEncoding=utf8。注意：必须在此处设置编码格式为 utf8，否则会出现中文乱码。 


