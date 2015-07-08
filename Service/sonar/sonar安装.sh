
# 下载
http://www.sonarqube.org/downloads/     

# java1.7+
# 先安装mysql5.6或 yum install mysql5.1
# 配置默认为innodb引擎, 

CREATE DATABASE sonar CHARACTER SET utf8 COLLATE utf8_general_ci;
GRANT all ON sonar.* TO sonar@localhost IDENTIFIED BY  "sonar";
GRANT all ON sonar.* TO sonar@'%' IDENTIFIED BY  "sonar";
flush privileges;


vim conf/sonar.properties
##################################################
sonar.jdbc.username=sonar
sonar.jdbc.password=sonar

sonar.jdbc.url=jdbc:mysql://localhost:3306/sonar?useUnicode=true&characterEncoding=utf8&rewriteBatchedStatements=true&useConfigs=maxPerformance

sonar.web.host=10.16.4.134
sonar.web.port=9000

##################################################


cd bin/linux-x86-64/
./sonar.sh start


# 插件地址
http://docs.sonarqube.org/display/PLUG/Plugin+Library   
# 中文插件地址 下载源码后需要编译为jar
https://github.com/SonarCommunity/sonar-l10n-zh
将插件jar包放到 extensions\plugins 下即可 重启生效










