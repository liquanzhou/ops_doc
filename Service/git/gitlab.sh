gitlab 基于Git的项目管理软件


GitLab 安装笔记


基本上参考官方文档就可以十分简单的安装上去, 其中几个注意点自己做下记录
安装要求

    Ubuntu/Debian**
    MySQL or PostgreSQL
    git
    gitlab-shell
    redis

Note: 推荐使用内部域名, 这样就可以直接用域名访问, 实现方法可以修改所有使用机的hosts 或 者自建DNS服务器(推荐)
安装教程
0.9. 在天朝的同学先将apt源更新成中科大或者网易的源! [重要]
1. 首先需要确定账户可以使用sudo, 并更新系统package

    apt-get update
    apt-get upgrade

正常情况系统都带sudo命令 如果没有的话 手动安装下 apt-get install sudo
2. 安装一些必要包

    sudo apt-get install -y build-essential zlib1g-dev libyaml-dev libssl-dev libgdbm-dev libreadline-dev libncurses5-dev libffi-dev curl git-core openssh-server redis-server checkinstall libxml2-dev libxslt-dev libcurl4-openssl-dev libicu-dev vim

确定本机python版本是否为2.7 python --version
如果版本不为2.7, 请安装2.7版本

    sudo apt-get install python2.7
    python2 --version
    sudo ln -s /usr/bin/python /usr/bin/python2

安装邮件发送支持 默认即可

    sudo apt-get install -y postfix

3. 安装Ruby 这里我们使用taobao的镜像进行安装 可以大大的缩短下载包的时间

    mkdir /tmp/ruby && cd /tmp/ruby
    curl --progress http://ruby.taobao.org/mirrors/ruby/1.9/ruby-1.9.3-p429.tar.gz | tar xz
    cd ruby-1.9.3-p429
    ./configure
    make
    sudo make install

Note: 请不要使用rvm来安装ruby 可能会因为环境变量导致这样那样的错误, 当然 如果你能解决这些问题可以使用rvm来安装ruby

安装bundler 这里我们也使用taobao镜像来缩短下载时间, 注意请使用sudo!!

    sudo gem sources --remove http://rubygems.org/
    sudo gem sources -a http://ruby.taobao.org/
    sudo gem install bundler

4. 添加Git用户

    sudo adduser --disabled-login --gecos 'GitLab' git

5. 安装 GitLab-shell 新版本使用GitLab-shell来代替gitolite

    # Login as git
    sudo su git

    # Go to home directory
    cd /home/git

    # Clone gitlab shell
    git clone https://github.com/gitlabhq/gitlab-shell.git

    cd gitlab-shell

    # switch to right version
    git checkout v1.4.0

    cp config.yml.example config.yml

    # Edit config and replace gitlab_url
    # with something like 'http://domain.com/'
    # 这里修改成自己的内部域名 如: http://gitlab.uloli/
    vim config.yml

    # Do setup
    ./bin/install

6. 安装数据库 推荐MySQL

以下所有操作需要使用可以sudo的账户

    # Install the database packages
    sudo apt-get install -y mysql-server mysql-client libmysqlclient-dev

    # Login to MySQL
    mysql -u root -p

    # Create a user for GitLab. (change $password to a real password)
    mysql> CREATE USER 'gitlab'@'localhost' IDENTIFIED BY 'gitlab';

    # Create the GitLab production database
    mysql> CREATE DATABASE IF NOT EXISTS `gitlabhq_production` DEFAULT CHARACTER SET `utf8` COLLATE `utf8_unicode_ci`;

    # Grant the GitLab user necessary permissions on the table.
    mysql> GRANT SELECT, LOCK TABLES, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON `gitlabhq_production`.* TO 'gitlab'@'localhost';

7. 开始安装GitLab主程序

    cd /home/git

    # Clone GitLab repository
    sudo -u git -H git clone https://github.com/gitlabhq/gitlabhq.git gitlab

    # Go to gitlab dir
    cd /home/git/gitlab

    # Checkout to stable release
    sudo -u git -H git checkout 5-2-stable

8. 配置GitLab

    # Copy the example GitLab config
    sudo -u git -H cp config/gitlab.yml.example config/gitlab.yml

    # Make sure to change "localhost" to the fully-qualified domain name of your
    # host serving GitLab where necessary
    # 这里仅需要修改host即可, 默认可行
    sudo -u git -H vim config/gitlab.yml

    # Make sure GitLab can write to the log/ and tmp/ directories
    # 修改账户权限
    sudo chown -R git log/
    sudo chown -R git tmp/
    sudo chmod -R u+rwX  log/
    sudo chmod -R u+rwX  tmp/

    # Create directory for satellites
    sudo -u git -H mkdir /home/git/gitlab-satellites

    # Create directories for sockets/pids and make sure GitLab can write to them
    sudo -u git -H mkdir tmp/pids/
    sudo -u git -H mkdir tmp/sockets/
    sudo chmod -R u+rwX  tmp/pids/
    sudo chmod -R u+rwX  tmp/sockets/

    # Create public/uploads directory otherwise backup will fail
    sudo -u git -H mkdir public/uploads
    sudo chmod -R u+rwX  public/uploads

    # Copy the example Puma config
    sudo -u git -H cp config/puma.rb.example config/puma.rb

    # Copy the example Puma config
    # 该配置文件默认即可
    sudo -u git -H vim config/puma.rb

    # Configure Git global settings for git user, useful when editing via web
    # Edit user.email according to what is set in gitlab.yml
    sudo -u git -H git config --global user.name "GitLab"
    sudo -u git -H git config --global user.email "gitlab@localhost"

    sudo -u git cp config/database.yml.mysql config/database.yml

    # 修改数据库账号密码, 刚才添加过gitlab这个数据库用户 直接修改成该账号即可
    sudo -u git vim config/database.yml

9. 安装 Gems

    cd /home/git/gitlab

    sudo gem install charlock_holmes --version '0.6.9.4'

    # 修改Bundle源地址为taobao, 首行改成 source 'http://ruby.taobao.org/'
    sudo -u git vim Gemfile

    # 这个是使用mysql数据库, 这个命令意思是排除postgres 请别搞错
    sudo -u git -H bundle install --deployment --without development test postgres

10. 初始化数据库并启用高级功能

    sudo -u git -H bundle exec rake gitlab:setup RAILS_ENV=production

11. 安装init脚本

    sudo curl --output /etc/init.d/gitlab https://raw.github.com/gitlabhq/gitlabhq/5-2-stable/lib/support/init.d/gitlab
    sudo chmod +x /etc/init.d/gitlab

    #设置开机启动GitLab
    sudo update-rc.d gitlab defaults 21

12. 最后检测一下程序状态

    sudo -u git -H bundle exec rake gitlab:check RAILS_ENV=production

Note: 这里可能会告诉你init脚本有问题或者git版本过低, 可以无视
13. 启动GitLab

    sudo service gitlab start

默认的账户如下

    用户名:admin@local.host
    密码: 5iveL!fe

Nginx配置

你可以安装nginx来代理访问GitLab 配置过程如下
1. 安装nginx

    sudo apt-get install nginx

1. 增加GitLab配置文件

    sudo curl --output /etc/nginx/sites-available/gitlab https://raw.github.com/gitlabhq/gitlabhq/5-2-stable/lib/support/nginx/gitlab
    sudo ln -s /etc/nginx/sites-available/gitlab /etc/nginx/sites-enabled/gitlab

    # 修改配置文件 Listen 直接监听80端口即可 e.g. listen 80;
    # 修改server_name为你的内部域名 e.g. server_name gitlab.uloli;
    sudo vim /etc/nginx/sites-available/gitlab

2. 重启nginx

    sudo service nginx restart

这样你就可以通过nginx来访问gitlab了
