FROM CentOS-6.6/sshd

MAINTAINER 汪志鹏 <wangzhipeng@tigerjoys.com>

RUN /bin/touch /tmp/wzp

RUN /bin/rpm -ivh http://mirrors.sohu.com/fedora-epel/6/i386/epel-release-6-8.noarch.rpm  \
 && /usr/bin/yum install nginx -y

RUN useradd deploy \
 && echo 'deploy:deploy' | chpasswd \
 && mkdir -p /usr/local/nginx/logs/ \
 && mkdir -p /etc/nginx/files

COPY assets/nginx.conf /etc/nginx/

RUN echo 'deploy:iwangzhipeng' | chpasswd \
 && chown -R deploy.deploy /etc/nginx/ \
 && service sshd start

EXPOSE 22
EXPOSE 80
EXPOSE 88

VOLUME ["/etc/nginx/files"]

WORKDIR /usr/sbin/

ENTRYPOINT nginx && tail -f /usr/local/nginx/logs/*

# CMD ["nginx && tail -f /etc/nginx/*"]
