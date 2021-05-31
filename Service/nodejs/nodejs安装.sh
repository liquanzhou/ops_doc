

环境配置
下载并安装node

可能有些目录与这边目录结构不同，按照实际情况修改即可。

cd /tmp/
wget -c http://nodejs.org/dist/v0.10.28/node-v0.10.28-linux-x64.tar.gz
tar zxvf node-v0.10.28-linux-x64.tar.gz
mv node-v0.10.28-linux-x64 node
mv node /usr/local/lib
编辑环境变量

sudo vim /etc/profile
添加下面的内容：

export PATH=$PATH:/usr/local/lib/node/bin
让环境变量生效：

source /etc/profile
验证环境变量是否生效：

node -v # 输出：v0.10.26
npm -v # 输出：1.4.14




发布脚本修改
发布脚本需要在svn co或up之后，需要在项目目录执行：

npm install
#grunt
make
以上两个步骤执行完毕后，方可把项目根目录下生成的build目录放在正式环境下。
