
一、客户端安装

	安装Git-1.8.1.2-preview20130201.exe
	打开 Git Bash
	生成key
	ssh-keygen.exe
	C:\Users\quanzhouli\.ssh\id_rsa.pub

二、用管理员添加新用户

	打开 Git Bash
	cd gitosis-admin
	git pull   # 更新文件

	将新建用户的key放到下 C:\gitosis-admin\keydir
	重命名为 quanzhouli@QUANZHOULI.pub
	
	修改 C:\gitosis-admin\gitosis.conf  
	在 members = 中添加新用户名 quanzhouli@QUANZHOULI
	
	git add .
	git commit -m "add xuesong key"
	git push   # 提交

三、更新项目

	打开 Git Bash
	cd c:
	# 在C盘下创建git项目目录gitosis-admin
	git clone git@10.10.76.42:gitosis-admin.git

	cd gitosis-admin
	git pull 
	git add .
	git commit -m "add xuesong key"
	git push

四、添加项目
	
	服务器创建项目
	10.10.76.42
		cd /home/git/repositories
		# smc-content-check.git 新创建项目名
		mkdir smc-content-check.git
		git init --bare smc-content-check.git
		chown -R git:git smc-content-check.git
	
	在本地更改git配置文件
		打开 Git Bash
		cd gitosis-admin
		git pull

		修改 C:\gitosis-admin\gitosis.conf   
		在 writable = 中添加新项目名 smc-content-check

		git add .
		git commit -m "add smc-content-check"
		git push
		
五、删除文件

    git rm -r -n --cached  ./img      # -n执行命令时，是不会删除任何文件，而是展示此命令要删除的文件列表预览
    git rm -r --cached  ./img         # 最终执行删除命令
    git commit -m "rm img"            # 提交
    git push                          # 提交到远程服务器

git 删除错误提交的commit

起因: 不小新把记录了公司服务器IP,账号,密码的文件提交到了git

方法:
    git reset --hard <commit_id>
    git push origin HEAD --force



其他:

    根据–soft –mixed –hard，会对working tree和index和HEAD进行重置:
    git reset –mixed：此为默认方式，不带任何参数的git reset，即时这种方式，它回退到某个版本，只保留源码，回退commit和index信息
    git reset –soft：回退到某个版本，只回退了commit的信息，不会恢复到index file一级。如果还要提交，直接commit即可
    git reset –hard：彻底回退到某个版本，本地的源码也会变为上一个版本的内容


    HEAD 最近一个提交
    HEAD^ 上一次
    <commit_id> 每次commit的SHA1值. 可以用git log 看到,也可以在页面上commit标签页里找到.