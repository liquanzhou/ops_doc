Linux 安装 Maven

 
Maven， 是基于项目对象模型（Project Object Model， POM），通过一小段描述信息来管理项目的构建，报告，文档的软件项目管理工具。

目前，绝大多数开发人员都把 Ant 当作 Java 编程项目的标准构建工具。但是，Ant 的项目管理工具（作为 make的替代工具）不能满足绝大多数开发人员的需要。通过检查 Ant 构建文件，很难发现项目的相关性信息和其它元信息（如开发人员/拥有者、版本或站点主页）。

Maven 除了以程序构建能力为特色之外，还提供 Ant 所缺少的高级项目管理工具。由于 Maven 的缺省构建规则有较高的可重用性，所以常常用两三行 Maven 构建脚本就可以构建简单的项目，而使用 Ant 则需要十几行。事实上，由于 Maven 的面向项目的方法，许多 Apache Jakarta 项目现在使用 Maven，而且公司项目采用 Maven 的比例在持续增长。

Maven这个单词来自于意第绪语，意为知识的积累，最早在Jakata Turbine项目中它开始被用来试图简化构建过程。当时有很多项目，它们的Ant build文件仅有细微的差别，而JAR文件都由CVS来维护。于是Maven创始者开始了Maven这个项目，该项目的清晰定义包括，一种很方便的发布项目信息的方式，以及一种在多个项目中共享JAR的方式。


Maven 和 Ant 有什么不同呢？

Ant 为 Java 技术开发项目提供跨平台构建任务

Maven 本身描述项目的高级方面，它从 Ant 借用了绝大多数构建任务

​

Maven

Ant

标准构建文件

project.xml 和 maven.xml

build.xml

特性处理顺序

${maven.home}/bin/driver.properties

${project.home}/project.properties

${project.home}/build.properties

${user.home}/build.properties

通过 -D 命令行选项定义的系统特性，最后一个定义起决定作用。

通过 -D 命令行选项定义的系统特性

由 <property> 任务装入的特性

第一个定义最先被处理。

构建规则

构建规则更为动态（类似于编程语言）；它们是基于 Jelly 的可执行 XML。

构建规则或多或少是静态的，除非使用 <script> 任务。

扩展语言

插件是用 Jelly（XML）编写的。

插件是用 Java 语言编写的。

构建规则可扩展性

通过定义 <preGoal> 和 <postGoal> 使构建 goal 可扩展。

构建规则不易扩展；可通过使用 <script> 任务模拟 <preGoal> 和 <postGoal> 所起的作用。

由上比较可知，Maven 和 Ant 代表两个差异很大的工具

1， 下载

官方下载地址： maven_download， 最新版 apache-maven-3.0.5-bin.tar.gz

官方地址： maven

2， 解压

tar zxvf apache-maven-3.0.5-bin.tar.gz （例如安装目录为： /home/homer/Apache-maven/apache-maven-3.0.5）

3， 安装

1） 编辑 /etc/profile

sudo vi /etc/profile

2） 配置

配置maven安装目录：

export MAVEN_HOME=/home/homer/Apache-maven/apache-maven-3.0.5 // 安装目录

export PATH=${MAVEN_HOME}/bin:${PATH}


3） 生效

source /etc/profile // 使上面配置生效

4， 验证

命令行输入： mvn -v

显示maven版本信息，表示安装成功！