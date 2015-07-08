
一个Tomcat支持不同的域名访问各自不同程序的配置方法  

2011-11-15 01:49:21|  分类： jsp |字号 订阅
条件是：这样一种实际情况是，就一台服务器，当公网的IP地址也只有一个。

应用是：不同的域名访问后访问相对应的不同的程序。

举个例子来说如下：

有一个域名叫www.yuming.com

另一个一名叫bbs.yuming.com

曾经想过部署多个tomcat，然后用不同的端口来对应不用的域名。这样是很不好的，不可能指望用户去记住输入端口号（不是默认的80）。

例如：www.yuming.com,              bbs.yuming.com:8080/

还有就是在一个tomcat下面部署多个应用，然后通过域名+应用名的方式访问，也不好，不够简洁。

例如：www.yuming.com/    （只能隐藏一个工程名）          bbs.yuming.com/bbs或www.yuming.com/bbs

以上两种方式虽然都做到了形似不同的域名访问了不同应用，但实际效果还是很不好的，我就想输入www.yuming.com或bbs.yuming.com就能访问了。还有就是想过用跳转的方式等等实现都不是很好。

刚刚试了一下原来是有其他方法的，以前没注意过，愚昧了。呵呵。

方法是基本只需修改server.xml即可，步骤如下：

在tomcat的conf/server.xml里面找到如下信息

<Host name="localhost" appBase="webapps"
       unpackWARs="true" autoDeploy="true"
       xmlValidation="false" xmlNamespaceAware="false">

 

将上面的代码复制，加到此代码前面，并加上标签结束符号，如下：

<Host name="localhost" appBase="webapps"
       unpackWARs="true" autoDeploy="true"
       xmlValidation="false" xmlNamespaceAware="false">

</Host>

<Host name="localhost" appBase="webapps"
       unpackWARs="true" autoDeploy="true"
       xmlValidation="false" xmlNamespaceAware="false">

修改上面Host标签name属性值，将localhost改为bbs.yuming.com；修改下面Host标签name属性值，将localhost改为www.yuming.com，修改后如下：

<Host name="bbs.yuming.com" appBase="webapps"
       unpackWARs="true" autoDeploy="true"
       xmlValidation="false" xmlNamespaceAware="false">

</Host>

<Host name="www.yuming.com" appBase="webapps"
       unpackWARs="true" autoDeploy="true"
       xmlValidation="false" xmlNamespaceAware="false">

在tomcat目录下新建一个叫webapps2的文件夹，将bbs.yuming.com对应的那个Host标签appBase属性值为webapps2，修改后如下：

<Host name="bbs.yuming.com" appBase="webapps2"
       unpackWARs="true" autoDeploy="true"
       xmlValidation="false" xmlNamespaceAware="false">

</Host>

<Host name="www.yuming.com" appBase="webapps"
       unpackWARs="true" autoDeploy="true"
       xmlValidation="false" xmlNamespaceAware="false">

如此，我们已经做到了不同的域名只能访问自己对应的那个项目目录了。当然这样还没有完，在webapps或webapps2下面是能发布项目了，但现在还是需要输入域名+项目名。下面再做一下处理，将工程名为test的项目拷贝到webapps下，将testbbs项目拷贝到webapps2下，在Host标签内各增加一个Context上下文标签，修改后如下：

<Host name="bbs.yuming.com" appBase="webapps2"
       unpackWARs="true" autoDeploy="true"
       xmlValidation="false" xmlNamespaceAware="false">
<Context path="" docBase="test" reloadable="true">
</Context>
</Host>      
<Host name="www.yuming.com" appBase="webapps"
       unpackWARs="true" autoDeploy="true"
       xmlValidation="false" xmlNamespaceAware="false">
<Context path="" docBase="testbbs" reloadable="true">
</Context>

这样做启动tomcat会发现，每个项目被发布了两遍。一遍是带工程名的，一遍是不带工程名的。要只发布一次的话，就将项目放在webapps和webapps2文件夹外的任意目录。通过配置指向发布，如下：

例如放在D:\project\test和D:\project\testbbs，最终修改配置后如下：

<Host name="bbs.yuming.com" appBase="webapps2"
       unpackWARs="true" autoDeploy="true"
       xmlValidation="false" xmlNamespaceAware="false">
<Context path="" docBase="D:\\project\\test" reloadable="true">
</Context>
</Host>      
<Host name="www.yuming.com" appBase="webapps"
       unpackWARs="true" autoDeploy="true"
       xmlValidation="false" xmlNamespaceAware="false">
<Context path="" docBase="D:\\project\\testbbs" reloadable="true">
</Context>

重新启动tomcat即可。如果想测试看看效果的话，可以在配置本地的hosts例如：

打开C:\WINDOWS\system32\drivers\etc\hosts  ，编辑如下：

127.0.0.1       localhost
192.168.1.11 bbs.yuming.com
192.168.1.11 www.yuming.com

好了，在浏览器里面输入www.yuming.com或bbs.yuming.com就能访问各自的工程了。

That's all!