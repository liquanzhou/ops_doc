Go语言介绍Go语言介绍 - 1：安装

简介

关于Go语言，原文介绍如下：
Go is an open source programming environment that makes it easy to build simple, reliable, and efficient software.

本系列文章主要针对Go语言，进行入门介绍。

引文

有两种官方编译器工具链: gc Go编译器和gccgo编译器。
本文以CentOS 6.2为例介绍，使用编译好的二进制分发包进行安装。

下载

访问Go project is downloads page。
(请下载与操作系统环境对应的二进制分发版，本环境使用go.go1.linux-amd64.tar.gz)
注意: 在Linux下，如果是从老版本更新过来的，必须先将老版本删除。（一般是安装在/usr/local/go目录下的） # rm -r /usr/local/go 提取归档文件到 /usr/local 目录，在 /usr/local/go 中创建Go的目录树。 # tar -C /usr/local -xzf go.go1.linux-amd64.tar.gz (通常情况下，这些命令必须以root身份运行，或通过sudo的.)

环境变量

添加 /usr/local/go/bin 到 /etc/profile.d/go.sh (对于CentOS，这样添加便于维护，系统范围的环境变量)，也可以指定用户,$HOME/.bashrc中，建议添加到系统范围的环境变量中。 # vi /etc/profile.d/go.sh 添加如下内容 # Initialization script for go path

export GOROOT=/usr/local/go
export PATH=$PATH:$GOROOT/bin    
使更改立即生效 # source /etc/profile （也可以重启系统使之生效）

测试

很简单，直接在命令行中输入go。 $ go Go is a tool for managing Go source code.

Usage:

    go command [arguments]

The commands are:

    build       compile packages and dependencies
    clean       remove object files
    doc         run godoc on package sources
    env         print Go environment information
    fix         run go tool fix on packages
    fmt         run gofmt on package sources
    get         download and install packages and dependencies
    install     compile and install packages and dependencies
    list        list packages
    run         compile and run Go program
    test        test packages
    tool        run specified go tool
    version     print Go version
    vet         run go tool vet on packages

Use "go help [command]" for more information about a command.

Additional help topics:

    gopath      GOPATH environment variable
    packages    description of package lists
    remote      remote import path syntax
    testflag    description of testing flags
    testfunc    description of testing functions

Use "go help [topic]" for more information about that topic.
至此，Go安装完毕。

当然，可以更进一步测试，新建hello.go，并输入如下代码：

package main
 
import "fmt"
 
func main() {
    fmt.Printf("hello, world\n")
}

使用go的工具运行

$ go run hello.go

hello, world

如果可以看到“hello, world”这个消息，则表示安装成功。