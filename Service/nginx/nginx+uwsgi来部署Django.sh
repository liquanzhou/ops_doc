 nginx+uwsgi来部署Django

1. 软件下载地址:

uwsgi 
wget http://projects.unbit.it/downloads/uwsgi-latest.tar.gz

flup 
wget http://www.saddi.com/software/flup/dist/flup-1.0.2.tar.gz

django
wget http://media.djangoproject.com/releases/1.2/Django-1.2.5.tar.gz

2. 安装

flup和django   都是用 python setup.py install

uwsgi安装 
cd  uwsgi-0.9.6.8
python uwsgiconfig.py --build
cd nginx
cp uwsgi_params /usr/local/nginx/conf/

 3. 建立项目目录
cd /root
django-admin.py startproject  my_django

vi uwsgi.xml
<uwsgi> 
  <socket>0.0.0.0:8000</socket> 
  <listen>20</listen> 
  <master>true</master> 
  <pidfile>/usr/local/nginx/uwsgi.pid</pidfile> 
  <processes>2</processes> 
  <module>django_wsgi</module>  #这个文件下面要建立
  <pythonpath>/root/my_django</pythonpath>   #刚才建立项目的路径
  <profiler>true</profiler> 
  <memory-report>true</memory-report> 
  <enable-threads>true</enable-threads> 
  <logdate>true</logdate> 
  <limit-as>6048</limit-as> 
</uwsgi>

vi django_wsgi
import os
import django.core.handlers.wsgi
os.environ['DJANGO_SETTINGS_MODULE'] = 'my_django.settings'    #这里的my_django.settings 表示 "项目名.settings"
application = django.core.handlers.wsgi.WSGIHandler()

4. 添加nginx配置
server { 
        listen  80; 
         server_name 192.168.0.100; 
   
          location / { 
            root /root/my_django;
            uwsgi_pass   127.0.0.1:8000; 
            include     uwsgi_params; 
            access_log  off;  }
 
} 

5. 启动uwsgi和nginx
/usr/local/nginx/sbin/nginx
uwsgi -x /root/my_django/uwsgi.xml &

好了,打开浏览器测试下吧