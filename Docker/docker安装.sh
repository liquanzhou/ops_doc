docker

yum -y install docker-io   # 安装docker
service docker start       # 启动docker服务
chkconfig	docker	on

https://registry.hub.docker.com                            # docker官方镜像地址
docker search centos                                       # 查找源中镜像
docker pull centos:6                                       # 从官方下载centos的docker镜像

docker images                                              # 查看docker镜像
docker ps                                                  # 查看docker启动的容器
docker ps -a                                               # 查看docker所有容器 包括未启动的


docker run -d -t -i centos:6 /bin/bash                     # 启动docker隔离的容器 -t 让Docker分配一个伪终端,并绑定到容器的标准输入上. -i 则让容器的标准输入保持打开. -d 守护进程
docker attach ID                                           # 进入后台的容器 指定容器ID   # util-linux 也可以进入容器
docker logs ID                                             # 获取容器内输出信息

docker stop ID                                             # 停止已启动的容器
docker start ID                                            # 启动已停止的容器
docker restart ID                                          # 重启容器

docker export 7691a814370e > centos_a.tar                  # 导出容器快照到本地
cat centos_a.tar | docker import - test/centos_a:v1.0      # 从容器快照文件中再导入为镜像

docker save -o centos.6.tar centos:6                       # 保存镜像到文件
docker load --input centos.6.tar                           # 载入镜像文件

docker rm 容器ID                                           # 删除终止状态的容器   加-f强制终止运行中的容器
docker rmi test/centos_a:v1.0                              # 移除本地镜像   在删除镜像之前要先用 docker rm 删掉依赖于这个镜像的所有容器


brctl show                                                 # 查看网桥

docker pull library/nginx

docker run --name some-nginx -v /some/content:/usr/share/nginx/html:ro -d nginx

mkdir testa                            # 创建静态资源目录
vim testa/a.txt
aaaaaa

vim Dockerfile                         # 创建 Dockerfile 文件
FROM nginx
COPY testa /usr/share/nginx/html       # 拷贝前面创建的静态资源目录

# Dockerfile用来创建一个自定义的image,包含了用户指定的软件依赖等。当前目录下包含Dockerfile,使用命令build来创建新的image,并命名为 some-content-nginx
docker build -t some-content-nginx .

docker run --name some-nginx -d some-content-nginx

docker run --name some-nginx-test1 -d -p 8080:80 some-content-nginx             # 暴漏端口的方式

docker run -d --name db training/postgres
docker run -d -P --name web --link db:db training/webapp python app.py          # 新建立容器,并连接db容器   --link name:alias	

curl http://localhost:8080/a.txt



