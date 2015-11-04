FROM centos-6.6/base
MAINTAINER 汪志鹏 <634348691@qq.com>

RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key
RUN ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key

RUN sed -ri 's/session    required     pam_loginuid.so/#session    required     pam_loginuid.so/g' /etc/pam.d/sshd

RUN mkdir -p /root/.ssh \
 && chown root.root /root \
 && chmod 700 /root/.ssh

EXPOSE 22

COPY assets/.bash* /root/

RUN echo 'root:iwangzhipeng' | chpasswd

# 此处可以增加YumRepo, 我这边提交到GitHub上 暂时不确定地址.
# RUN curl https://www.iOpDev.com/Repo.sh | sh

RUN chkconfig --level 3 sshd on

ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

CMD /usr/sbin/sshd -D
