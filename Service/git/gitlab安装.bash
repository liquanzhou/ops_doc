
gitlab安装

  gitlab	46 151



  
https://github.com/gitlabhq/gitlabhq/blob/master/doc/install/installation.md
  
http://doc.gitlab.com/ce/

https://packages.gitlab.com/gitlab/gitlab-ce/install

https://github.com/gitlabhq/gitlabhq


https://github.com/gitlabhq/gitlabhq/blob/master/doc/install/requirements.md


http://www.open-open.com/lib/view/open1399684894447.html



Ubuntu/Debian/CentOS/RHEL
Ruby (MRI) 2.1
Git 1.7.10+
Redis 2.4+
MySQL or PostgreSQL


  
rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
  

  
  
yum -y install gcc gcc-c++ make autoconf libyaml-devel gdbm-devel ncurses-devel openssl-devel zlib-devel readline-devel curl-devel expat-devel gettext-devel  tk-devel libxml2-devel libffi-devel libxslt-devel libicu-devel sendmail patch libyaml* pcre-devel sqlite-devel  cmake nodejs curl openssh-server postfix cronie   mysql-server mysql-devel  redis
  

  
Python 2.7+


git安装

curl -L --progress https://www.kernel.org/pub/software/scm/git/git-2.4.3.tar.gz | tar xz
cd git-2.4.3/
./configure
make prefix=/usr/local all
make prefix=/usr/local install

useradd  git


ruby安装
wget https://cache.ruby-lang.org/pub/ruby/2.1/ruby-2.1.7.tar.gz
tar zxvpf ruby-2.1.7.tar.gz
cd ruby-2.1.7
./configure --prefix=/usr/local/  --disable-install-rdoc
 make && make install


gem sources --remove https://rubygems.org/
gem sources -a https://ruby.taobao.org/
gem sources -l
gem install bundler --no-ri --no-rdoc


go安装
wget https://storage.googleapis.com/golang/go1.5.1.linux-amd64.tar.gz
tar -C /usr/local -xzf go1.5.1.linux-amd64.tar.gz
ln -sf /usr/local/go/bin/{go,godoc,gofmt} /usr/local/bin/



mysql安装
chkconfig mysqld on
service mysqld start

use mysql;
update user set password=password('root123') where user='root';

# 为gitlab创建使用用户
CREATE USER 'gitlab'@'localhost' IDENTIFIED BY 'gitlib123';

# 创建gitlaba使用的数据库
CREATE DATABASE IF NOT EXISTS `gitlabhq_production` DEFAULT CHARACTER SET `utf8` COLLATE `utf8_unicode_ci`;

# 给予gitlab用户权限
GRANT SELECT, LOCK TABLES, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON `gitlabhq_production`.* TO 'gitlab'@'localhost';


redis安装
vim /etc/redis.conf

# 修改端口为0
port 0
# 增加参数
unixsocket /var/run/redis/redis.sock
unixsocketperm 770


mkdir /var/run/redis
chown redis:redis /var/run/redis
chmod 755 /var/run/redis


usermod -aG redis git

chkconfig redis on
service redis start
chown redis.git /var/run/redis/redis.sock


gitlab shell安装

su git
cd /home/git/
git clone https://github.com/gitlabhq/gitlab-shell.git
cd gitlab-shell
cp config.yml.example config.yml

vim /home/git/gitlab-shell/config.yml
更改访问地址gitlab_url


GitLab安装

mkdir /data/gitlab
chown git.git /data/gitlab
cd /data
sudo -u git -H git clone https://gitlab.com/gitlab-org/gitlab-ce.git -b 8-0-stable gitlab


cd /data/gitlab

cp config/gitlab.yml.example config/gitlab.yml
cp config/secrets.yml.example config/secrets.yml
cp config/unicorn.rb.example config/unicorn.rb
cp config/initializers/rack_attack.rb.example config/initializers/rack_attack.rb
cp config/resque.yml.example config/resque.yml
cp config/database.yml.mysql config/database.yml

chown -R git.git config
chmod 0600 config/secrets.yml
chown -R git log/
chown -R git tmp/
chmod -R u+rwX,go-w log/
chmod -R u+rwX tmp/
chmod -R u+rwX tmp/pids/
chmod -R u+rwX tmp/sockets/
chmod -R u+rwX  public/uploads
chmod -R u+rwX builds/
chmod o-rwx config/database.yml



editor config/gitlab.yml
editor config/unicorn.rb
# listen "0.0.0.0:8080", :tcp_nopush => true
editor config/resque.yml

# Configure Git global settings for git user, used when editing via web editor
sudo -u git -H git config --global core.autocrlf input



# production

vim Gemfile
# 更改源
source "https://ruby.taobao.org"

# bundle 命令需要git用户在项目目录下gitlib

sudo -u git -H /usr/local/bin/bundle install --deployment --without development test postgres aws kerberos

su - git
cd /data/gitlib
# 创建web登录账户，需要先配置 mysql
/usr/local/bin/bundle exec rake gitlab:setup RAILS_ENV=production


bundle exec rake gitlab:setup RAILS_ENV=production GITLAB_ROOT_PASSWORD=yourpassword




cd /data/gitlab
bundle exec rake gitlab:shell:install[v2.6.5] REDIS_URL=unix:/var/run/redis/redis.sock RAILS_ENV=production


# root
cp lib/support/init.d/gitlab /etc/init.d/gitlab
cp lib/support/init.d/gitlab.default.example /etc/default/gitlab
cp lib/support/logrotate/gitlab /etc/logrotate.d/gitlab

su git
bundle exec rake gitlab:env:info RAILS_ENV=production
bundle exec rake assets:precompile RAILS_ENV=production




yum install nginx
cp lib/support/nginx/gitlab /etc/nginx/conf.d/
# 修改为git用户启动
nginx -t
service nginx restart


/etc/init.d/gitlab restart


# 最后检查
/home/git/gitlab-shell/bin/check

tail -f /var/log/nginx/gitlab_access.log

bundle exec rake gitlab:check RAILS_ENV=production




http://192.168.1.151/users/sign_in

# 初始密码 如果密码不对   在执行创建账号   /usr/local/bin/bundle exec rake gitlab:setup RAILS_ENV=production
root
5iveL!fe







vim /data/gitlab/config/environments/production.rb 



gitlab web登入密码忘记以后可以用如下方式修改密码

bundle exec rails console production
irb(main):007:0> user = User.where(email: 'admin@local.host').first //email 为gitlabuser 账户，我的是默认的管理员账户
rb(main):006:0* user = User.where(username: 'root').first
rb(main):006:0* user = User.where(id: 1).first
irb(main):007:0>user.password = 'yourpassword'   //密码必须至少8个字符
irb(main):007:0>user.save!  // 如没有问题 返回true




# 邮件配置 

http://iceeggplant.blog.51cto.com/1446843/1611147

http://my.oschina.net/anylain/blog/220774

配置smtp主要要配置2个地方

vim config/environments/production.rb
config.action_mailer.delivery_method= :smtp


cp config/initializers/smtp_settings.rb.sample config/initializers/smtp_settings.rb
vim config/initializers/smtp_settings.rb

if Gitlab::Application.config.action_mailer.delivery_method == :smtp
  ActionMailer::Base.smtp_settings = {
    address: "smtp.domain.com",
    port: 587,
    user_name: "mail_username",
    password: "mail_password",
    domain: "domain.com",
    authentication: 'plain', 
    enable_starttls_auto: true 
  }end
Tip: 如果没用smtp没有开加密连接的话 enable_starttls_auto 的值应该配置为 false

这里需要注意一个问题, 如果你的smtp服务器做了权限限制,只能以登陆账户的邮件帐号发邮件的话,还需要修改一处地方

编辑 config/gitlab.yml 找到下面两个字段将内容改成你的邮件帐户地址:

email_from: yourmail@domain.com
support_email: yourmail@domain.com















