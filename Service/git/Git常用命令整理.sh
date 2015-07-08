
在介绍安装和简单使用前，先看一下百度百科中的简介吧：
————————————————————————————————————————

    Git --- The stupid content tracker, 傻瓜内容跟踪器。

    Linux 是这样给我们介绍 Git 的：

    Git 是用于Linux 内核开发的版本控制工具。与常用的版本控制工具 CVS, Subversion 等不同，它采用了分布式版本库的方式，不必服务器端软件支持，使源代码的发布和交流极其方便。 Git 的速度很快，这对于诸如 Linux kernel 这样的大项目来说自然很重要。 Git 最为出色的是它的合并跟踪（merge tracing）能力。

————————————————————————————————————————

下面我用ubuntu 10.10上的命令为例：（这些命令都是在本地客户端处使用，非服务器操作裸库使用）
（本文中尖括号内包含尖括号都将是描述内容，请在输入实际命令时替换成描述内容所符的内容。）

1、安装：
$ sudo apt-get install git
$ sudo apt-get install gitk#此为安装官方的图形界面，不需要的可以不安装

2、cd到需要管理的代码、文件所在的第一级目录

3、初始化：
$ git init

4、添加当前目录所有内容：
$ git add .

5、查看状态：
$ git status

6、添加commit：
$ git commit -am "first commit."

7、版本对比：
$ git diff

8、查看历史记录：
$ git log

9、分支操作
查看分支：$ git branch
创建分支：$ git branch 分支名称 （注意：请不要在服务端建立分支）
切换分支：$ git checkout 分支名称
删除分支：$ git branch -d 分支名称

10、加入服务器
$ git remote add 用户名@计算机名或IP:~/某个目录

11、推送数据
$ git push master master #本地master推送到远端master
# 如果想快捷的使用git push就推送到默认远端分支master，可以做个一次性设置：
$ git remote add origin <实际的ssl用户名>@<IP地址>:<Git在远端的path>
    # 做完以上设置，以后直接使用git push 就会自动推送到上述设置地址了，但如果要推送到其他分支，还是需要加参数的，这个设置只是相当于一个默认参数而已。

12、接收数据
$ git pull origin master
# 如果想直接使用git pull直接接收，同样需要提前做一个一次性设置（同样也是不能应用多分支pull情况）：
$ git branch --set-upstream master origin/master

13、本地库设置个人姓名和邮件
$ git config --global user.name "你的姓名，最好由没有符合和空格的英文字母组成"
$ git config --global user.email <邮件名>@<邮箱服务商后缀>
如果不设置个人信息，提交的信息将不会有更改者信息，这样会加大项目管理的难度。

14、启动图形界面
$ gitk



Git常用命令整理


取得Git仓库

git init   # 初始化一个版本仓库
git clone git@xbc.me:wordpress.git   # Clone远程版本库
git remote add origin git@xbc.me:wordpress.git   # 添加远程版本库origin，语法为 git remote add [shortname] [url]
git remote -v     # 查看远程仓库

提交你的修改

git add .                                   # 添加当前修改的文件到暂存区
git add -u                                  # 如果你自动追踪文件，包括你已经手动删除的，状态为Deleted的文件
git commit –m &quot;你的注释&quot;          # 提交你的修改
git push origin master                      # 推送你的更新到远程服务器,语法为 git push [远程名] [本地分支]:[远程分支]
git status                                  # 查看文件状态
git add readme.txt                          # 跟踪新文件
git rm readme.txt                           # 从当前跟踪列表移除文件，并完全删除
git rm –cached readme.txt                   # 仅在暂存区删除，保留文件在当前目录，不再跟踪
git mv reademe.txt readme                   # 重命名文件
git log                                     # 查看提交的历史记录
git commit --amend                          # 修改最后一次提交注释的，利用–amend参数
git commit –m &quot;add readme.txt&quot;    # 忘记提交某些修改，下面的三条命令只会得到一个提交。
git add readme_forgotten  
git commit –amend
git reset HEAD b                            # 假设你已经使用git add .，将修改过的文件a、b加到暂存区 现在你只想提交a文件，不想提交b文件，应该这样
git checkout –- readme.txt                  # 取消对文件的修改

基本的分支管理

git branch iss53                            # 创建一个分支
git chekcout iss53                          # 切换工作目录到iss53
git chekcout –b iss53                       # 将上面的命令合在一起，创建iss53分支并切换到iss53
git merge iss53                             # 合并iss53分支，当前工作目录为master
git branch –d iss53                         # 合并完成后，没有出现冲突，删除iss53分支
git fetch                                   # 拉去远程仓库的数据，语法为 git fetch [remote-name]
git pull                                    # fetch 会拉去最新的远程仓库数据，但不会自动到当前目录下，要自动合并
git remote show origin                      # 查看远程仓库的信息
git checkout –b dev origin/develop          # 建立本地的dev分支追踪远程仓库的develop分支



