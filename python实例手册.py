    python实例手册

#encoding:utf8
# 设定编码-支持中文

0 说明

    手册制作: 雪松 littlepy www.51reboot.com
    更新日期: 2016-01-21

    欢迎系统运维加入Q群: 198173206  # 加群请回答问题
    欢迎运维开发加入Q群: 365534424  # 不定期技术分享

    请使用"notepad++"或其它编辑器打开此文档, "alt+0"将函数折叠后方便查阅
    请勿删除信息, 转载请说明出处, 抵制不道德行为
    错误在所难免, 还望指正！

    [python实例手册] [shell实例手册] [LazyManage运维批量管理(shell/python两个版本)]
    网盘更新下载地址:    http://pan.baidu.com/s/1sjsFrmX
    github更新下载地址:  https://github.com/liquanzhou/ops_doc

1 基础

    安装python2.7

        wget https://www.python.org/ftp/python/2.7.9/Python-2.7.9.tgz

        tar xvf Python-2.7.9.tgz
        cd Python-2.7.9
        ./configure --prefix=/usr/local/python27
        make
        make install
        mv /usr/bin/python /usr/bin/python_old
        ln -s /usr/local/python27/bin/python /usr/bin/python
        python          # 查看版本

        解决YUM无法使用的问题

           vim /usr/bin/yum
           首行#!/usr/bin/python 替换为老版本python  #!/usr/bin/python2.4  注意可能为2.6

    pip模块安装

        yum install python-pip            # centos安装pip
        sudo apt-get install python-pip   # ubuntu安装pip
        pip官方安装脚本
            wget https://raw.github.com/pypa/pip/master/contrib/get-pip.py
            python get-pip.py
        pip编译安装
            # https://pypi.python.org/pypi/setuptools
            wget http://pypi.python.org/packages/source/s/setuptools/setuptools.tar.gz
            tar zxvf setuptools.tar.gz
            cd setuptools/
            python setup.py build
            python setup.py install
            # https://pypi.python.org/pypi/ez_setup
            tar zxvf ez_setup.tar.gz
            cd ez_setup/
            python setup.py build
            python setup.py install
            # https://pypi.python.org/pypi/pip
            tar zxvf pip.tar.gz
            cd pip/
            python setup.py build
            python setup.py install
        加载环境变量
            vim /etc/profile
            export PATH=/usr/local/python27/bin:$PATH
            . /etc/profile

        pip freeze                      # 查看包版本
        pip install Package             # 安装包 pip install requests
        pip show --files Package        # 查看安装包时安装了哪些文件
        pip show --files Package        # 查看哪些包有更新
        pip install --upgrade Package   # 更新一个软件包
        pip uninstall Package           # 卸载软件包
        pip list                        # 查看pip安装的包及版本
        pip install django==1.5         # 指定版本安装

    查看帮助

        python -c "help('modules')"     # 查看python所有模块
        import os
        for i in dir(os):
            print i         # 模块的方法
        help(os.path)       # 方法的帮助

    python中关键字

        import keyword
        keyword.iskeyword(str)       # 字符串是否为python关键字
        keyword.kwlist               # 返回pytho所有关键字
        ['and', 'as', 'assert', 'break', 'class', 'continue', 'def', 'del', 'elif', 'else', 'except', 'exec', 'finally', 'for', 'from', 'global', 'if', 'import', 'in', 'is', 'lambda', 'not', 'or', 'pass', 'print', 'raise', 'return', 'try', 'while', 'with', 'yield']

    调试

        python -m trace -t aaaaaa.py
        strace -p pid       # 用系统命令跟踪系统调用

    变量

        r=r'\n'          # 输出时原型打印
        u=u'中文'        # 定义为unicode编码
        global x         # 全局变量
        a = 0 or 2 or 1  # 布尔运算赋值,a值为True既不处理后面,a值为2.  None、字符串''、空元组()、空列表[],空字典{}、0、空字符串都是false
        name = raw_input("input:").strip()        # 输入字符串变量
        num = int(raw_input("input:").strip())    # 输入字符串str转为int型
        locals()                                  # 所有局部变量组成的字典
        locals().values()                         # 所有局部变量值的列表
        os.popen("date -d @{0} +'%Y-%m-%d %H:%M:%S'".format(12)).read()    # 特殊情况引用变量 {0} 代表第一个参数

        基于字典的字符串格式化
            params = {"server":"mpilgrim", "database":"master", "uid":"sa", "pwd":"secret"}
            "%(pwd)s" % params                                         # 'secret'
            "%(pwd)s is not a good password for %(uid)s" % params      # 'secret is not a good password for sa'
            "%(database)s of mind, %(database)s of body" % params      # 'master of mind, master of body'

    打印

        # 字符串 %s  整数 %d  浮点 %f  原样打印 %r
        print '字符串: %s 整数: %d 浮点: %f 原样打印: %r' % ('aa',2,1.0,'r')
        print 'abc',      # 有逗号,代表不换行打印,在次打印会接着本行打印
		print '%-10s %s' % ('aaa','bbb')    # 左对齐 占10个字符
		print '%10s %s' % ('aaa','bbb')     # 右对齐 占10个字符

    列表

        # 列表元素的个数最多 536870912
        shoplist = ['apple', 'mango', 'carrot', 'banana']
        shoplist[2] = 'aa'
        del shoplist[0]
        shoplist.insert(4,'www')
        shoplist.append('aaa')
        shoplist[::-1]    # 倒着打印 对字符翻转串有效
        shoplist[2::3]    # 从第二个开始每隔三个打印
        shoplist[:-1]     # 排除最后一个
        '\t'.join(li)     # 将列表转换成字符串 用字表符分割
        sys.path[1:1]=[5] # 在位置1前面插入列表中一个值
        list(set(['qwe', 'as', '123', '123']))   # 将列表通过集合去重复
        eval("['1','a']")                        # 将字符串当表达式求值,得到列表

        # enumerate 可得到每个值的对应位置
        for i, n in enumerate(['a','b','c']):
            print i,n

    元组

        # 不可变
        zoo = ('wolf', 'elephant', 'penguin')

    字典

        ab = {       'Swaroop'   : 'swaroopch@byteofpython.info',
                     'Larry'     : 'larry@wall.org',
             }
        ab['c'] = 80      # 添加字典元素
        del ab['Larry']   # 删除字典元素
        ab.keys()         # 查看所有键值
        ab.values()       # 打印所有值
        ab.has_key('a')   # 查看键值是否存在
        ab.items()        # 返回整个字典列表

        复制字典
            a = {1: {1: 2, 3: 4}}
            b = a
            b[1][1] = 8888                # a和b都为 {1: {1: 8888, 3: 4}}
            import copy
            c = copy.deepcopy(a)          # 再次赋值 b[1][1] = 9999 拷贝字典为新的字典,互不干扰

            a[2] = copy.deepcopy(a[1])    # 复制出第二个key，互不影响  {1: {1: 2, 3: 4},2: {1: 2, 3: 4}}

    迭代器

        # 创建迭代接口，而不是原来的对象 支持字符串、列表和字典等序列对象
        i = iter('abcd')
        print i.next()

        s = {'one':1,'two':2,'three':3}
        m = iter(s)
        print m.next()                     # 迭代key

    流程结构

        if判断

            # 布尔值操作符 and or not 实现多重判断
            if a == b:
                print '=='
            elif a < b:
                print b
            else:
                print a

        while循环

            while True:
                if a == b:
                    print "=="
                    break
                print "!="
            else:
                print 'over'

            count=0
            while(count<9):
                print count
                count += 1

        for循环

            sorted()           # 返回一个序列(列表)
            zip()              # 返回一个序列(列表)
            enumerate()        # 返回循环列表序列 for i,v in enumerate(['a','b']):
            reversed()         # 反序迭代器对象
            dict.iterkeys()    # 通过键迭代
            dict.itervalues()  # 通过值迭代
            dict.iteritems()   # 通过键-值对迭代
            readline()         # 文件迭代
            iter(obj)          # 得到obj迭代器 检查obj是不是一个序列
            iter(a,b)          # 重复调用a,直到迭代器的下一个值等于b
            for i in range(1, 5):
                print i
            else:
                print 'over'

            list = ['a','b','c','b']
            for i in range(len(list)):
                print list[i]
            for x, Lee in enumerate(list):
                print "%d %s Lee" % (x+1,Lee)

            # enumerate 使用函数得到索引值和对应值
            for i, v in enumerate(['tic', 'tac', 'toe']):
                print(i, v)

        流程结构简写

            [ i * 2 for i in [8,-2,5]]
            [16,-4,10]
            [ i for i in range(8) if i %2 == 0 ]
            [0,2,4,6]

    tab补全

        # vim /usr/lib/python2.7/dist-packages/tab.py
        # python startup file
        import sys
        import readline
        import rlcompleter
        import atexit
        import os
        # tab completion
        readline.parse_and_bind('tab: complete')
        # history file
        histfile = os.path.join(os.environ['HOME'], '.pythonhistory')

    函数

        def printMax(a, b = 1):
            if a > b:
                print a
                return a
            else:
                print b
                return b
        x = 5
        y = 7
        printMax(x, y)

        def update(*args,**kwargs):
            p=''
            for i,t in kwargs.items():
                    p = p+ '%s=%s,' %(i,str(t))
            sql = "update  'user' set (%s) where (%s)" %(args[0],p)
            print sql

        update('aaa',uu='uu',id=3)

    模块

        # Filename: mymodule.py
        def sayhi():
            print 'mymodule'
        version = '0.1'

        # 使用模块中方法
        import mymodule
        from mymodule import sayhi, version
        mymodule.sayhi()   # 使用模块中函数方法

    装饰器

        # 为已存在的功能添加额外的功能,只在初始化脚本的时候执行一次

        #!/usr/bin/env python

        def deco(func):
            def wrapper(*args, **kwargs):
                print "Wrap start"
                func(*args, **kwargs)
                func(*args, **kwargs)
                print "Wrap end\n"
            return wrapper

        @deco
        def foo(x):
            print "In foo():"
            print "I have a para: %s" % x
        @deco
        def foo_dict(x,z='dict_para'):
            print "In foo_dict:"
            print "I have two para, %s and %s" % (x, z)

        if __name__ == "__main__":
            # 装饰器 @deco  等价于 foo = deco(foo)
            foo('x')
            foo_dict('x', z='dict_para')

        结果

            Wrap start
            In foo():
            I have a para: x
            In foo():
            I have a para: x
            Wrap end

            Wrap start
            In foo_dict:
            I have two para, x and dict_para
            In foo_dict:
            I have two para, x and dict_para
            Wrap end

    类对象的方法

        __xxx__               # 系统定义名字
        __init__              # 实例化初始化类的方法
        __all__ = ['xs']      # __all__ 用于模块import导入时限制,定义了只有all内指定的属性、方法、类可被导入,没定义则模块内的所有将被导入
        _xxx                  # _开头的为私有类,只有类对象和子类对象自己能访问到这些变量  不能用 from module import * 导入  class _status:
        __xxx                 # __开头的为类中的私有变量名,只有类对象自己能访问,连子类对象也不能访问到这个数据

        class Person:
            # 实例化初始化的方法
            def __init__(self, name ,age):
                self.name = name
                self.age = age
                print self.name
            # 有self此函数为方法
            def sayHi(self):
                print 'Hello, my name is', self.name
            # 对象消逝的时候被调用
            def __del__(self):
                print 'over'
        # 实例化对象
        p = Person('Swaroop',23)
        # 使用对象方法
        p.sayHi()
        # 继承
        class Teacher(Person):
            def __init__(self, name, age, salary):
                Person.__init__(self, name, age)
                self.salary = salary
                print '(Initialized Teacher: %s)' % self.name
            def tell(self):
                Person.tell(self)
                print 'Salary: "%d"' % self.salary
        t = Teacher('Mrs. Shrividya', 40, 30000)

        getattr(object,name,default)

            # 返回object的名称为name的属性的属性值,如果属性name存在,则直接返回其属性值.如果属性name不存在,则触发AttribetError异常或当可选参数default定义时返回default值

            class A:
                def __init__(self):
                    self.name = 'zhangjing'
                def method(self):
                    print"method print"

            Instance = A()
            print getattr(Instance , 'name', 'not find')           # 如果Instance 对象中有属性name则打印self.name的值，否则打印'not find'
            print getattr(Instance , 'age', 'not find')            # 如果Instance 对象中有属性age则打印self.age的值，否则打印'not find'
            print getattr(Instance, 'method', 'default')           # 如果有方法method，否则打印其地址，否则打印default
            print getattr(Instance, 'method', 'default')()         # 如果有方法method，运行函数并打印None否则打印default

        setattr(object,name,value)

            # 设置object的名称为name(type：string)的属性的属性值为value，属性name可以是已存在属性也可以是新属性。

            #等同多次 self.name = name 赋值 在外部可以直接把变量和值对应关系传进去
            #class Person:
            #    def __init__(self, name ,age):
            #        self.name = name
            #        self.age = age

            config = {'name':'name','age','age'}
            class Configure(object):
                def __init__(self, config):
                    self.register(config)

                def register(self, config):
                    for key, value in config.items():
                        if key.upper() == key:
                            setattr(self, key, value)

    模块包

        # 文件 ops/fileserver/__init__.py
        import readers
        import writers

        # 每个模块的包中，都有一个 __init__.py 文件，有了这个文件，才能导入这个目录下的module，在导入一个包时 import ops.fileserver ，实际上是导入了它的 __init__.py 文件，可以再 __init__.py 文件中再导入其他的包，或者模块。就不需要将所有的import语句写在一个文件里了，也可以减少代码量，不需要一个个去导入module了。
        # __init__.py 有一个重要的变量 __all__ 。有时会需要全部导入，from PackageName import *   ，这时 import 就会把注册在包 __init__.py 文件中 __all__ 列表中的子模块和子包导入到当前作用域中来。如：
        __all__ = ["Module1", "Module2", "subPackage1", "subPackage2"]

    执行模块类中的所有方法

        # moniItems.py
        import sys, time
        import inspect

        class mon:
            def __init__(self):
                self.data = dict()
            def run(self):
                return self.runAllGet()
            def getDisk(self):
                return 222
            def getCpu(self):
                return 111
            def runAllGet(self):
                for fun in inspect.getmembers(self, predicate=inspect.ismethod):
                    print fun[0], fun[1]
                    if fun[0][:3] == 'get':
                        self.data[fun[0][3:]] = fun[1]()
                print self.data
                return self.data

        # 模块导入使用
        from moniItems import mon
        m = mon()
        m.runAllGet()

    文件处理

        # 模式: 读'r'  写[清空整个文件]'w' 追加[文件需要存在]'a' 读写'r+' 二进制文件'b'  'rb','wb','rb+'

        写文件
            i={'ddd':'ccc'}
            f = file('poem.txt', 'a')
            f.write("string")
            f.write(str(i))
            f.flush()
            f.close()

        读文件
            f = file('/etc/passwd','r')
            c = f.read().strip()        # 读取为一个大字符串，并去掉最后一个换行符
            for i in c.spilt('\n'):     # 用换行符切割字符串得到列表循环每行
                print i
            f.close()

        读文件1
            f = file('/etc/passwd','r')
            while True:
                line = f.readline()    # 返回一行
                if len(line) == 0:
                    break
                x = line.split(":")                  # 冒号分割定义序列
                #x = [ x for x in line.split(":") ]  # 冒号分割定义序列
                #x = [ x.split("/") for x in line.split(":") ]  # 先冒号分割,在/分割 打印x[6][1]
                print x[6],"\n",
            f.close()

        读文件2
            f = file('/etc/passwd')
            c = f.readlines()       # 读入所有文件内容,可反复读取,大文件时占用内存较大
            for line in c:
                print line.rstrip(),
            f.close()

        读文件3
            for i in open('b.txt'):   # 直接读取也可迭代,并有利于大文件读取,但不可反复读取
                print i,

        追加日志
            log = open('/home/peterli/xuesong','a')
            print >> log,'faaa'
            log.close()

        with读文件

            # 自动关闭文件、线程锁的自动获取和释放等
            with open('a.txt') as f:
                for i in f:
                    print i
                print f.read()        # 打印所有内容为字符串
                print f.readlines()   # 打印所有内容按行分割的列表

        文件随机读写

            # 文件本没有换行,一切都是字符,文件也没有插入功能
            f.tell()       # 当前读写位置
            f.read(5)      # 读取5个字符并改变指针
            f.seek(5)      # 改变用户态读写指针偏移位置,可做随机写
            f.seek(p,0)    # 移动当文件第p个字节处，绝对位置
            f.seek(p,1)    # 移动到相对于当前位置之后的p个字节
            f.seek(p,2)    # 移动到相对文件尾之后的p个字节
            f.seek(0,2)    # 指针指到尾部
            # 改变指针超出文件尾部,会造成文件洞,ll看占用较大，但du -sh却非常小
            f.read(65535)  # 读取64K字节
            f.write("str") # 写会覆盖当前指针后的响应字符,无插入功能

    内建函数

        dir(sys)            # 显示对象的属性
        help(sys)           # 交互式帮助
        int(obj)            # 转型为整形
        str(obj)            # 转为字符串
        len(obj)            # 返回对象或序列长度
        open(file,mode)     # 打开文件 #mode (r 读,w 写, a追加)
        range(0,3)          # 返回一个整形列表
        raw_input("str:")   # 等待用户输入
        type(obj)           # 返回对象类型
        abs(-22)            # 绝对值
        random              # 随机数
        choice()            # 随机返回给定序列的一个元素
        divmod(x,y)         # 函数完成除法运算，返回商和余数。
        round(x[,n])        # 函数返回浮点数x的四舍五入值，如给出n值，则代表舍入到小数点后的位数
        strip()             # 是去掉字符串两端多于空格,该句是去除序列中的所有字串两端多余的空格
        del                 # 删除列表里面的数据
        cmp(x,y)            # 比较两个对象    #根据比较结果返回一个整数，如果x<y，则返回-1；如果x>y，则返回1,如果x==y则返回0
        max()               # 字符串中最大的字符
        min()               # 字符串中最小的字符
        sorted()            # 对序列排序
        reversed()          # 对序列倒序
        enumerate()         # 返回索引位置和对应的值
        sum()               # 总和
        list()              # 变成列表可用于迭代
        eval('3+4')         # 将字符串当表达式求值 得到7
        exec 'a=100'        # 将字符串按python语句执行
        exec(a+'=new')      # 将变量a的值作为新的变量
        tuple()             # 变成元组可用于迭代   #一旦初始化便不能更改的数据结构,速度比list快
        zip(s,t)            # 返回一个合并后的列表  s = ['11','22']  t = ['aa','bb']  [('11', 'aa'), ('22', 'bb')]
        isinstance(object,int)    # 测试对象类型 int
        xrange([lower,]stop[,step])            # 函数与range()类似，但xrnage()并不创建列表，而是返回一个xrange对象

    列表类型内建函数

        list.append(obj)                 # 向列表中添加一个对象obj
        list.count(obj)                  # 返回一个对象obj在列表中出现的次数
        list.extend(seq)                 # 把序列seq的内容添加到列表中
        list.index(obj,i=0,j=len(list))  # 返回list[k] == obj 的k值,并且k的范围在i<=k<j;否则异常
        list.insert(index.obj)           # 在索引量为index的位置插入对象obj
        list.pop(index=-1)               # 删除并返回指定位置的对象,默认是最后一个对象
        list.remove(obj)                 # 从列表中删除对象obj
        list.reverse()                   # 原地翻转列表
        list.sort(func=None,key=None,reverse=False)  # 以指定的方式排序列表中成员,如果func和key参数指定,则按照指定的方式比较各个元素,如果reverse标志被置为True,则列表以反序排列

    序列类型操作符

        seq[ind]              # 获取下标为ind的元素
        seq[ind1:ind2]        # 获得下标从ind1到ind2的元素集合
        seq * expr            # 序列重复expr次
        seq1 + seq2           # 连接seq1和seq2
        obj in seq            # 判断obj元素是否包含在seq中
        obj not in seq        # 判断obj元素是否不包含在seq中

    字符串类型内建方法

        string.expandtabs(tabsize=8)                  # tab符号转为空格 #默认8个空格
        string.endswith(obj,beg=0,end=len(staring))   # 检测字符串是否已obj结束,如果是返回True #如果beg或end指定检测范围是否已obj结束
        string.count(str,beg=0,end=len(string))       # 检测str在string里出现次数  f.count('\n',0,len(f)) 判断文件行数
        string.find(str,beg=0,end=len(string))        # 检测str是否包含在string中
        string.index(str,beg=0,end=len(string))       # 检测str不在string中,会报异常
        string.isalnum()                              # 如果string至少有一个字符并且所有字符都是字母或数字则返回True
        string.isalpha()                              # 如果string至少有一个字符并且所有字符都是字母则返回True
        string.isnumeric()                            # 如果string只包含数字字符,则返回True
        string.isspace()                              # 如果string包含空格则返回True
        string.isupper()                              # 字符串都是大写返回True
        string.islower()                              # 字符串都是小写返回True
        string.lower()                                # 转换字符串中所有大写为小写
        string.upper()                                # 转换字符串中所有小写为大写
        string.lstrip()                               # 去掉string左边的空格
        string.rstrip()                               # 去掉string字符末尾的空格
        string.replace(str1,str2,num=string.count(str1))  # 把string中的str1替换成str2,如果num指定,则替换不超过num次
        string.startswith(obj,beg=0,end=len(string))  # 检测字符串是否以obj开头
        string.zfill(width)                           # 返回字符长度为width的字符,原字符串右对齐,前面填充0
        string.isdigit()                              # 只包含数字返回True
        string.split("分隔符")                        # 把string切片成一个列表
        ":".join(string.split())                      # 以:作为分隔符,将所有元素合并为一个新的字符串

    字典内建方法

        dict.clear()                            # 删除字典中所有元素
        dict copy()                             # 返回字典(浅复制)的一个副本
        dict.fromkeys(seq,val=None)             # 创建并返回一个新字典,以seq中的元素做该字典的键,val做该字典中所有键对的初始值
        dict.get(key,default=None)              # 对字典dict中的键key,返回它对应的值value,如果字典中不存在此键,则返回default值
        dict.has_key(key)                       # 如果键在字典中存在,则返回True 用in和not in代替
        dict.items()                            # 返回一个包含字典中键、值对元组的列表
        dict.keys()                             # 返回一个包含字典中键的列表
        dict.iter()                             # 方法iteritems()、iterkeys()、itervalues()与它们对应的非迭代方法一样,不同的是它们返回一个迭代子,而不是一个列表
        dict.pop(key[,default])                 # 和方法get()相似.如果字典中key键存在,删除并返回dict[key]
        dict.setdefault(key,default=None)       # 和set()相似,但如果字典中不存在key键,由dict[key]=default为它赋值
        dict.update(dict2)                      # 将字典dict2的键值对添加到字典dict
        dict.values()                           # 返回一个包含字典中所有值得列表

        dict([container])     # 创建字典的工厂函数。提供容器类(container),就用其中的条目填充字典
        len(mapping)          # 返回映射的长度(键-值对的个数)
        hash(obj)             # 返回obj哈希值,判断某个对象是否可做一个字典的键值

    集合方法

        s.update(t)                         # 用t中的元素修改s,s现在包含s或t的成员   s |= t
        s.intersection_update(t)            # s中的成员是共用属于s和t的元素          s &= t
        s.difference_update(t)              # s中的成员是属于s但不包含在t中的元素    s -= t
        s.symmetric_difference_update(t)    # s中的成员更新为那些包含在s或t中,但不是s和t共有的元素  s ^= t
        s.add(obj)                          # 在集合s中添加对象obj
        s.remove(obj)                       # 从集合s中删除对象obj;如果obj不是集合s中的元素(obj not in s),将引发KeyError错误
        s.discard(obj)                      # 如果obj是集合s中的元素,从集合s中删除对象obj
        s.pop()                             # 删除集合s中的任意一个对象,并返回它
        s.clear()                           # 删除集合s中的所有元素
        s.issubset(t)                       # 如果s是t的子集,则返回True   s <= t
        s.issuperset(t)                     # 如果t是s的超集,则返回True   s >= t
        s.union(t)                          # 合并操作;返回一个新集合,该集合是s和t的并集   s | t
        s.intersection(t)                   # 交集操作;返回一个新集合,该集合是s和t的交集   s & t
        s.difference(t)                     # 返回一个新集合,改集合是s的成员,但不是t的成员  s - t
        s.symmetric_difference(t)           # 返回一个新集合,该集合是s或t的成员,但不是s和t共有的成员   s ^ t
        s.copy()                            # 返回一个新集合,它是集合s的浅复制
        obj in s                            # 成员测试;obj是s中的元素 返回True
        obj not in s                        # 非成员测试:obj不是s中元素 返回True
        s == t                              # 等价测试 是否具有相同元素
        s != t                              # 不等价测试
        s < t                               # 子集测试;s!=t且s中所有元素都是t的成员
        s > t                               # 超集测试;s!=t且t中所有元素都是s的成员

    序列化

        #!/usr/bin/python
        import cPickle
        obj = {'1':['4124','1241','124'],'2':['12412','142','1241']}

        pkl_file = open('account.pkl','wb')
        cPickle.dump(obj,pkl_file)
        pkl_file.close()

        pkl_file = open('account.pkl','rb')
        account_list = cPickle.load(pkl_file)
        pkl_file.close()

    文件对象方法

        file.close()                     # 关闭文件
        file.fileno()                    # 返回文件的描述符
        file.flush()                     # 刷新文件的内部缓冲区
        file.isatty()                    # 判断file是否是一个类tty设备
        file.next()                      # 返回文件的下一行,或在没有其他行时引发StopIteration异常
        file.read(size=-1)               # 从文件读取size个字节,当未给定size或给定负值的时候,读取剩余的所有字节,然后作为字符串返回
        file.readline(size=-1)           # 从文件中读取并返回一行(包括行结束符),或返回最大size个字符
        file.readlines(sizhint=0)        # 读取文件的所有行作为一个列表返回
        file.xreadlines()                # 用于迭代,可替换readlines()的一个更高效的方法
        file.seek(off, whence=0)         # 在文件中移动文件指针,从whence(0代表文件起始,1代表当前位置,2代表文件末尾)偏移off字节
        file.tell()                      # 返回当前在文件中的位置
        file.truncate(size=file.tell())  # 截取文件到最大size字节,默认为当前文件位置
        file.write(str)                  # 向文件写入字符串
        file.writelines(seq)             # 向文件写入字符串序列seq;seq应该是一个返回字符串的可迭代对象

    文件对象的属性

        file.closed          # 表示文件已被关闭,否则为False
        file.encoding        # 文件所使用的编码  当unicode字符串被写入数据时,它将自动使用file.encoding转换为字节字符串;若file.encoding为None时使用系统默认编码
        file.mode            # Access文件打开时使用的访问模式
        file.name            # 文件名
        file.newlines        # 未读取到行分隔符时为None,只有一种行分隔符时为一个字符串,当文件有多种类型的行结束符时,则为一个包含所有当前所遇到的行结束符的列表
        file.softspace       # 为0表示在输出一数据后,要加上一个空格符,1表示不加

    异常处理

        # try 中使用 sys.exit(2) 会被捕获,无法退出脚本,可使用 os._exit(2) 退出脚本

        class ShortInputException(Exception):  # 继承Exception异常的类,定义自己的异常
            def __init__(self, length, atleast):
                Exception.__init__(self)
                self.length = length
                self.atleast = atleast
        try:
            s = raw_input('Enter something --> ')
            if len(s) < 3:
                raise ShortInputException(len(s), 3)    # 触发异常
        except EOFError:
            print '\nWhy did you do an EOF on me?'
        except ShortInputException, x:      # 捕捉指定错误信息
            print 'ShortInputException:  %d | %d' % (x.length, x.atleast)
        except Exception as err:            # 捕捉所有其它错误信息内容
            print str(err)
        #except urllib2.HTTPError as err:   # 捕捉外部导入模块的错误
        #except:                            # 捕捉所有其它错误 不会看到错误内容
        #        print 'except'
        finally:                            # 无论什么情况都会执行 关闭文件或断开连接等
               print 'finally'
        else:                               # 无任何异常 无法和finally同用
            print 'No exception was raised.'

        不可捕获的异常

            NameError:              # 尝试访问一个未申明的变量
            ZeroDivisionError:      # 除数为零
            SyntaxErrot:            # 解释器语法错误
            IndexError:             # 请求的索引元素超出序列范围
            KeyError:               # 请求一个不存在的字典关键字
            IOError:                # 输入/输出错误
            AttributeError:         # 尝试访问未知的对象属性
            ImportError             # 没有模块
            IndentationError        # 语法缩进错误
            KeyboardInterrupt       # ctrl+C
            SyntaxError             # 代码语法错误
            ValueError              # 值错误
            TypeError               # 传入对象类型与要求不符合

        内建异常

            BaseException                # 所有异常的基类
            SystemExit                   # python解释器请求退出
            KeyboardInterrupt            # 用户中断执行
            Exception                    # 常规错误的基类
            StopIteration                # 迭代器没有更多的值
            GeneratorExit                # 生成器发生异常来通知退出
            StandardError                # 所有的内建标准异常的基类
            ArithmeticError              # 所有数值计算错误的基类
            FloatingPointError           # 浮点计算错误
            OverflowError                # 数值运算超出最大限制
            AssertionError               # 断言语句失败
            AttributeError               # 对象没有这个属性
            EOFError                     # 没有内建输入,到达EOF标记
            EnvironmentError             # 操作系统错误的基类
            IOError                      # 输入/输出操作失败
            OSError                      # 操作系统错误
            WindowsError                 # windows系统调用失败
            ImportError                  # 导入模块/对象失败
            KeyboardInterrupt            # 用户中断执行(通常是ctrl+c)
            LookupError                  # 无效数据查询的基类
            IndexError                   # 序列中没有此索引(index)
            KeyError                     # 映射中没有这个键
            MemoryError                  # 内存溢出错误(对于python解释器不是致命的)
            NameError                    # 未声明/初始化对象(没有属性)
            UnboundLocalError            # 访问未初始化的本地变量
            ReferenceError               # 若引用试图访问已经垃圾回收了的对象
            RuntimeError                 # 一般的运行时错误
            NotImplementedError          # 尚未实现的方法
            SyntaxError                  # python语法错误
            IndentationError             # 缩进错误
            TabError                     # tab和空格混用
            SystemError                  # 一般的解释器系统错误
            TypeError                    # 对类型无效的操作
            ValueError                   # 传入无效的参数
            UnicodeError                 # Unicode相关的错误
            UnicodeDecodeError           # Unicode解码时的错误
            UnicodeEncodeError           # Unicode编码时的错误
            UnicodeTranslateError        # Unicode转换时错误
            Warning                      # 警告的基类
            DeprecationWarning           # 关于被弃用的特征的警告
            FutureWarning                # 关于构造将来语义会有改变的警告
            OverflowWarning              # 旧的关于自动提升为长整形的警告
            PendingDeprecationWarning    # 关于特性将会被废弃的警告
            RuntimeWarning               # 可疑的运行时行为的警告
            SyntaxWarning                # 可疑的语法的警告
            UserWarning                  # 用户代码生成的警告

        触发异常

            raise exclass            # 触发异常,从exclass生成一个实例(不含任何异常参数)
            raise exclass()          # 触发异常,但现在不是类;通过函数调用操作符(function calloperator:"()")作用于类名生成一个新的exclass实例,同样也没有异常参数
            raise exclass, args      # 触发异常,但同时提供的异常参数args,可以是一个参数也可以是元组
            raise exclass(args)      # 触发异常,同上
            raise exclass, args, tb  # 触发异常,但提供一个跟踪记录(traceback)对象tb供使用
            raise exclass,instance   # 通过实例触发异常(通常是exclass的实例)
            raise instance           # 通过实例触发异常;异常类型是实例的类型:等价于raise instance.__class__, instance
            raise string             # 触发字符串异常
            raise string, srgs       # 触发字符串异常,但触发伴随着args
            raise string,args,tb     # 触发字符串异常,但提供一个跟踪记录(traceback)对象tb供使用
            raise                    # 重新触发前一个异常,如果之前没有异常,触发TypeError

        跟踪异常栈

            # traceback 获取异常相关数据都是通过sys.exc_info()函数得到的
            import traceback
            import sys
            try:
                s = raw_input()
                print int(s)
            except ValueError:
                # sys.exc_info() 返回值是元组，第一个exc_type是异常的对象类型，exc_value是异常的值，exc_tb是一个traceback对象，对象中包含出错的行数、位置等数据
                exc_type, exc_value, exc_tb = sys.exc_info()
                print "\n%s \n %s \n %s\n" %(exc_type, exc_value, exc_tb )
                traceback.print_exc()        # 打印栈跟踪信息

        抓取全部错误信息存如字典

            import sys, traceback

            try:
                s = raw_input()
                int(s)
            except:
                exc_type, exc_value, exc_traceback = sys.exc_info()
                traceback_details = {
                                     'filename': exc_traceback.tb_frame.f_code.co_filename,
                                     'lineno'  : exc_traceback.tb_lineno,
                                     'name'    : exc_traceback.tb_frame.f_code.co_name,
                                     'type'    : exc_type.__name__,
                                     'message' : exc_value.message,
                                    }

                del(exc_type, exc_value, exc_traceback)
                print traceback_details
                f = file('test1.txt', 'a')
                f.write("%s %s %s %s %s\n" %(traceback_details['filename'],traceback_details['lineno'],traceback_details['name'],traceback_details['type'],traceback_details['message'], ))
                f.flush()
                f.close()

    调试log

        # cgitb覆盖了默认sys.excepthook全局异常拦截器
        def func(a, b):
            return a / b
        if __name__ == '__main__':
            import cgitb
            cgitb.enable(format='text')
            func(1, 0)

    函数式编程的内建函数

        apply(func[,nkw][,kw])          # 用可选的参数来调用func,nkw为非关键字参数,kw为关键字参数;返回值是函数调用的返回值
        filter(func,seq)                # 调用一个布尔函数func来迭代遍历每个seq中的元素;返回一个使func返回值为true的元素的序列
        map(func,seq1[,seq2])           # 将函数func作用于给定序列(s)的每个元素,并用一个列表来提供返回值;如果func为None,func表现为一个身份函数,返回一个含有每个序列中元素集合的n个元组的列表
        reduce(func,seq[,init])         # 将二元函数作用于seq序列的元素,每次携带一堆(先前的结果以及下一个序列元素),连续地将现有的结果和下一个值作用在获得的随后的结果上,最后减少我们的序列为一个单一的返回值;如果初始值init给定,第一个比较会是init和第一个序列元素而不是序列的头两个元素
        lambda x,y:x+y                  # 创建一个匿名函数 可用于上面几种方法中直接创建匿名函数式

        # filter 即通过函数方法只保留结果为真的值组成列表
        def f(x): return x % 2 != 0 and x % 3 != 0
        f(3)     # 函数结果是False  3被filter抛弃
        f(5)     # 函数结果是True   5被加入filter最后的列表结果
        filter(f, range(2, 25))
        [5, 7, 11, 13, 17, 19, 23]

        # map 通过函数对列表进行处理得到新的列表
        def cube(x): return x*x*x
        map(cube, range(1, 11))
        [1, 8, 27, 64, 125, 216, 343, 512, 729, 1000]

        # reduce 通过函数会先接收初始值和序列的第一个元素，然后是返回值和下一个元素，依此类推
        def add(x,y): return x+y
        reduce(add, range(1, 11))              # 结果55  是1到10的和  x的值是上一次函数返回的结果，y是列表中循环的值
        reduce(lambda x,y:x+y, range(1,11))    # 等同上面两条  lambda来创建匿名函数[ lambda x,y:x+y ] ,后面跟可迭代的对象

    编码转换

        a='中文'                    # 编码未定义按输入终端utf8或gbk
        u=u'中文'                   # 定义为unicode编码  u值为 u'\u4e2d\u6587'
        u.encode('utf8')            # 转为utf8格式 u值为 '\xe4\xb8\xad\xe6\x96\x87'
        print u                     # 结果显示 中文
        print u.encode('utf8')      # 转为utf8格式,当显示终端编码为utf8  结果显示 中文  编码不一致则乱码
        print u.encode('gbk')       # 当前终端为utf8 故乱码
        ord('4')                    # 字符转ASCII码
        chr(52)                     # ASCII码转字符

    遍历递归

        [os.path.join(x[0],y) for x in os.walk('/root/python/5') for y in x[2]]

        for i in os.walk('/root/python/5/work/server'):
            print i

    元类

        # 实现动态curd类的或者实例中的方法属性

        #!/usr/bin/env python
        # -*- coding:utf-8 -*-
        # Name:        metaclass.py
        # Author:      ZhiPeng Wang.
        # Created:     15/8/12
        # Copyright:   (c) TigerJoys-SA 2015
        # -----------------------------------------------------------------------------

        """首先检查__metaclass__属性, 如果设置了此属性, 如果设置了此属性则调用对应Metaclass,
        Metaclass本身也是Class 当调用时先调用自身的__new__方法新建一个Instance然后Instance调
        用__init__返回一个新对象(MyClss), 然后正常执行原Class
        """

        ext_attr = {
            'wzp': 'wzp',
            'test': 'test',
        }

        class CustomMeta(type):
            build_in_attr = ['name', ]

            def __new__(cls, class_name, bases, attributes):
                # 获取`Meta` Instance
                attr_meta = attributes.pop('Meta', None)
                if attr_meta:
                    for attr in cls.build_in_attr:      # 遍历内置属性
                        # 自省, 获取Meta Attributes 不是build_in_attr的属性不处理
                        print "Meta:", getattr(attr_meta, attr, False)
                # 扩展属性
                attributes.update(ext_attr)
                return type.__new__(cls, class_name, bases, attributes)

            def __init__(cls, class_name, bases, attributes):
                super(CustomMeta, cls).__init__(class_name, bases, attributes)

        class MyClass(object):
            __metaclass__ = CustomMeta  # metaclass
            class Meta:
                name = 'Meta attr'

        if __name__ == '__main__':

            # TODO 此处返回一个类｀Instance｀对象
            print MyClass()

            # TODO 此处返回一个类对象, 并不是｀Instance｀
            print type("MyClass", (), {})

2 常用模块

    sys             [系统操作模块]

        sys.argv              # 取参数列表
        sys.exit(2)           # 退出脚本返回状态 会被try截取
        sys.exc_info()        # 获取当前正在处理的异常类
        sys.version           # 获取Python解释程序的版本信息
        sys.maxint            # 最大的Int值  9223372036854775807
        sys.maxunicode        # 最大的Unicode值
        sys.modules           # 返回系统导入的模块字段，key是模块名，value是模块
        sys.path              # 返回模块的搜索路径，初始化时使用PYTHONPATH环境变量的值
        sys.platform          # 返回操作系统平台名称
        sys.stdout            # 标准输出
        sys.stdin             # 标准输入
        sys.stderr            # 错误输出
        sys.exec_prefix       # 返回平台独立的python文件安装的位置
        sys.stdin.readline()  # 从标准输入读一行
        sys.stdout.write("a") # 屏幕输出a
        sys.path.insert(1, os.path.join(sys.path[0], '/opt/script/'))     # 将/opt/script/目录加入环境变量，可导入相应模块

    os              [系统模块]

        # 相对sys模块 os模块更为底层 os._exit() try无法抓取
        os.popen('id').read()      # 执行系统命令得到返回结果
        os.system()                # 得到返回状态 返回无法截取
        os.name                    # 返回系统平台 Linux/Unix用户是'posix'
        os.getenv()                # 读取环境变量
        os.putenv()                # 设置环境变量
        os.getcwd()                # 当前工作路径
        os.chdir()                 # 改变当前工作目录
        os.walk('/root/')          # 递归路径
        os.environ['HOME']         # 查看系统环境变量
        os.statvfs("/")            # 获取磁盘信息

        文件处理
            mkfifo()/mknod()       # 创建命名管道/创建文件系统节点
            remove()/unlink()      # 删除文件
            rename()/renames()     # 重命名文件
            stat()                 # 返回文件信息
            symlink()              # 创建符号链接
            utime()                # 更新时间戳
            tmpfile()              # 创建并打开('w+b')一个新的临时文件
            walk()                 # 遍历目录树下的所有文件名

            oct(os.stat('th1.py').st_mode)[-3:]      # 查看目录权限

        目录/文件夹
            chdir()/fchdir()       # 改变当前工作目录/通过一个文件描述符改变当前工作目录
            chroot()               # 改变当前进程的根目录
            listdir()              # 列出指定目录的文件
            getcwd()/getcwdu()     # 返回当前工作目录/功能相同,但返回一个unicode对象
            mkdir()/makedirs()     # 创建目录/创建多层目录
            rmdir()/removedirs()   # 删除目录/删除多层目录

        访问/权限
            saccess()                    # 检验权限模式
            chmod('txt',eval("0777"))    # 改变权限模式
            chown()/lchown()             # 改变owner和groupID功能相同,但不会跟踪链接
            umask()                      # 设置默认权限模式

        文件描述符操作
            open()                 # 底层的操作系统open(对于稳健,使用标准的内建open()函数)
            read()/write()         # 根据文件描述符读取/写入数据 按大小读取文件部分内容
            dup()/dup2()           # 复制文件描述符号/功能相同,但是复制到另一个文件描述符

        设备号
            makedev()              # 从major和minor设备号创建一个原始设备号
            major()/minor()        # 从原始设备号获得major/minor设备号

        os.path模块

            os.path.expanduser('~/.ssh/key')   # 家目录下文件的全路径

            分隔
                os.path.basename()         # 去掉目录路径,返回文件名
                os.path.dirname()          # 去掉文件名,返回目录路径
                os.path.join()             # 将分离的各部分组合成一个路径名
                os.path.spllt()            # 返回(dirname(),basename())元组
                os.path.splitdrive()       # 返回(drivename,pathname)元组
                os.path.splitext()         # 返回(filename,extension)元组

            信息
                os.path.getatime()         # 返回最近访问时间
                os.path.getctime()         # 返回文件创建时间
                os.path.getmtime()         # 返回最近文件修改时间
                os.path.getsize()          # 返回文件大小(字节)

            查询
                os.path.exists()           # 指定路径(文件或目录)是否存在
                os.path.isabs()            # 指定路径是否为绝对路径
                os.path.isdir()            # 指定路径是否存在且为一个目录
                os.path.isfile()           # 指定路径是否存在且为一个文件
                os.path.islink()           # 指定路径是否存在且为一个符号链接
                os.path.ismount()          # 指定路径是否存在且为一个挂载点
                os.path.samefile()         # 两个路径名是否指向同一个文件

        子进程
            os.fork()    # 创建子进程,并复制父进程所有操作  通过判断pid = os.fork() 的pid值,分别执行父进程与子进程操作，0为子进程
            os.wait()    # 等待子进程结束

        跨平台os模块属性

            linesep         # 用于在文件中分隔行的字符串
            sep             # 用来分隔文件路径名字的字符串
            pathsep         # 用于分割文件路径的字符串
            curdir          # 当前工作目录的字符串名称
            pardir          # 父目录字符串名称

        磁盘空间

            import os
            disk = os.statvfs("/")
            # disk.f_bsize       块大小
            # disk.f_blocks      块总数
            # disk.f_bfree       剩余块总数
            # disk.f_bavail      非root用户的剩余块数  由于权限小会比root的剩余块总数小 用这个做报警会更准确
            # disk.f_files       总节点数
            # disk.f_ffree       剩余节点数
            # disk.f_favail      非root用户的剩余节点数

            disk.f_bsize * disk.f_bavail / 1024 / 1024 / 1024   # 非root用户剩余空间大小G
            disk.f_bsize * disk.f_blocks / 1024 / 1024 / 1024   # 分区空间总大小

    commands        [执行系统命令]

        commands.getstatusoutput('id')       # 返回元组(状态,标准输出)
        commands.getoutput('id')             # 只返回执行的结果, 忽略返回值
        commands.getstatus('file')           # 返回ls -ld file执行的结果

    re              [perl风格正则]

        compile(pattern,flags=0)          # 对正则表达式模式pattern进行编译,flags是可选标识符,并返回一个regex对象
        match(pattern,string,flags=0)     # 尝试用正则表达式模式pattern匹配字符串string,flags是可选标识符,如果匹配成功,则返回一个匹配对象;否则返回None
        search(pattern,string,flags=0)    # 在字符串string中搜索正则表达式模式pattern的第一次出现,flags是可选标识符,如果匹配成功,则返回一个匹配对象;否则返回None
        findall(pattern,string[,flags])   # 在字符串string中搜索正则表达式模式pattern的所有(非重复)出现:返回一个匹配对象的列表  # pattern=u'\u4e2d\u6587' 代表UNICODE
        finditer(pattern,string[,flags])  # 和findall()相同,但返回的不是列表而是迭代器;对于每个匹配,该迭代器返回一个匹配对象
        split(pattern,string,max=0)       # 根据正则表达式pattern中的分隔符把字符string分割为一个列表,返回成功匹配的列表,最多分割max次(默认所有)
        sub(pattern,repl,string,max=0)    # 把字符串string中所有匹配正则表达式pattern的地方替换成字符串repl,如果max的值没有给出,则对所有匹配的地方进行替换(subn()会返回一个表示替换次数的数值)
        group(num=0)                      # 返回全部匹配对象(或指定编号是num的子组)
        groups()                          # 返回一个包含全部匹配的子组的元组(如果没匹配成功,返回一个空元组)

        零宽断言
            str = 'aaa111aaa , bbb222&, 333ccc'
            re.compile('\d+(?=[a-z]+)').findall(str)          # 前向界定 (?=exp) 找出连续的数字并且最后一个数字跟着至少一个a-z ['111', '333']
            re.compile(r"\d+(?![a-z]+)").findall(str)         # 前向否定界定 (?!exp)  找出连续数字，且最后一个数字后不能跟a-z  ['11', '222', '33']
            re.compile(r"(?<=[a-z])\d+").findall(str)         # 反向界定 (?<=exp) 逆序环视 找出连续的数字，且第一个数字前面是a-z  ['111', '222']
            re.compile(r"(?<![a-z])\d+").findall(str)         # 反向否定界定 (?<!exp) 否定逆序环视  找出连续的数字，且第一个数字前不能是a-z  ['11', '22', '333']
            re.compile(r"(?:\d+)").findall(str)               # 无捕获的匹配 (?:exp)
            s= 'Tom:9527 , Sharry:0003 '
            re.match( r'(?P<name>\w+):(?P<num>\d+)' , s).group(0)   # 捕获组 <num>第二个标签变量[9527] 获取 group("num") 等同 group(2)[9527], group(0)全部[Tom:9527]

        例子
            re.findall(r'a[be]c','123abc456eaec789')         # 返回匹配对象列表 ['abc', 'aec']
            re.findall("(.)12[34](..)",a)                    # 取出匹配括号中内容   a='qedqwe123dsf'
            re.search("(.)123",a ).group(1)                  # 搜索匹配的取第1个标签
            re.match("^(1|2) *(.*) *abc$", str).group(2)     # 取第二个标签
            re.match("^(1|2) *(.*) *abc$", str).groups()     # 取所有标签
            re.sub('[abc]','A','alex')                       # 替换
            for i in re.finditer(r'\d+',s):                  # 迭代
                print i.group(),i.span()                     #

        搜索网页中UNICODE格式的中文
            QueryAdd='http://www.anti-spam.org.cn/Rbl/Query/Result'
            Ip='222.129.184.52'
            s = requests.post(url=QueryAdd, data={'IP':Ip})
            re.findall(u'\u4e2d\u56fd', s.text, re.S)

    csv             [访问csv逗号分隔的文件]

        csv读配置文件

            192.168.1.5,web # 配置文件按逗号分割
            list = csv.reader(file('a.csv'))
            for line in list:
                print line              #  ['192.168.1.5', 'web']

        csv配合with读文件

            import csv
            with open('some.csv', 'rb') as f:
                reader = csv.reader(f)
                for row in reader:
                    print row

        csv配合with写文件

            import csv
            with open('some.csv', 'wb') as f:
                writer = csv.writer(f)
                writer.writerow(['Column1', 'Column2', 'Column3'])    # 写单行 列表
                writer.writerows([range(3) for i in range(5)])        # 写多行 列表套列表

    shutil          [提供高级文件访问功能]

        import shutil
        shutil.copyfile('data.db', 'archive.db')             # 拷贝文件
        shutil.move('/build/executables', 'installdir')      # 移动文件或目录

    dircache        [目录文件列表缓存]

        import dircache
        a = dircache.listdir('/data/xuesong')        # 列出目录下所有的文件和目录
        dircache.annotate('/data/xuesong', a)        # 判断指定目录下的是文件还是目录,目录则后面加/ 文件或不存在则不改变

    glob            [文件通配符]

        import glob
        glob.glob('*.py')    # 查找当前目录下py结尾的文件

    random          [随机模块]

        import random
        random.choice(['apple', 'pear', 'banana'])   # 随机取列表一个参数
        random.sample(xrange(100), 10)  # 不重复抽取10个
        random.random()                 # 随机浮点数
        random.randrange(6)             # 随机整数范围

    tempfile        [创建临时文件]

        import os
        import tempfile
         
        temp = tempfile.TemporaryFile()                # 定义一个临时文件对象
        try:
            temp.write('Some data')                    # 写入数据
            temp.writelines(['first\n', 'second\n'])   # 写入多行
            temp.seek(0)                               # 写入
             
            print temp.read()                          # 读取

            for line in temp:                          # 循环读取每一行
                print line.rstrip()
        finally:
            temp.close()                               # 关闭后删除临时文件



        # 创建临时目录
        import os
        import tempfile
         
        directory_name = tempfile.mkdtemp()
        print directory_name                            # 打印临时目录地址 /var/folders...
        # Clean up the directory yourself
        os.removedirs(directory_name)                   # 创建临时目录需要手动删除


        # 控制临时文件名
        import tempfile
         
        temp = tempfile.NamedTemporaryFile(suffix='_suffix',  prefix='prefix_',  dir='/tmp')
        try:
            print 'temp:', temp
            print 'temp.name:', temp.name
        finally:
            temp.close()

    email           [发送邮件]

        发送邮件内容

            #!/usr/bin/python
            #encoding:utf8
            # 导入 smtplib 和 MIMEText
            import smtplib
            from email.mime.text import MIMEText

            # 定义发送列表
            mailto_list=["272121935@qq.com","272121935@163.com"]

            # 设置服务器名称、用户名、密码以及邮件后缀
            mail_host = "smtp.163.com"
            mail_user = "mailuser"
            mail_pass = "password"
            mail_postfix="163.com"

            # 发送邮件函数
            def send_mail(to_list, sub):
                me = mail_user + "<"+mail_user+"@"+mail_postfix+">"
                fp = open('context.txt')
                msg = MIMEText(fp.read(),_charset="utf-8")
                fp.close()
                msg['Subject'] = sub
                msg['From'] = me
                msg['To'] = ";".join(to_list)
                try:
                    send_smtp = smtplib.SMTP()
                    send_smtp.connect(mail_host)
                    send_smtp.login(mail_user, mail_pass)
                    send_smtp.sendmail(me, to_list, msg.as_string())
                    send_smtp.close()
                    return True
                except Exception, e:
                    print str(e)
                    return False

            if send_mail(mailto_list,"标题"):
                print "测试成功"
            else:
                print "测试失败"

        发送附件

            #!/usr/bin/python
            #encoding:utf8
            import smtplib
            from email.mime.multipart import MIMEMultipart
            from email.mime.base import MIMEBase
            from email import encoders

            def send_mail(to_list, sub, filename):
                me = mail_user + "<"+mail_user+"@"+mail_postfix+">"
                msg = MIMEMultipart()
                msg['Subject'] = sub
                msg['From'] = me
                msg['To'] = ";".join(to_list)
                submsg = MIMEBase('application', 'x-xz')
                submsg.set_payload(open(filename,'rb').read())
                encoders.encode_base64(submsg)
                submsg.add_header('Content-Disposition', 'attachment', filename=filename)
                msg.attach(submsg)
                try:
                    send_smtp = smtplib.SMTP()
                    send_smtp.connect(mail_host)
                    send_smtp.login(mail_user, mail_pass)
                    send_smtp.sendmail(me, to_list, msg.as_string())
                    send_smtp.close()
                    return True
                except Exception, e:
                    print str(e)[1]
                    return False

            # 设置服务器名称、用户名、密码以及邮件后缀
            mail_host = "smtp.163.com"
            mail_user = "xuesong"
            mail_pass = "mailpasswd"
            mail_postfix = "163.com"
            mailto_list = ["272121935@qq.com","quanzhou722@163.com"]
            title = 'check'
            filename = 'file_check.html'
            if send_mail(mailto_list,title,filename):
                print "发送成功"
            else:
                print "发送失败"

    gzip            [解压缩gzip 删除原文件]

        #压缩gzip
        import gzip
        f_in = open('file.log', 'rb')
        f_out = gzip.open('file.log.gz', 'wb')
        f_out.writelines(f_in)
        f_out.close()
        f_in.close()

        #压缩gzip
        File = 'xuesong_18.log'
        g = gzip.GzipFile(filename="", mode='wb', compresslevel=9, fileobj=open((r'%s.gz' %File),'wb'))
        g.write(open(r'%s' %File).read())
        g.close()

        #解压gzip
        g = gzip.GzipFile(mode='rb', fileobj=open((r'xuesong_18.log.gz'),'rb'))
        open((r'xuesong_18.log'),'wb').write(g.read())

    tarfile         [归档压缩tar.gz 保留原文件]

        # 压缩tar.gz
        import os
        import tarfile
        tar = tarfile.open("/tmp/tartest.tar.gz","w:gz")   # 创建压缩包名
        for path,dir,files in os.walk("/tmp/tartest"):     # 递归文件目录
            for file in files:
                fullpath = os.path.join(path,file)
                tar.add(fullpath)                          # 创建压缩包
        tar.close()

        # 解压tar.gz
        import tarfile
        tar = tarfile.open("/tmp/tartest.tar.gz")
        #tar.extract("/tmp")                               # 全部解压到指定路径
        names = tar.getnames()                             # 包内文件名
        for name in names:
            tar.extract(name,path="./")                    # 解压指定文件
        tar.close()

    zipfile         [解压缩zip 最大2G]

        # 压缩zip
        import zipfile,os
        f = zipfile.ZipFile('filename.zip', 'w' ,zipfile.ZIP_DEFLATED)    # ZIP_STORE 为默认表不压缩. ZIP_DEFLATED 表压缩
        #f.write('file1.txt')                              # 将文件写入压缩包
        for path,dir,files in os.walk("tartest"):          # 递归压缩目录
            for file in files:
                f.write(os.path.join(path,file))           # 将文件逐个写入压缩包
        f.close()

        # 解压zip
        if zipfile.is_zipfile('filename.zip'):             # 判断一个文件是不是zip文件
            f = zipfile.ZipFile('filename.zip')
            for file in f.namelist():                      # 返回文件列表
                f.extract(file, r'/tmp/')                  # 解压指定文件
            #f.extractall()                                # 解压全部
            f.close()

    time/datetime   [时间]

        import time
        time.strftime('%Y%m%d_%H%M')         # 格式化时间
        time.time()                          # 时间戳[浮点]
        int(time.time())                     # 时间戳[整s]
        time.localtime()[1] - 1              # 上个月
        time.strftime('%Y-%m-%d_%X',time.localtime( time.time() ) )              # 时间戳转日期
        time.mktime(time.strptime('2012-03-28 06:53:40', '%Y-%m-%d %H:%M:%S'))   # 日期转时间戳

        判断输入时间格式是否正确

            #encoding:utf8
            import time
            while 1:
                atime=raw_input('输入格式如[14.05.13 13:00]:')
                try:
                    btime=time.mktime(time.strptime('%s:00' %atime, '%y.%m.%d %H:%M:%S'))
                    break
                except:
                    print '时间输入错误,请重新输入，格式如[14.05.13 13:00]'

        上一个月最后一天
            import datetime
            lastMonth=datetime.date(datetime.date.today().year,datetime.date.today().month,1)-datetime.timedelta(1)
            lastMonth.strftime("%Y/%m")

        前一天
            (datetime.datetime.now() + datetime.timedelta(days=-1) ).strftime('%Y%m%d')

        两日期相差天数

            import datetime
            d1 = datetime.datetime(2005, 2, 16)
            d2 = datetime.datetime(2004, 12, 31)
            (d1 - d2).days

        向后加10个小时

            import datetime
            d1 = datetime.datetime.now()
            d3 = d1 + datetime.timedelta(hours=10)
            d3.ctime()

    optparse        [解析参数及标准提示]

        import os, sys
        import time
        import optparse
        # python aaa.py -t file -p /etc/opt -o aaaaa

        def do_fiotest( type, path, output,):
            print type, path, output,

        def main():
            parser = optparse.OptionParser()
            parser.add_option('-t', '--type', dest = 'type', default = None, help = 'test type[file, device]')
            parser.add_option('-p', '--path', dest = 'path', default = None, help = 'test file path or device path')
            parser.add_option('-o', '--output', dest = 'output', default = None, help = 'result dir path')

            (o, a) = parser.parse_args()

            if None == o.type or None == o.path or None == o.output:
                print "No device or file or output dir"
                return -1

            if 'file' != o.type and 'device' != o.type:
                print "You need specify test type ['file' or 'device']"
                return -1

            do_fiotest(o.type, o.path, o.output)
            print "Test done!"


        if __name__ == '__main__':
            main()

    getopt          [解析参数]

        import sys,os
        import getopt

        try:
            options,argsErr = getopt.getopt(sys.argv[1:],"hu:c:",["help","user=","cmd="])    # 中间短参数，后面长参数对应. 不带:或=代表不带参数
        except getopt.GetoptError:
            print "Unknown parameters,More info with: %s -h" %(sys.argv[0])
            sys.exit(2)
        if argsErr != []:
            print "Unknown parameters,More info with: %s -h" %(sys.argv[0])
            sys.exit(2)

        for o,a in  options:
            if o in ("-h","--help"):
                print '''Usage: python te.py -u user -c "cmd -options" '''
                sys.exit(2)
            if o in ("-u","--user"):
                user = a
            if o in ("-c","--cmd"):
                cmd = a
        print user,cmd

    argparse        [命令行选项和参数解析库]

        import argparse
        parser = argparse.ArgumentParser( prog='usage_name', description='开头打印', epilog="结束打印")
        parser.add_argument('-f', '--foo', help='foo help', action='append')      # 可选参数,如使用此参数必须传值 action='store_true' 不加参数为True  action='append' 多个参数可叠加为列表
        parser.add_argument('--aa', type=int, default=42, help='aa!')             # type规定参数类型,default设置默认值
        parser.add_argument('bar', nargs='*', default=[1, 2, 3], help='BAR!')     # 位置参数 必须传递  nargs=2 需要传递2个参数
        parser.add_argument('args', nargs=argparse.REMAINDER)                     # 剩余参数收集到列表
        parser.print_help()                                                       # 打印使用帮助
        #parser.parse_args('BAR --foo FOO'.split())                               # 设置位置参数
        args = parser.parse_args()                                                # 全部的值
        parser.get_default('foo')                                                 # 获取

        python a.py --foo ww  --aa 40 xuesong 27                                  # 执行此脚本

    subprocess      [子进程管理]

        import subprocess
        s=subprocess.Popen('ls', shell=True, \
                stdin = subprocess.PIPE, stdout = subprocess.PIPE, stderr = subprocess.PIPE)
        print s.stdout.read()
        print s.stderr.read()
        print s.wait()         # 等待子进程结束。并返回执行状态 shell 0为正确

    base64          [编码]

        # 简单但容易被直接破解
        import base64
        s1 = base64.encodestring('hello world')
        s2 = base64.decodestring(s1)

    uu              [对文件uu编码]

        import uu
        uu.encode('in_file','out_file')       # 编码
        uu.decode('in_file','out_file')       # 解码

    binascii        [ascii和二进制编码转换]

    md5             [单向MD5加密]

        import md5
        m = md5.new('123456').hexdigest()

    hashlib         [hash算法库]

        import hashlib
        m = hashlib.md5()
        m.update("Nobody inspects")    # 使用update方法对字符串md5加密
        m.digest()                     # 加密后二进制结果
        m.hexdigest()                  # 加密后十进制结果
        hashlib.new("md5", "string").hexdigest()               # 对字符串加密
        hashlib.new("md5", open("file").read()).hexdigest()    # 查看文件MD5值

        hashlib.sha224("Nobody inspects the spammish repetition").hexdigest()       # 几种hash算法 sha1  sha224  sha256  sha384  ha512

    crypt           [单向加密]

        import crypt
        import random,string

        def getsalt(chars = string.letters+string.digits):
            return random.choice(chars)+random.choice(chars)
        salt = getsalt()
        print salt
        print crypt.crypt('bananas',salt)

    pycrypto        [加密]

        # https://github.com/dlitz/pycrypto
        SHA256  # 不可逆散列算法加密
            from Crypto.Hash import SHA256
            hash = SHA256.new()
            hash.update('message')
            hash.digest()

        AES     # 可逆加密,需要密钥
            from Crypto.Cipher import AES
            obj = AES.new('This is a key123', AES.MODE_CBC, 'This is an IV456')
            message = "The answer is no"
            ciphertext = obj.encrypt(message)
            ciphertext
            '\xd6\x83\x8dd!VT\x92\xaa`A\x05\xe0\x9b\x8b\xf1'
            obj2 = AES.new('This is a key123', AES.MODE_CBC, 'This is an IV456')
            obj2.decrypt(ciphertext)
            'The answer is no'

    rsa             [公钥加密算法]

        http://www.heikkitoivonen.net/m2crypto/api/M2Crypto.RSA.RSA-class.html

        pip install M2Crypto

        from M2Crypto import RSA,BIO                         # help(RSA)
        rsa = RSA.gen_key(2048, 'sha1')                      # 设置生成密钥为2048位,1024较不安全,默认算法sha1
        rsa.save_key('rsa.priv.pem', None )                  # 生成私钥pem文件
        rsa.save_pub_key('rsa.pub.pem')                      # 生成公钥pem文件
        rsa.save_key_bio()                                   # 私钥保存到pem格式的M2Crypto.BIO.BIO对象
        rsa.save_pub_key_bio()                               # 公钥保存到pem格式的M2Crypto.BIO.BIO对象
        priv=RSA.load_key('rsa.priv.pem')                    # 加载私钥文件
        pub=RSA.load_pub_key('rsa.pub.pem')                  # 加载公钥文件
        rsa.check_key()                                      # 检查key是否初始化
        pub_key.public_encrypt('data',RSA.pkcs1_padding)     # 公钥加密
        priv_key.private_decrypt('密文',RSA.pkcs1_padding)   # 私钥解密

        from M2Crypto import RSA,BIO

        rsa = RSA.gen_key(2048, 3, lambda *agr:None)
        pub_bio = BIO.MemoryBuffer()
        priv_bio = BIO.MemoryBuffer()

        rsa.save_pub_key_bio(pub_bio)
        rsa.save_key_bio(priv_bio, None)

        # print pub_bio.read_all()
        pub_key = RSA.load_pub_key_bio(pub_bio)
        priv_key = RSA.load_key_bio(priv_bio)

        message = 'i am luchanghong'

        encrypted = pub_key.public_encrypt(message, RSA.pkcs1_padding)        # 加密
        decrypted = priv_key.private_decrypt(encrypted, RSA.pkcs1_padding)    # 解密

        print decrypted

    getpass         [隐藏输入密码]

        import getpass
        passwd=getpass.getpass()

    string          [字符串类]

        import string
        string.ascii_letters   # a-zA-Z  ascii的不受语言系统环境变化
        string.ascii_lowercase # a-z
        string.letters         # a-zA-Z  受系统语言环境变化影响
        string.lowercase       # a-z
        string.uppercase       # A-Z大小
        string.digits          # 0-9
        string.printable       # 所有字符
        string.whitespace      # 空白字符

    paramiko        [ssh客户端]

        安装
            sudo apt-get install python-setuptools
            easy_install
            sudo apt-get install python-all-dev
            sudo apt-get install build-essential

        paramiko实例(账号密码登录执行命令)

            #!/usr/bin/python
            #ssh
            import paramiko
            import sys,os

            host = '10.152.15.200'
            user = 'peterli'
            password = '123456'

            s = paramiko.SSHClient()                                 # 绑定实例
            s.load_system_host_keys()                                # 加载本地HOST主机文件
            s.set_missing_host_key_policy(paramiko.AutoAddPolicy())  # 允许连接不在know_hosts文件中的主机
            s.connect(host,22,user,password,timeout=5)               # 连接远程主机
            while True:
                    cmd=raw_input('cmd:')
                    stdin,stdout,stderr = s.exec_command(cmd)        # 执行命令
                    cmd_result = stdout.read(),stderr.read()         # 读取命令结果
                    for line in cmd_result:
                            print line,
            s.close()

        paramiko实例(传送文件)

            #!/usr/bin/evn python
            import os
            import paramiko
            host='127.0.0.1'
            port=22
            username = 'peterli'
            password = '123456'
            ssh=paramiko.Transport((host,port))
            privatekeyfile = os.path.expanduser('~/.ssh/id_rsa')
            mykey = paramiko.RSAKey.from_private_key_file( os.path.expanduser('~/.ssh/id_rsa'))   # 加载key 不使用key可不加
            ssh.connect(username=username,password=password)           # 连接远程主机
            # 使用key把 password=password 换成 pkey=mykey
            sftp=paramiko.SFTPClient.from_transport(ssh)               # SFTP使用Transport通道
            sftp.get('/etc/passwd','pwd1')                             # 下载 两端都要指定文件名
            sftp.put('pwd','/tmp/pwd')                                 # 上传
            sftp.close()
            ssh.close()

        paramiko实例(密钥执行命令)

            #!/usr/bin/python
            #ssh
            import paramiko
            import sys,os
            host = '10.152.15.123'
            user = 'peterli'
            s = paramiko.SSHClient()
            s.load_system_host_keys()
            s.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            privatekeyfile = os.path.expanduser('~/.ssh/id_rsa')             # 定义key路径
            mykey = paramiko.RSAKey.from_private_key_file(privatekeyfile)
            # mykey=paramiko.DSSKey.from_private_key_file(privatekeyfile,password='061128')   # DSSKey方式 password是key的密码
            s.connect(host,22,user,pkey=mykey,timeout=5)
            cmd=raw_input('cmd:')
            stdin,stdout,stderr = s.exec_command(cmd)
            cmd_result = stdout.read(),stderr.read()
            for line in cmd_result:
                    print line,
            s.close()

        ssh并发(Pool控制最大并发)

            #!/usr/bin/env python
            #encoding:utf8
            #ssh_concurrent.py

            import multiprocessing
            import sys,os,time
            import paramiko

            def ssh_cmd(host,port,user,passwd,cmd):
                msg = "-----------Result:%s----------" % host

                s = paramiko.SSHClient()
                s.load_system_host_keys()
                s.set_missing_host_key_policy(paramiko.AutoAddPolicy())
                try:
                    s.connect(host,22,user,passwd,timeout=5)
                    stdin,stdout,stderr = s.exec_command(cmd)

                    cmd_result = stdout.read(),stderr.read()
                    print msg
                    for line in cmd_result:
                            print line,

                    s.close()
                except paramiko.AuthenticationException:
                    print msg
                    print 'AuthenticationException Failed'
                except paramiko.BadHostKeyException:
                    print msg
                    print "Bad host key"

            result = []
            p = multiprocessing.Pool(processes=20)
            cmd=raw_input('CMD:')
            f=open('serverlist.conf')
            list = f.readlines()
            f.close()
            for IP in list:
                print IP
                host=IP.split()[0]
                port=int(IP.split()[1])
                user=IP.split()[2]
                passwd=IP.split()[3]
                result.append(p.apply_async(ssh_cmd,(host,port,user,passwd,cmd)))

            p.close()

            for res in result:
                res.get(timeout=35)

        ssh并发(取文件状态并发送邮件)

            #!/usr/bin/python
            #encoding:utf8
            #config file: ip.list

            import paramiko
            import multiprocessing
            import smtplib
            import sys,os,time,datetime,socket,re
            from email.mime.text import MIMEText

            # 配置文件(IP列表)
            Conf = 'ip.list'
            user_name = 'peterli'
            user_pwd = 'passwd'
            port = 22
            PATH = '/home/peterli/'

            # 设置服务器名称、用户名、密码以及邮件后缀
            mail_host = "smtp.163.com"
            mail_user = "xuesong"
            mail_pass = "mailpasswd"
            mail_postfix = "163.com"
            mailto_list = ["272121935@qq.com","quanzhou722@163.com"]
            title = 'file check'

            DATE1=(datetime.datetime.now() + datetime.timedelta(days=-1) ).strftime('%Y%m%d')
            file_path = '%s%s' %(PATH,DATE1)

            def Ssh_Cmd(file_path,host_ip,user_name,user_pwd,port=22):

                s = paramiko.SSHClient()
                s.load_system_host_keys()
                s.set_missing_host_key_policy(paramiko.AutoAddPolicy())

                try:
                    s.connect(hostname=host_ip,port=port,username=user_name,password=user_pwd)
                    stdin,stdout,stderr = s.exec_command('stat %s' %file_path)
                    stat_result = '%s%s' %(stdout.read(),stderr.read())
                    if stat_result.find('No such file or directory') == -1:
                        file_status = 'OK\t'
                        stdin,stdout,stderr = s.exec_command('du -sh %s' %file_path)
                        cmd1_result = '%s_%s' %(stat_result.split()[32],stat_result.split()[33].split('.')[0])
                        cmd2_result = ('%s%s' %(stdout.read(),stderr.read())).split()[0]
                    else:
                        file_status = '未生成\t'
                        cmd1_result = 'null'
                        cmd2_result = 'null'
                    q.put(['Login successful'])
                    s.close()
                except socket.error:
                    file_status = '主机或端口错误'
                    cmd1_result = '-'
                    cmd2_result = '-'
                except paramiko.AuthenticationException:
                    file_status = '用户或密码错误'
                    cmd1_result = '-'
                    cmd2_result = '-'
                except paramiko.BadHostKeyException:
                    file_status = 'Bad host key'
                    cmd1_result = '-'
                    cmd2_result = '-'
                except:
                    file_status = 'ssh异常'
                    cmd1_result = '-'
                    cmd2_result = '-'
                r.put('%s\t-\t%s\t%s\t%s\t%s\n' %(time.strftime('%Y-%m-%d_%H:%M'),host_ip,file_status,cmd2_result,cmd1_result))

            def Concurrent(Conf,file_path,user_name,user_pwd,port):
                # 执行总计
                total = 0
                # 读取配置文件
                f=open(Conf)
                list = f.readlines()
                f.close()
                # 并发执行
                process_list = []
                log_file = file('file_check.log', 'w')
                log_file.write('检查时间\t\t业务\tIP\t\t文件状态\t大小\t生成时间\n')
                for host_info in list:
                    # 判断配置文件中注释行跳过
                    if host_info.startswith('#'):
                        continue
                    # 取变量,其中任意变量未取到就跳过执行
                    try:
                        host_ip=host_info.split()[0].strip()
                        #user_name=host_info.split()[1]
                        #user_pwd=host_info.split()[2]
                    except:
                        log_file.write('Profile error: %s\n' %(host_info))
                        continue
                    #try:
                    #    port=int(host_info.split()[3])
                    #except:
                    #    port=22
                    total +=1
                    p = multiprocessing.Process(target=Ssh_Cmd,args=(file_path,host_ip,user_name,user_pwd,port))
                    p.start()
                    process_list.append(p)
                for j in process_list:
                    j.join()
                for j in process_list:
                    log_file.write(r.get())

                successful = q.qsize()
                log_file.write('执行完毕。 总执行:%s 登录成功:%s 登录失败:%s\n' %(total,successful,total - successful))
                log_file.flush()
                log_file.close()

            def send_mail(to_list, sub):
                me = mail_user + "<"+mail_user+"@"+mail_postfix+">"
                fp = open('file_check.log')
                msg = MIMEText(fp.read(),_charset="utf-8")
                fp.close()
                msg['Subject'] = sub
                msg['From'] = me
                msg['To'] = ";".join(to_list)
                try:
                    send_smtp = smtplib.SMTP()
                    send_smtp.connect(mail_host)
                    send_smtp.login(mail_user, mail_pass)
                    send_smtp.sendmail(me, to_list, msg.as_string())
                    send_smtp.close()
                    return True
                except Exception, e:
                    print str(e)[1]
                    return False

            if __name__ == '__main__':
                q = multiprocessing.Queue()
                r = multiprocessing.Queue()
                Concurrent(Conf,file_path,user_name,user_pwd,port)
                if send_mail(mailto_list,title):
                    print "发送成功"
                else:
                    print "发送失败"

    pysnmp          [snmp客户端]

        #!/usr/bin/python
        from pysnmp.entity.rfc3413.oneliner import cmdgen

        cg = cmdgen.CommandGenerator()

        # 注意IP 端口 组默认public  oid值
        varBinds = cg.getCmd( cmdgen.CommunityData('any-agent', 'public',0 ), cmdgen.UdpTransportTarget(('10.10.76.42', 161)),    (1,3,6,1,4,1,2021,10,1,3,1), )

        print varBinds[3][0][1]

    PDB             [单步调试]

        # 很多程序因为被try了,看不到具体报错的地方, 用这个模块就很清晰可以看到错误的位置
        # http://docs.python.org/2/library/pdb.html

        (Pdb) h              # 帮助
        # 断点设置
        (Pdb)b 10            # 断点设置在本py的第10行
        (Pdb)b ots.py:20     # 断点设置到 ots.py第20行
        (Pdb)b               # 查看断点编号
        (Pdb)cl 2            # 删除第2个断点

        # 运行
        (Pdb)n               # 单步运行
        (Pdb)s               # 细点运行 也就是会下到，方法
        (Pdb)c               # 跳到下个断点
        # 查看
        (Pdb)p param         # 查看当前 变量值
        (Pdb)l               # 查看运行到某处代码
        (Pdb)a               # 查看全部栈内变量
        !a = 100             # 直接赋值

        python -m pdb myscript.py   # 直接对脚本单步调试

        # 在程序里面加单步调试
        import pdb
        def tt():
            pdb.set_trace()
            for i in range(1, 5):
                print i
        >>> tt()
        > <stdin>(3)tt()
        (Pdb) n              #这里支持 n p c 而已

    pstats          [源码性能分析测试]

        import profile
        import pstats

        profile.run("run()", "prof.txt")
        p = pstats.Stats("prof.txt")
        p.sort_stats("time").print_stats()

    apscheduler     [任务调度]

        # 安装   pip install apscheduler
        # 例子   https://bitbucket.org/agronholm/apscheduler/src/e6298f953a68/tests/?at=master

        scheduler.start()                                                   # 启动任务
        job = scheduler.add_job(myfunc, 'interval', minutes=2)              # 添加任务
        job.remove()                                                        # 删除任务
        scheduler.add_job(myfunc, 'interval', minutes=2, id='my_job_id')    # 添加任务
        scheduler.remove_job('my_job_id')                                   # 删除任务
        job.modify(max_instances=6, name='Alternate name')                  # 修改工作
        scheduler.shutdown()                                                # 关闭调度
        scheduler.shutdown(wait=False)                                      # 关闭调度  不等待
        # 暂停
        apscheduler.job.Job.pause()
        apscheduler.schedulers.base.BaseScheduler.pause_job()
        # 恢复
        apscheduler.job.Job.resume()
        apscheduler.schedulers.base.BaseScheduler.resume_job()

        定时任务
            from pytz import utc
            from apscheduler.schedulers.background import BackgroundScheduler
            from apscheduler.executors.pool import ThreadPoolExecutor, ProcessPoolExecutor
            import time

            executors = {
                'default': ThreadPoolExecutor(20),
                'processpool': ProcessPoolExecutor(5)
            }
            job_defaults = {
                'coalesce': False,
                'max_instances': 3
            }
            scheduler = BackgroundScheduler( executors=executors, job_defaults=job_defaults, timezone=utc)

            def myfunc():
                print 'test'

            scheduler.add_job(myfunc, 'interval', minutes=1, id='myworkid')
            scheduler.start()

            try:
                while True:
                    time.sleep(2)
                    # add_job
            except (KeyboardInterrupt, SystemExit):
                scheduler.shutdown()

    logging         [日志记录]

        # 日志级别大小关系为: critical > error > warning > info > debug > notset  也可自定义日志级别
        import logging
        logging.debug('debug')                 # 默认日志级别为 warning ,故debug日志不做打印
        logging.warning('warning')             # 达到默认日志级别为WARNING,打印到屏幕 warning
        logging.basicConfig                    # 通过logging.basicConfig函数对日志的输出格式及方式做相关配置
            # basicConfig 相关参数帮助
            filename               # 指定日志文件名
            filemode               # 和file函数意义相同，指定日志文件的打开模式，'w'或'a'
            datefmt                # 指定时间格式，同time.strftime()
            level                  # 设置日志级别，默认为logging.WARNING
            stream                 # 指定将日志的输出流，可以指定输出到sys.stderr,sys.stdout或者文件，默认输出到sys.stderr，当stream和filename同时指定时，stream被忽略
            format                 # 指定输出的格式和内容，format可以输出很多有用信息，如上例所示:
                %(levelno)s        # 打印日志级别的数值
                %(levelname)s      # 打印日志级别名称
                %(pathname)s       # 打印当前执行程序的路径，其实就是sys.argv[0]
                %(filename)s       # 打印当前执行程序名
                %(funcName)s       # 打印日志的当前函数
                %(lineno)d         # 打印日志的当前行号
                %(asctime)s        # 打印日志的时间
                %(thread)d         # 打印线程ID
                %(threadName)s     # 打印线程名称
                %(process)d        # 打印进程ID
                %(message)s        # 打印日志信息

        logging.basicConfig(level=logging.DEBUG,
                        format='%(asctime)s %(filename)s[line:%(lineno)d] %(levelname)s %(message)s',
                        datefmt='%a, %d %b %Y %H:%M:%S',
                        filename='myapp.log',
                        filemode='w')
        # 日志级别warning或高于warning的会写入文件 myapp.log 中

        logging.config.fileConfig("logger.conf")        # 加载配置文件
        logger = logging.getLogger("example02")         # 使用已定义的日志记录器
        logger.conf                                     # 配置文件
            ###############################################
            [loggers]
            keys=root,example01,example02    # 设置三种日志记录器
            [logger_root]                    # 针对单一种设置
            level=DEBUG
            handlers=hand01,hand02
            [logger_example01]
            handlers=hand01,hand02           # 使用2中处理方式 应该是根据不同级别区分的
            qualname=example01
            propagate=0
            [logger_example02]
            handlers=hand01,hand03
            qualname=example02
            propagate=0
            ###############################################
            [handlers]                      # 不同的处理方式
            keys=hand01,hand02,hand03       # 三种方式的名字
            [handler_hand01]                # 第一种方式配置
            class=StreamHandler             # 发送错误信息到流
            level=INFO                      # 日志级别
            formatter=form02                # 日志的格式方式
            args=(sys.stderr,)
            [handler_hand02]
            class=FileHandler               # FileHandler写入磁盘文件
            level=DEBUG
            formatter=form01
            args=('myapp.log', 'a')         # 追加到日志文件
            [handler_hand03]
            class=handlers.RotatingFileHandler
            level=INFO
            formatter=form02
            args=('myapp.log', 'a', 10*1024*1024, 5)    # 追加日志并切割日志
            ###############################################
            [formatters]                                # 针对不同处理日志方式设置具体的日志格式
            keys=form01,form02
            [formatter_form01]
            format=%(asctime)s %(filename)s[line:%(lineno)d] %(levelname)s %(message)s    # 日志列
            datefmt=%a, %d %b %Y %H:%M:%S               # 时间格式
            [formatter_form02]
            format=%(name)-12s: %(levelname)-8s %(message)s
            datefmt=

    ConfigParser    [配置解析]

        写入配置文件

            import ConfigParser
            config = ConfigParser.RawConfigParser()
            config.add_section('Section1')                          # 添加配置文件的块 [name]
            config.set('Section1', 'an_int', '15')                  # 针对块设置配置参数和值
            config.set('Section1', 'a_bool', 'true')
            config.set('Section1', 'a_float', '3.1415')
            config.set('Section1', 'baz', 'fun')
            config.set('Section1', 'bar', 'Python')
            config.set('Section1', 'foo', '%(bar)s is %(baz)s!')
            with open('example.cfg', 'wb') as configfile:           # 指定配置文件路径
                config.write(configfile)                            # 写入配置文件

        读取配置文件

            import ConfigParser
            config = ConfigParser.RawConfigParser()
            config.read('example.cfg')                              # 读取配置文件
            a_float = config.getfloat('Section1', 'a_float')        # 获取配置文件参数对应的浮点值,如参数值类型不对则报ValueError
            an_int = config.getint('Section1', 'an_int')            # 获取配置文件参数对应的整数值,可直接进行计算
            print a_float + an_int
            if config.getboolean('Section1', 'a_bool'):             # 根据配置文件参数值是否为真
                print config.get('Section1', 'foo')                 # 再获取依赖的配置参数 get获取后值为字符串
            print config.get('Section1', 'foo', 0)                  # 获取配置文件参数的同时加载变量[配置文件中的参数]
            print config.get('Section1', 'foo', 1)                  # 获取配置文件参数 原始值不做任何改动 不使用变量
            config.remove_option('Section1', 'bar')                 # 删除读取配置文件获取bar的值
            config.remove_option('Section1', 'baz')
            print config.get('Section1', 'foo', 0, {'bar': 'str1', 'baz': 'str1'})    # 读取配置参数的同时设置变量的值


        import ConfigParser
        import io

        sample_config = """
        [mysqld]
        user = mysql
        pid-file = /var/run/mysqld/mysqld.pid
        skip-external-locking
        old_passwords = 1
        skip-bdb
        skip-innodb
        """
        config = ConfigParser.RawConfigParser(allow_no_value=True)
        config.readfp(io.BytesIO(sample_config))
        config.get("mysqld", "user")

    ftplib          [ftp客户端]

        from ftplib import FTP
        ftp = FTP('ftp.debian.org')     # 连接ftp地址   FTP(host,port,timeout)
        ftp.login()                     # 使用默认anonymous登录  login(user,passwd)
        ftp.cwd('debian')               # 切换到目录debian
        ftp.retrlines('LIST')           # 打印目录列表
        ftp.retrbinary('RETR README', open('README', 'wb').write)       # 下载文件写到本地
        ftp.delete('filename')          # 删除ftp中文件
        ftp.mkd('dirname')              # 在ftp上创建目录
        ftp.size('filename')            # 查看文件大小
        ftp.quit()

    difflib         [对象比较]

        import difflib
        s1 = ['bacon\n', 'eggs\n', 'ham\n', 'guido\n']
        s2 = ['python\n', 'eggy\n', 'hamster\n', 'guido\n']
        for line in difflib.context_diff(s1, s2, fromfile='txt-s1', tofile='txt-s2'):    # 两字列表比较差异
            sys.stdout.write(line)

        difflib.get_close_matches('appel', ['ape', 'apple', 'peach', 'puppy'])           # 模糊匹配 匹配列表与字符串相似的值，越相似越靠前

    heapq           [优先队列算法]

        from heapq import *
        h = []
        heappush(h, (5, 'write code'))          # 放入队列
        heappush(h, (7, 'release product'))
        heappush(h, (1, 'write spec'))
        heappush(h, (3, 'create tests'))
        heappop(h)                              # 从队列取出 第一次是1

        from heapq import *
        def heapsort(iterable):
            h = []
            for value in iterable:
                heappush(h, value)
            return [heappop(h) for i in range(len(h))]

        heapsort([1, 3, 5, 7, 9, 2, 4, 6, 8, 0])

    linecache       [随机读取指定行]

        import linecache
        linecache.getline('/etc/passwd', 4)

    json            [数据交换格式]

        #!/usr/bin/python
        import json

        #json file temp.json
        #{ "name":"00_sample_case1", "description":"an example."}

        f = file("temp.json");
        s = json.load(f)        # 直接读取json文件
        print s
        f.close

        d = {"a":1}
        j=json.dumps(d)  # 字典转json
        json.loads(j)    # json转字典

        s = json.loads('{"name":"test", "type":{"name":"seq", "parameter":["1", "2"]}}')
        print type(s)    # dic
        print s
        print s.keys()
        print s["type"]["parameter"][1]

        json.dumps({'ret':'cmd_ret0', 'out':'cmd_ret1'}, separators=(',', ':'))    # 紧凑的json格式,去掉空格

    filecmp         [文件目录比较]

        filecmp.cmp('/etc/passwd', '/etc/passwd')     # 比较两文件是否一致

        # 比较两目录下文件是否一致
        from filecmp import dircmp
        def print_diff_files(dcmp):
            for name in dcmp.diff_files:
                print "diff_file %s found in %s and %s" % (name, dcmp.left, dcmp.right)
            for sub_dcmp in dcmp.subdirs.values():
                print_diff_files(sub_dcmp)

        dcmp = dircmp('dir1', 'dir2')
        print_diff_files(dcmp)

    errno           [符号错误码]

        https://docs.python.org/2/library/errno.html#module-errno

        import errno

        try:
            fp = open("no.such.file")
        except IOError, (error, message):
            if error == errno.ENOENT:
                print "no such file"
            elif error == errno.EPERM:
                print "permission denied"
            else:
                print message

    Exceptions      [标准异常类]

        # 详见官网 不需要导入
        https://docs.python.org/2/library/exceptions.html#module-exceptions

    ctypes          [调用C的动态库]

        提供和C语言兼容的数据类型,也可调用C的动态库

        http://blog.csdn.net/linda1000/article/details/12623527
        http://www.cnblogs.com/wuchang/archive/2010/04/04/1704456.html
        http://www.ibm.com/developerworks/cn/linux/l-cn-pythonandc/

    daemon          [守护进程]

        daemon.py

            # 创建守护进程的模块
            #!/usr/bin/env python

            import sys, os, time, atexit
            from signal import SIGTERM

            class Daemon:
                """
                A generic daemon class.

                Usage: subclass the Daemon class and override the run() method
                """
                def __init__(self, pidfile='nbMon.pid', stdin='/dev/null', stdout='nbMon.log', stderr='nbMon.log'):
                    self.stdin = stdin
                    self.stdout = stdout
                    self.stderr = stderr
                    self.pidfile = pidfile

                def daemonize(self):
                    """
                    do the UNIX double-fork magic, see Stevens' "Advanced
                    Programming in the UNIX Environment" for details (ISBN 0201563177)
                    http://www.erlenstar.demon.co.uk/unix/faq_2.html#SEC16
                    """
                    try:
                        pid = os.fork()
                        if pid > 0:
                            # exit first parent
                            sys.exit(0)
                    except OSError, e:
                        sys.stderr.write("fork #1 failed: %d (%s)\n" % (e.errno, e.strerror))
                        sys.exit(1)

                    # decouple from parent environment
                    #os.chdir("/")
                    os.setsid()
                    os.umask(0)

                    # do second fork
                    try:
                        pid = os.fork()
                        if pid > 0:
                            # exit from second parent
                            sys.exit(0)
                    except OSError, e:
                        sys.stderr.write("fork #2 failed: %d (%s)\n" % (e.errno, e.strerror))
                        sys.exit(1)

                    # redirect standard file descriptors
                    sys.stdout.flush()
                    sys.stderr.flush()
                    si = file(self.stdin, 'r')
                    so = file(self.stdout, 'a+')
                    se = file(self.stderr, 'a+', 0)
                    os.dup2(si.fileno(), sys.stdin.fileno())
                    os.dup2(so.fileno(), sys.stdout.fileno())
                    os.dup2(se.fileno(), sys.stderr.fileno())

                    # write pidfile
                    atexit.register(self.delpid)
                    pid = str(os.getpid())
                    file(self.pidfile,'w+').write("%s\n" % pid)

                def delpid(self):
                    os.remove(self.pidfile)

                def start(self):
                    """
                    Start the daemon
                    """
                    # Check for a pidfile to see if the daemon already runs
                    try:
                        pf = file(self.pidfile,'r')
                        pid = int(pf.read().strip())
                        pf.close()
                    except IOError:
                        pid = None

                    if pid:
                        message = "pidfile %s already exist. Daemon already running?\n"
                        sys.stderr.write(message % self.pidfile)
                        sys.exit(1)

                    # Start the daemon
                    self.daemonize()
                    self.run()

                def stop(self):
                    """
                    Stop the daemon
                    """
                    # Get the pid from the pidfile
                    try:
                        pf = file(self.pidfile,'r')
                        pid = int(pf.read().strip())
                        pf.close()
                    except IOError:
                        pid = None

                    if not pid:
                        message = "pidfile %s does not exist. Daemon not running?\n"
                        sys.stderr.write(message % self.pidfile)
                        return # not an error in a restart

                    # Try killing the daemon process
                    try:
                        while 1:
                            os.kill(pid, SIGTERM)
                            time.sleep(0.1)
                    except OSError, err:
                        err = str(err)
                        if err.find("No such process") > 0:
                            if os.path.exists(self.pidfile):
                                os.remove(self.pidfile)
                        else:
                            print str(err)
                            sys.exit(1)

                def restart(self):
                    """
                    Restart the daemon
                    """
                    self.stop()
                    self.start()

                def run(self):
                    """
                    You should override this method when you subclass Daemon. It will be called after the process has been
                    daemonized by start() or restart().
                    """

        run_daemon.py

            # 启动脚本,倒入需要后台启动的模块,继承Daemon类,覆盖run函数
            # 启动方式  python run_daemon.py start

            #!/usr/bin/env python
            import Queue
            import threading
            import sys, time
            import urllib2
            import json
            import framework
            from moniItems import mon
            from daemon import Daemon

            class MyDaemon(Daemon):
                def run(self):
                    print 'start'
                    framework.startTh()
                    print 'stop2'

            if __name__ == "__main__":
                daemon = MyDaemon()
                if len(sys.argv) == 2:
                    if 'start' == sys.argv[1]:
                        daemon.start()
                    elif 'stop' == sys.argv[1]:
                        daemon.stop()
                    elif 'restart' == sys.argv[1]:
                        daemon.restart()
                    else:
                        print "Unknown command"
                        sys.exit(2)
                    sys.exit(0)
                else:
                    print "usage: %s start|stop|restart" % sys.argv[0]
                    sys.exit(2)

    psutil          [获取系统信息]

        pip install psutil                     # 安装

        import psutil
        dir(psutil)
        psutil.boot_time()                     # 开机时间
        psutil.virtual_memory()                # 内存详细信息
        psutil.virtual_memory().total          # 内存总大小
        psutil.disk_partitions()               # 获取磁盘信息
        psutil.disk_io_counters()              # 磁盘IO信息
        psutil.net_io_counters()               # 获取网络IO信息

        psutil.pids()                          # 返回所有进程PID
        psutil.Process(PID)                    # 获取进程信息
        psutil.Process(PID).name()             # 指定进程的进程名
        psutil.Process(PID).exe()              # 进程的路径
        psutil.Process(PID).cwd()              # 进程工作路径
        psutil.Process(PID).status()           # 进程状态
        psutil.Process(PID).create_time()      # 进程创建时间
        psutil.Process(PID).memory_percent()   # 进程内存使用率
        psutil.Process(PID).io_counters()      # 进程IO信息
        psutil.Process(PID).num_threads()      # 进程线程数

    watchdog        [监视文件实时写入]

        https://pypi.python.org/pypi/watchdog
        pip install watchdog

        import sys
        import time
        import logging
        from watchdog.observers import Observer
        from watchdog.events import LoggingEventHandler

        if __name__ == "__main__":
            logging.basicConfig(level=logging.INFO,
                                format='%(asctime)s - %(message)s',
                                datefmt='%Y-%m-%d %H:%M:%S')
            path = sys.argv[1] if len(sys.argv) > 1 else '.'
            event_handler = LoggingEventHandler()
            observer = Observer()
            observer.schedule(event_handler, path, recursive=True)
            observer.start()
            try:
                while True:
                    time.sleep(1)
            except KeyboardInterrupt:
                observer.stop()
            observer.join()

    yaml            [标记语言]

        pip  install  pyyaml

        import yaml

        a = yaml.load("""
        name: Vorlin Laruknuzum
        sex: Male
        class: Priest
        title: Acolyte
        hp: [32, 71]
        sp: [1, 13]
        gold: 423
        inventory:
        - a Holy Book of Prayers (Words of Wisdom)
        - an Azure Potion of Cure Light Wounds
        - a Silver Wand of Wonder
        """)

        print a['inventory'][1]     # 字典
        print yaml.dump(a)          # 把字典生成yaml文件
        yaml.load_all               # 生成迭代器

        print yaml.dump({'name': "The Cloak 'Colluin'", 'depth': 5, 'rarity': 45,
            'weight': 10, 'cost': 50000, 'flags': ['INT', 'WIS', 'SPEED', 'STEALTH']})

    itertools       [迭代功能函数]

        import itertools
        # 全排序
        print list(itertools.permutations(['a', 'b', 'c', 'd'],4))

        # 无限迭代
        ns = itertools.count(1)
        for n in ns:
            print n

        # 指定次数循环
        ns = itertools.repeat('A', 10)
        for n in ns:
            print n

3 socket

    socket.gethostname()     # 获取主机名
    from socket import *     # 避免 socket.socket()
    s=socket()
    s.bind()                 # 绑定地址到套接字
    s.listen()               # 开始TCP监听
    s.accept()               # 被动接受TCP客户端连接，等待连接的到来
    s.connect()              # 主动初始化TCP服务器连接
    s.connect_ex()           # connect()函数的扩展版本，出错时返回出错码，而不是跑出异常
    s.recv()                 # 接收TCP数据
    s.send()                 # 发送TCP数据
    s.sendall()              # 完整发送TCP数据
    s.recvfrom()             # 接收UDP数据
    s.sendto()               # 发送UDP数据
    s.getpeername()          # 连接到当前套接字的远端的地址(TCP连接)
    s.getsockname()          # 当前套接字的地址
    s.getsockopt()           # 返回指定套接字的参数
    s.setsockopt()           # 设置指定套接字的参数
    s.close()                # 关闭套接字
    s.setblocking()          # 设置套接字的阻塞与非阻塞模式
    s.settimeout()           # 设置阻塞套接字操作的超时时间
    s.gettimeout()           # 得到阻塞套接字操作的超时时间
    s.makefile()             # 创建一个与该套接字关联的文件对象
    s.fileno()               # 套接字获取对应的文件描述符fd

    socket.AF_UNIX           # 只能够用于单一的Unix系统进程间通信
    socket.AF_INET           # 服务器之间网络通信
    socket.AF_INET6          # IPv6

    socket.SOCK_STREAM       # 流式socket , for TCP
    socket.SOCK_DGRAM        # 数据报式socket , for UDP
    socket.SOCK_RAW          # 原始套接字，普通的套接字无法处理ICMP、IGMP等网络报文，而SOCK_RAW可以；其次，SOCK_RAW也可以处理特殊的IPv4报文；此外，利用原始套接字，可以通过IP_HDRINCL套接字选项由用户构造IP头。

    socket.SOCK_RDM          # 是一种可靠的UDP形式，即保证交付数据报但不保证顺序。SOCK_RAM用来提供对原始协议的低级访问，在需要执行某些特殊操作时使用，如发送ICMP报文。SOCK_RAM通常仅限于高级用户或管理员运行的程序使用。

    socket.SOCK_SEQPACKET    # 可靠的连续数据包服务

    socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)   # 关闭server后马上释放端口,避免被TIME_WAIT占用

    select          [IO多路复用的机制]

        # select每次遍历都需要把fd集合从用户态拷贝到内核态,开销较大,受系统限制最大1024
        select.select(rlist, wlist, xlist[, timeout])
        # poll和select很像 通过一个pollfd数组向内核传递需要关注的事件,没有描述符1024限制
        select.poll()
        # 创建epoll句柄,注册监听事件,通过回调函数等待事件产生,不做主动扫描,整个过程对fd只做一次拷贝.打开最大文件数后,不受限制,1GB内存大约是10万链接
        select.epoll([sizehint=-1])

        select.epoll

            EPOLLIN                # 监听可读事件
            EPOLLET                # 高速边缘触发模式,即触发后不会再次触发直到新接收数据
            EPOLLOUT               # 监听写事件

            epoll.poll([timeout=-1[, maxevents=-1]]) # 等待事件,未指定超时时间[毫秒]则为一直阻塞等待
            epoll.register(fd,EPOLLIN)               # 向epoll句柄中注册,新来socket链接,监听可读事件
            epoll.modify(fd, EPOLLET | EPOLLOUT)     # 改变监听事件为边缘触发,监听写事件
            epoll.fileno()                           # 通过链接对象得到fd
            epoll.unregister(fd)                     # 取消fd监听事件

    SocketServer

        #!/usr/bin/python
        #server.py
        import SocketServer
        import os
        class MyTCP(SocketServer.BaseRequestHandler):
            def handle(self):
                # 应该已经封装好了 不需要这层while了 可能会引起大量 close_wait
                while True:
                    self.data=self.request.recv(1024).strip()
                    if self.data == 'quit' or not self.data:break

                    cmd=os.popen(self.data).read()
                    if cmd == '':cmd= self.data + ': Command not found'
                    self.request.sendall(cmd)
        if __name__ == '__main__':
            HOST,PORT = '10.0.0.119',50007
            server = SocketServer.ThreadingTCPServer((HOST,PORT),MyTCP)
            server.serve_forever()

    SocketClient

        #!/usr/bin/python
        #client.py
        import socket

        HOST='10.0.0.119'
        PORT=50007
        s=socket.socket(socket.AF_INET,socket.SOCK_STREAM)
        s.connect((HOST,PORT))

        while True:
            while True:
                cmd=raw_input('CMD:').strip()
                if cmd != '':break
            s.sendall(cmd)
            data=s.recv(1024).split('\n')
            print 'cmd:'
            for line in data:print line
        s.close()

    ftp

        ftpserver

            #!/usr/bin/python
            #ftpserver.py

            import SocketServer
            import os
            import cPickle
            import md5
            from time import sleep

            def filer(file1):
                try:
                    f = file(file1,'rb')
                    return cPickle.load(f)
                except IOError:
                    return {}
                except EOFError:
                    return {}
                f.close()

            def filew(file1,content):
                f = file(file1,'wb')
                cPickle.dump(content,f)
                f.close()

            class MyTCP(SocketServer.BaseRequestHandler):
                def handle(self):
                    i = 0
                    while i<3:
                        user=self.request.recv(1024).strip()
                        userinfo=filer('user.pkl')
                        if userinfo.has_key(user.split()[0]):
                            if md5.new(user.split()[1]).hexdigest() == userinfo[user.split()[0]]:
                                results='login successful'
                                self.request.sendall(results)
                                login='successful'
                                break
                            else:
                                i = i + 1
                                results='Error:password not correct'
                                self.request.sendall(results)
                                continue
                        else:
                            i = i + 1
                            results='Error:password not correct'
                            self.request.sendall(results)
                            continue
                        break
                    else:
                        results = 'Error:Wrong password too many times'
                        self.request.sendall(results)
                        login='failure'
                    home_path = os.popen('pwd').read().strip() + '/' + user.split()[0]
                    current_path = '/'
                    print home_path
                    while True:
                        if login == 'failure':
                            break
                        print 'home_path:%s=current_path:%s' %(home_path,current_path)
                        cmd=self.request.recv(1024).strip()
                        print cmd
                        if cmd == 'quit':
                            break
                        elif cmd == 'dir':
                            list=os.listdir('%s%s' %(home_path,current_path))
                            if list:
                                dirlist,filelist = '',''
                                for i in list:
                                    if os.path.isdir('%s%s%s' %(home_path,current_path,i)):
                                        dirlist = dirlist + '\033[32m' + i + '\033[m\t'
                                    else:
                                        filelist = filelist + i + '\t'
                                results = dirlist + filelist
                            else:
                                results = '\033[31mnot find\033[m'
                            self.request.sendall(results)
                        elif cmd == 'pdir':
                            self.request.sendall(current_path)
                        elif cmd.split()[0] == 'mdir':
                            if cmd.split()[1].isalnum():
                                tmppath='%s%s%s' %(home_path,current_path,cmd.split()[1])
                                os.makedirs(tmppath)
                                self.request.sendall('\033[32mcreating successful\033[m')
                            else:
                                self.request.sendall('\033[31mcreate failure\033[m')
                        elif cmd.split()[0] == 'cdir':
                            if cmd.split()[1] == '/':
                                tmppath='%s%s' %(home_path,cmd.split()[1])
                                if os.path.isdir(tmppath):
                                    current_path = cmd.split()[1]
                                    self.request.sendall(current_path)
                                else:
                                    self.request.sendall('\033[31mnot_directory\033[m')
                            elif cmd.split()[1].startswith('/'):
                                tmppath='%s%s' %(home_path,cmd.split()[1])
                                if os.path.isdir(tmppath):
                                    current_path = cmd.split()[1] + '/'
                                    self.request.sendall(current_path)
                                else:
                                    self.request.sendall('\033[31mnot_directory\033[m')
                            else:
                                tmppath='%s%s%s' %(home_path,current_path,cmd.split()[1])
                                if os.path.isdir(tmppath):
                                    current_path = current_path + cmd.split()[1] + '/'
                                    self.request.sendall(current_path)
                                else:
                                    self.request.sendall('\033[31mnot_directory\033[m')
                        elif cmd.split()[0] == 'get':
                            if os.path.isfile('%s%s%s' %(home_path,current_path,cmd.split()[1])):
                                f = file('%s%s%s' %(home_path,current_path,cmd.split()[1]),'rb')
                                self.request.sendall('ready_file')
                                sleep(0.5)
                                self.request.send(f.read())
                                f.close()
                                sleep(0.5)
                            elif os.path.isdir('%s%s%s' %(home_path,current_path,cmd.split()[1])):
                                self.request.sendall('ready_dir')
                                sleep(0.5)
                                for dirpath in os.walk('%s%s%s' %(home_path,current_path,cmd.split()[1])):
                                    dir=dirpath[0].replace('%s%s' %(home_path,current_path),'',1)
                                    self.request.sendall(dir)
                                    sleep(0.5)
                                    for filename in dirpath[2]:
                                        self.request.sendall(filename)
                                        sleep(0.5)
                                        f = file('%s/%s' %(dirpath[0],filename),'rb')
                                        self.request.send(f.read())
                                        f.close()
                                        sleep(0.5)
                                        self.request.sendall('file_get_done')
                                        sleep(0.5)
                                    else:
                                        self.request.sendall('dir_get_done')
                                    sleep(0.5)
                            else:
                                self.request.sendall('get_failure')
                                continue
                            self.request.sendall('get_done')

                        elif cmd.split()[0] == 'send':
                            if os.path.exists('%s%s%s' %(home_path,current_path,cmd.split()[1])):
                                self.request.sendall('existing')
                                action=self.request.recv(1024)
                                if action == 'cancel':
                                    continue
                            self.request.sendall('ready')
                            msg=self.request.recv(1024)
                            if msg == 'ready_file':
                                f = file('%s%s%s' %(home_path,current_path,cmd.split()[1]),'wb')
                                while True:
                                    data=self.request.recv(1024)
                                    if data == 'file_send_done':break
                                    f.write(data)
                                f.close()

                            elif msg == 'ready_dir':
                                os.system('mkdir -p %s%s%s' %(home_path,current_path,cmd.split()[1]))
                                while True:
                                    dir=self.request.recv(1024)
                                    if dir == 'get_done':break
                                    os.system('mkdir -p %s%s%s' %(home_path,current_path,dir))
                                    while True:
                                        filename=self.request.recv(1024)
                                        if filename == 'dir_send_done':break
                                        f = file('%s%s%s/%s' %(home_path,current_path,dir,filename),'wb')
                                        while True:
                                            data=self.request.recv(1024)
                                            if data == 'file_send_done':break
                                            f.write(data)
                                        f.close()
                                        self.request.sendall('%s/%s\t\033[32mfile_done\033[m' %(dir,filename))
                                    self.request.sendall('%s\t\033[32mdir_done\033[m' %(dir))
                            elif msg == 'unknown_file':
                                continue

                        else:
                            results = cmd.split()[0] + ': Command not found'
                            self.request.sendall(results)

            if __name__ == '__main__':
                HOST,PORT = '10.152.14.85',50007
                server = SocketServer.ThreadingTCPServer((HOST,PORT),MyTCP)
                server.serve_forever()

        ftpmanage

            #!/usr/bin/python
            #manage_ftp.py
            import cPickle
            import sys
            import md5
            import os
            import getpass

            def filer(file1):
                try:
                    f = file(file1,'rb')
                    return cPickle.load(f)
                except IOError:
                    return {}
                except EOFError:
                    return {}
                f.close()

            def filew(file1,content):
                f = file(file1,'wb')
                cPickle.dump(content,f)
                f.close()

            while True:
                print '''
                1.add user
                2.del user
                3.change password
                4.query user
                0.exit
                '''
                i = raw_input(':').strip()
                userinfo=filer('user.pkl')
                if i == '':
                    continue
                elif i == '1':
                    while True:
                        user=raw_input('user name:').strip()
                        if user.isalnum():
                            i = 0
                            while i<3:
                                passwd=getpass.getpass('passwd:').strip()
                                if passwd == '':
                                    continue
                                else:
                                    passwd1=getpass.getpass('Confirm password:').strip()
                                    if passwd == passwd1:
                                        mpasswd = md5.new(passwd).hexdigest()
                                        userinfo[user] = mpasswd
                                        os.system('mkdir -p %s' %user)
                                        print '%s creating successful ' %user
                                        break
                                    else:
                                        print "Passwords don't match "
                                        i = i + 1
                                        continue
                            else:
                                print 'Too many wrong'
                                continue
                            break
                        else:
                            print 'user not legal'
                            continue
                elif i == '2':
                    user=raw_input('user name:').strip()
                    if userinfo.has_key(user):
                        del userinfo[user]
                        print 'Delete users successfully'
                    else:
                        print 'user not exist'
                        continue
                elif i == '3':
                    user=raw_input('user name:').strip()
                    if userinfo.has_key(user):
                        i = 0
                        while i<3:
                            passwd=getpass.getpass('passwd:').strip()
                            if passwd == '':
                                continue
                            else:
                                passwd1=getpass.getpass('Confirm password:').strip()
                                if passwd == passwd1:
                                    mpasswd = md5.new(passwd).hexdigest()
                                    userinfo[user] = mpasswd
                                    print '%s password is changed' %user
                                    break
                                else:
                                    print "Passwords don't match "
                                    i = i + 1
                                    continue
                        else:
                            print 'Too many wrong'
                            continue
                    else:
                        print 'user not exist'
                        continue
                elif i == '4':
                    print userinfo.keys()
                elif i == '0':
                    sys.exit()
                else:
                    print 'select error'
                    continue
                filew('user.pkl',content=userinfo)

        ftpclient

            #!/usr/bin/python
            #ftpclient.py

            import socket
            import os
            import getpass
            from time import sleep

            HOST='10.152.14.85'
            PORT=50007
            s=socket.socket(socket.AF_INET,socket.SOCK_STREAM)
            s.connect((HOST,PORT))

            while True:
                user = raw_input('user:').strip()
                if user.isalnum():
                    while True:
                        passwd = getpass.getpass('passwd:').strip()
                        s.sendall(user + ' ' + passwd)
                        servercmd=s.recv(1024)
                        if servercmd == 'login successful':
                            print '\033[32m%s\033[m' %servercmd
                            break
                        else:
                            print servercmd

                    while True:
                        cmd=raw_input('FTP>').strip()
                        if cmd == '':
                            continue
                        if cmd.split()[0] == 'get':
                            if cmd == 'get':continue
                            for i in cmd.split()[1:]:
                                if os.path.exists(i):
                                    confirm = raw_input("\033[31mPlease confirm whether the cover %s(Y/N):\033[m" %(i)).upper().startswith('Y')
                                    if not confirm:
                                        print '%s cancel' %i
                                        continue
                                s.sendall('get ' + i)
                                servercmd=s.recv(1024)
                                if servercmd == 'inexistence':
                                    print '%s \t\033[32minexistence\033[m' %i
                                    continue
                                elif servercmd == 'ready_file':
                                    f = file(i,'wb')
                                    while True:
                                        data=s.recv(1024)
                                        if data == 'get_done':break
                                        f.write(data)
                                    f.close()
                                    print '%s \t\033[32mfile_done\033[m' %(i)
                                elif servercmd == 'ready_dir':
                                    try:
                                        os.makedirs(i)
                                    except:
                                        pass
                                    while True:
                                        serverdir=s.recv(1024)
                                        if serverdir == 'get_done':break
                                        os.system('mkdir -p %s' %serverdir)
                                        print '%s \t\033[32mdir_done\033[m' %(serverdir)
                                        while True:
                                            serverfile=s.recv(1024)
                                            if serverfile == 'dir_get_done':break
                                            f = file('%s/%s' %(serverdir,serverfile),'wb')
                                            while True:
                                                data=s.recv(1024)
                                                if data == 'file_get_done':break
                                                f.write(data)
                                            f.close()
                                            print '%s/%s \t\033[32mfile_done\033[m' %(serverdir,serverfile)

                        elif cmd.split()[0] == 'send':

                            if cmd == 'send':continue
                            for i in cmd.split()[1:]:
                                if not os.path.exists(i):
                                    print '%s\t\033[31minexistence\033[m' %i
                                    continue

                                s.sendall('send ' + i)
                                servercmd=s.recv(1024)
                                if servercmd == 'existing':
                                    confirm = raw_input("\033[31mPlease confirm whether the cover %s(Y/N):\033[m" %(i)).upper().startswith('Y')
                                    if confirm:
                                        s.sendall('cover')
                                        servercmd=s.recv(1024)
                                    else:
                                        s.sendall('cancel')
                                        print '%s\tcancel' %i
                                        continue

                                if os.path.isfile(i):
                                    s.sendall('ready_file')
                                    sleep(0.5)
                                    f = file(i,'rb')
                                    s.send(f.read())
                                    sleep(0.5)
                                    s.sendall('file_send_done')
                                    print '%s\t\033[32mfile done\033[m' %(cmd.split()[1])
                                    f.close()
                                elif os.path.isdir(i):
                                    s.sendall('ready_dir')
                                    sleep(0.5)
                                    for dirpath in os.walk(i):
                                        dir=dirpath[0].replace('%s/' %os.popen('pwd').read().strip(),'',1)
                                        s.sendall(dir)
                                        sleep(0.5)
                                        for filename in dirpath[2]:
                                            s.sendall(filename)
                                            sleep(0.5)
                                            f = file('%s/%s' %(dirpath[0],filename),'rb')
                                            s.send(f.read())
                                            f.close()
                                            sleep(0.5)
                                            s.sendall('file_send_done')
                                            msg=s.recv(1024)
                                            print msg

                                        else:
                                            s.sendall('dir_send_done')
                                            msg=s.recv(1024)
                                            print msg

                                else:
                                    s.sendall('unknown_file')
                                    print '%s\t\033[31munknown type\033[m' %i
                                    continue
                                sleep(0.5)
                                s.sendall('get_done')

                        elif cmd.split()[0] == 'cdir':
                            if cmd == 'cdir':continue
                            s.sendall(cmd)
                            data=s.recv(1024)
                            print data
                            continue
                        elif cmd == 'ls':
                            list=os.popen(cmd).read().strip().split('\n')
                            if list:
                                dirlist,filelist = '',''
                                for i in list:
                                    if os.path.isdir(i):
                                        dirlist = dirlist + '\033[32m' + i + '\033[m\t'
                                    else:
                                        filelist = filelist + i + '\t'
                                results = dirlist + filelist
                            else:
                                results = '\033[31mnot find\033[m'
                            print results
                            continue
                        elif cmd == 'pwd':
                            os.system(cmd)
                        elif cmd.split()[0] == 'cd':
                            try:
                                os.chdir(cmd.split()[1])
                            except:
                                print '\033[31mcd failure\033[m'
                        elif cmd == 'dir':
                            s.sendall(cmd)
                            data=s.recv(1024)
                            print data
                            continue
                        elif cmd == 'pdir':
                            s.sendall(cmd)
                            data=s.recv(1024)
                            print data
                            continue
                        elif cmd.split()[0] == 'mdir':
                            if cmd == 'mdir':continue
                            s.sendall(cmd)
                            data=s.recv(1024)
                            print data
                            continue
                        elif cmd.split()[0] == 'help':
                            print '''
                get [file] [dir]
                send [file] [dir]

                dir
                mdir
                cdir
                pdir

                pwd
                md
                cd
                ls

                help
                quit
                '''
                            continue
                        elif cmd == 'quit':
                            break
                        else:
                            print '\033[31m%s: Command not found,Please see the "help"\033[m' %cmd
                else:
                    continue
                break
            s.close()

    扫描主机开放端口
        #!/usr/bin/env python

        import socket

        def check_server(address,port):
            s=socket.socket()
            try:
                s.connect((address,port))
                return True
            except socket.error,e:
                return False

        if __name__=='__main__':
            from optparse import OptionParser
            parser=OptionParser()
            parser.add_option("-a","--address",dest="address",default='localhost',help="Address for server",metavar="ADDRESS")
            parser.add_option("-s","--start",dest="start_port",type="int",default=1,help="start port",metavar="SPORT")
            parser.add_option("-e","--end",dest="end_port",type="int",default=1,help="end port",metavar="EPORT")
            (options,args)=parser.parse_args()
            print 'options: %s, args: %s' % (options, args)
            port=options.start_port
            while(port<=options.end_port):
                check = check_server(options.address, port)
                if (check):
                    print 'Port  %s is on' % port
                port=port+1

    zmq [网络通讯库]

        # https://github.com/zeromq/pyzmq
        # pip install pyzmq
        # ZMQ是一个开源的、跨语言的、非常简洁的、非常高性能、非常灵活的网络通讯库

        服务端程序
            import zmq
            context = zmq.Context()
            socket = context.socket(zmq.REP)
            socket.bind("tcp://127.0.0.1:1234")   # 提供传输协议  INPROC  IPC  MULTICAST  TCP

            while True :
                msg = socket.recv()
                socket.send(msg)

        客户端端程序
            import zmq
            context = zmq.Context()
            socket = context.socket(zmq.REQ)
            socket.connect("tcp://127.0.0.1:1234")
            # socket.connect("tcp://127.0.0.1:6000")    # 设置2个可以均衡负载请求到2个监听的server
            msg_send = "xxx"socket.send(msg_send)
            print "Send:", msg_send
            msg_recv = socket.recv()
            print "Receive:", msg_recv

    epoll
        https://docs.python.org/2/library/select.html    # python官网

        epoll短链接server
            # 原文  http://my.oschina.net/moooofly/blog/147297
            # 此代码还有改进地方，在接收数据和发送数据都是阻塞死循环处理，必须等待全部接收完毕才会继续操作
            server端代码：

                #!/usr/bin/python
                #-*- coding:utf-8 -*-

                import socket, logging
                import select, errno

                logger = logging.getLogger("network-server")

                def InitLog():
                    logger.setLevel(logging.DEBUG)

                    fh = logging.FileHandler("network-server.log")
                    fh.setLevel(logging.DEBUG)
                    ch = logging.StreamHandler()
                    ch.setLevel(logging.ERROR)

                    formatter = logging.Formatter("%(asctime)s - %(name)s - %(levelname)s - %(message)s")
                    ch.setFormatter(formatter)
                    fh.setFormatter(formatter)

                    logger.addHandler(fh)
                    logger.addHandler(ch)

                if __name__ == "__main__":
                    InitLog()

                    try:
                        # 创建 TCP socket 作为监听 socket
                        listen_fd = socket.socket(socket.AF_INET, socket.SOCK_STREAM, 0)
                    except socket.error, msg:
                        logger.error("create socket failed")

                    try:
                        # 设置 SO_REUSEADDR 选项
                        listen_fd.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
                    except socket.error, msg:
                        logger.error("setsocketopt SO_REUSEADDR failed")

                    try:
                        # 进行 bind -- 此处未指定 ip 地址，即 bind 了全部网卡 ip 上
                        listen_fd.bind(('', 2003))
                    except socket.error, msg:
                        logger.error("bind failed")

                    try:
                        # 设置 listen 的 backlog 数
                        listen_fd.listen(10)
                    except socket.error, msg:
                        logger.error(msg)

                    try:
                        # 创建 epoll 句柄
                        epoll_fd = select.epoll()
                        # 向 epoll 句柄中注册 监听 socket 的 可读 事件
                        epoll_fd.register(listen_fd.fileno(), select.EPOLLIN)
                    except select.error, msg:
                        logger.error(msg)

                    connections = {}
                    addresses = {}
                    datalist = {}
                    while True:
                        # epoll 进行 fd 扫描的地方 -- 未指定超时时间则为阻塞等待
                        epoll_list = epoll_fd.poll()

                        for fd, events in epoll_list:
                            # 若为监听 fd 被激活
                            if fd == listen_fd.fileno():
                                # 进行 accept -- 获得连接上来 client 的 ip 和 port，以及 socket 句柄
                                conn, addr = listen_fd.accept()
                                logger.debug("accept connection from %s, %d, fd = %d" % (addr[0], addr[1], conn.fileno()))
                                # 将连接 socket 设置为 非阻塞
                                conn.setblocking(0)
                                # 向 epoll 句柄中注册 连接 socket 的 可读 事件
                                epoll_fd.register(conn.fileno(), select.EPOLLIN | select.EPOLLET)
                                # 将 conn 和 addr 信息分别保存起来
                                connections[conn.fileno()] = conn
                                addresses[conn.fileno()] = addr
                            elif select.EPOLLIN & events:
                                # 有 可读 事件激活
                                datas = ''
                                while True:
                                    try:
                                        # 从激活 fd 上 recv 10 字节数据
                                        data = connections[fd].recv(10)
                                        # 若当前没有接收到数据，并且之前的累计数据也没有
                                        if not data and not datas:
                                            # 从 epoll 句柄中移除该 连接 fd
                                            epoll_fd.unregister(fd)
                                            # server 侧主动关闭该 连接 fd
                                            connections[fd].close()
                                            logger.debug("%s, %d closed" % (addresses[fd][0], addresses[fd][1]))
                                            break
                                        else:
                                            # 将接收到的数据拼接保存在 datas 中
                                            datas += data
                                    except socket.error, msg:
                                        # 在 非阻塞 socket 上进行 recv 需要处理 读穿 的情况
                                        # 这里实际上是利用 读穿 出 异常 的方式跳到这里进行后续处理
                                        if msg.errno == errno.EAGAIN:
                                            logger.debug("%s receive %s" % (fd, datas))
                                            # 将已接收数据保存起来
                                            datalist[fd] = datas
                                            # 更新 epoll 句柄中连接d 注册事件为 可写
                                            epoll_fd.modify(fd, select.EPOLLET | select.EPOLLOUT)
                                            break
                                        else:
                                            # 出错处理
                                            epoll_fd.unregister(fd)
                                            connections[fd].close()
                                            logger.error(msg)
                                            break
                            elif select.EPOLLHUP & events:
                                # 有 HUP 事件激活
                                epoll_fd.unregister(fd)
                                connections[fd].close()
                                logger.debug("%s, %d closed" % (addresses[fd][0], addresses[fd][1]))
                            elif select.EPOLLOUT & events:
                                # 有 可写 事件激活
                                sendLen = 0
                                # 通过 while 循环确保将 buf 中的数据全部发送出去
                                while True:
                                    # 将之前收到的数据发回 client -- 通过 sendLen 来控制发送位置
                                    sendLen += connections[fd].send(datalist[fd][sendLen:])
                                    # 在全部发送完毕后退出 while 循环
                                    if sendLen == len(datalist[fd]):
                                        break
                                # 更新 epoll 句柄中连接 fd 注册事件为 可读
                                epoll_fd.modify(fd, select.EPOLLIN | select.EPOLLET)
                            else:
                                # 其他 epoll 事件不进行处理
                                continue

            client 端代码

                import socket
                import time
                import logging

                logger = logging.getLogger("network-client")
                logger.setLevel(logging.DEBUG)

                fh = logging.FileHandler("network-client.log")
                fh.setLevel(logging.DEBUG)
                ch = logging.StreamHandler()
                ch.setLevel(logging.ERROR)

                formatter = logging.Formatter("%(asctime)s - %(name)s - %(levelname)s - %(message)s")
                ch.setFormatter(formatter)
                fh.setFormatter(formatter)

                logger.addHandler(fh)
                logger.addHandler(ch)

                if __name__ == "__main__":
                    try:
                        connFd = socket.socket(socket.AF_INET, socket.SOCK_STREAM, 0)
                    except socket.error, msg:
                        logger.error(msg)

                    try:
                        connFd.connect(("127.0.0.1", 2003))
                        logger.debug("connect to network server success")
                    except socket.error,msg:
                        logger.error(msg)

                    for i in range(1, 11):
                        data = "The Number is %d" % i
                        if connFd.send(data) != len(data):
                            logger.error("send data to network server failed")
                            break
                        readData = connFd.recv(1024)
                        print readData
                        time.sleep(1)

                    connFd.close()

4 mysql

    # yum install mysql-devel python-tools gcc openssl-devel
    pip install MySQL-python
    # yum install python-MySQLdb MySQL-python

    help(MySQLdb.connections.Connection)      # 查看链接参数

    conn=MySQLdb.connect(host='localhost',user='root',passwd='123456',db='fortress',port=3306)    # 定义连接
    #conn=MySQLdb.connect(unix_socket='/var/run/mysqld/mysqld.sock',user='root',passwd='123456')   # 使用socket文件链接
    conn.autocommit(True)                                        # 自动提交
    cur=conn.cursor()                                            # 定义游标
    conn.select_db('fortress')                                   # 选择数据库
    sqlcmd = 'insert into user(name,age) value(%s,%s)'           # 定义sql命令
    cur.executemany(sqlcmd,[('aa',1),('bb',2),('cc',3)])         # 插入多条值
    cur.execute('delete from user where id=20')                  # 删除一条记录
    cur.execute("update user set name='a' where id=20")          # 更细数据
    sqlresult = cur.fetchall()                                   # 接收全部返回结果
    conn.commit()                                                # 提交
    cur.close()                                                  # 关闭游标
    conn.close()                                                 # 关闭连接

    import MySQLdb
    def mydb(dbcmdlist):
        try:
            conn=MySQLdb.connect(host='localhost',user='root',passwd='123456',db='fortress',port=3306)
            conn.autocommit(True)
            cur=conn.cursor()

            cur.execute('create database if not exists fortress;')  # 创建数据库
            conn.select_db('fortress')                              # 选择数据库
            cur.execute('drop table if exists log;')                # 删除表
            cur.execute('CREATE TABLE log ( id BIGINT(20) NOT NULL AUTO_INCREMENT, loginuser VARCHAR(50) DEFAULT NULL, remoteip VARCHAR(50) DEFAULT NULL, PRIMARY KEY (id) );')  # 创建表

            result=[]
            for dbcmd in dbcmdlist:
                cur.execute(dbcmd)           # 执行sql
                sqlresult = cur.fetchall()   # 接收全部返回结果
                result.append(sqlresult)
            conn.commit()                    # 提交
            cur.close()
            conn.close()
            return result
        except MySQLdb.Error,e:
            print 'mysql error msg: ',e
    sqlcmd=[]
    sqlcmd.append("insert into log (loginuser,remoteip)values('%s','%s');" %(loginuser,remoteip))
    mydb(sqlcmd)

    sqlcmd=[]
    sqlcmd.append("select * from log;")
    result = mydb(sqlcmd)
    for i in result[0]:
        print i

5 处理信号

    信号的概念

        信号(signal): 进程之间通讯的方式，是一种软件中断。一个进程一旦接收到信号就会打断原来的程序执行流程来处理信号。
        发送信号一般有两种原因:
            1(被动式)  内核检测到一个系统事件.例如子进程退出会像父进程发送SIGCHLD信号.键盘按下control+c会发送SIGINT信号
            2(主动式)  通过系统调用kill来向指定进程发送信号
        操作系统规定了进程收到信号以后的默认行为，可以通过绑定信号处理函数来修改进程收到信号以后的行为，有两个信号是不可更改的 SIGTOP 和 SIGKILL
        如果一个进程收到一个SIGUSR1信号，然后执行信号绑定函数，第二个SIGUSR2信号又来了，第一个信号没有被处理完毕的话，第二个信号就会丢弃。
        进程结束信号 SIGTERM 和 SIGKILL 的区别:  SIGTERM 比较友好，进程能捕捉这个信号，根据您的需要来关闭程序。在关闭程序之前，您可以结束打开的记录文件和完成正在做的任务。在某些情况下，假如进程正在进行作业而且不能中断，那么进程可以忽略这个SIGTERM信号。

    常见信号
        kill -l      # 查看linux提供的信号

        SIGHUP  1          A     # 终端挂起或者控制进程终止
        SIGINT  2          A     # 键盘终端进程(如control+c)
        SIGQUIT 3          C     # 键盘的退出键被按下
        SIGILL  4          C     # 非法指令
        SIGABRT 6          C     # 由abort(3)发出的退出指令
        SIGFPE  8          C     # 浮点异常
        SIGKILL 9          AEF   # Kill信号  立刻停止
        SIGSEGV 11         C     # 无效的内存引用
        SIGPIPE 13         A     # 管道破裂: 写一个没有读端口的管道
        SIGALRM 14         A     # 闹钟信号 由alarm(2)发出的信号
        SIGTERM 15         A     # 终止信号,可让程序安全退出 kill -15
        SIGUSR1 30,10,16   A     # 用户自定义信号1
        SIGUSR2 31,12,17   A     # 用户自定义信号2
        SIGCHLD 20,17,18   B     # 子进程结束自动向父进程发送SIGCHLD信号
        SIGCONT 19,18,25         # 进程继续（曾被停止的进程）
        SIGSTOP 17,19,23   DEF   # 终止进程
        SIGTSTP 18,20,24   D     # 控制终端（tty）上按下停止键
        SIGTTIN 21,21,26   D     # 后台进程企图从控制终端读
        SIGTTOU 22,22,27   D     # 后台进程企图从控制终端写

        缺省处理动作一项中的字母含义如下:
            A  缺省的动作是终止进程
            B  缺省的动作是忽略此信号，将该信号丢弃，不做处理
            C  缺省的动作是终止进程并进行内核映像转储(dump core),内核映像转储是指将进程数据在内存的映像和进程在内核结构中的部分内容以一定格式转储到文件系统，并且进程退出执行，这样做的好处是为程序员提供了方便，使得他们可以得到进程当时执行时的数据值，允许他们确定转储的原因，并且可以调试他们的程序。
            D  缺省的动作是停止进程，进入停止状况以后还能重新进行下去，一般是在调试的过程中（例如ptrace系统调用）
            E  信号不能被捕获
            F  信号不能被忽略

    Python提供的信号
        import signal
        dir(signal)
        ['NSIG', 'SIGABRT', 'SIGALRM', 'SIGBUS', 'SIGCHLD', 'SIGCLD', 'SIGCONT', 'SIGFPE', 'SIGHUP', 'SIGILL', 'SIGINT', 'SIGIO', 'SIGIOT', 'SIGKILL', 'SIGPIPE', 'SIGPOLL', 'SIGPROF', 'SIGPWR', 'SIGQUIT', 'SIGRTMAX', 'SIGRTMIN', 'SIGSEGV', 'SIGSTOP', 'SIGSYS', 'SIGTERM', 'SIGTRAP', 'SIGTSTP', 'SIGTTIN', 'SIGTTOU', 'SIGURG', 'SIGUSR1', 'SIGUSR2', 'SIGVTALRM', 'SIGWINCH', 'SIGXCPU', 'SIGXFSZ', 'SIG_DFL', 'SIG_IGN', '__doc__', '__name__', 'alarm', 'default_int_handler', 'getsignal', 'pause', 'signal']

    绑定信号处理函数
        #encoding:utf8
        import os,signal
        from time import sleep
        def onsignal_term(a,b):
            print 'SIGTERM'      # kill -15
        signal.signal(signal.SIGTERM,onsignal_term)     # 接收信号,执行相应函数

        def onsignal_usr1(a,b):
            print 'SIGUSR1'      # kill -10
        signal.signal(signal.SIGUSR1,onsignal_usr1)

        while 1:
            print 'ID',os.getpid()
            sleep(10)

    通过另外一个进程发送信号
        import os,signal
        os.kill(16175,signal.SIGTERM)    # 发送信号，16175是绑定信号处理函数的进程pid，需要自行修改
        os.kill(16175,signal.SIGUSR1)

    父进程接收子进程结束发送的SIGCHLD信号
        #encoding:utf8
        import os,signal
        from time import sleep

        def onsigchld(a,b):
            print '收到子进程结束信号'
        signal.signal(signal.SIGCHLD,onsigchld)

        pid = os.fork()                # 创建一个子进程,复制父进程所有资源操作
        if pid == 0:                   # 通过判断子进程os.fork()是否等于0,分别同时执行父进程与子进程操作
           print '我是子进程,pid是',os.getpid()
           sleep(2)
        else:
            print '我是父进程,pid是',os.getpid()
            os.wait()      # 等待子进程结束

    接收信号的程序，另外一端使用多线程向这个进程发送信号，会遗漏一些信号
        #encoding:utf8
        import os
        import signal
        from time import sleep
        import Queue
        QCOUNT = Queue.Queue()  # 初始化队列
        def onsigchld(a,b):
            '''收到信号后向队列中插入一个数字1'''
            print '收到SIGUSR1信号'
            sleep(1)
            QCOUNT.put(1)       # 向队列中写入
        signal.signal(signal.SIGUSR1,onsigchld)   # 绑定信号处理函数
        while 1:
            print '我的pid是',os.getpid()
            print '现在队列中元素的个数是',QCOUNT.qsize()
            sleep(2)

    多线程发信号端的程序
        #encoding:utf8
        import threading
        import os
        import signal
        def sendusr1():
            print '发送信号'
            os.kill(17788, signal.SIGUSR1)     # 这里的进程id需要写前一个程序实际运行的pid
        WORKER = []
        for i in range(1, 7):                  # 开启6个线程
            threadinstance = threading.Thread(target = sendusr1)
            WORKER.append(threadinstance)
        for i in WORKER:
            i.start()
        for i in WORKER:
            i.join()
        print '主线程完成'

6 缓存数据库

    python使用memcache

        easy_install python-memcached   # 安装(python2.7+)
        import memcache
        mc = memcache.Client(['10.152.14.85:12000'],debug=True)    # 也可以使用socket直接连接IP端口
        mc.set('name','luo',60)
        mc.get('name')
        mc.delete('name1')

        # 豆瓣的python-memcache模块，大于1M自动切割 性能是纯python的3倍+
        https://code.google.com/p/python-libmemcached/

        保存数据

            set(key,value,timeout)      # 把key映射到value，timeout指的是什么时候这个映射失效
            add(key,value,timeout)      # 仅当存储空间中不存在键相同的数据时才保存
            replace(key,value,timeout)  # 仅当存储空间中存在键相同的数据时才保存

        获取数据

            get(key)                    # 返回key所指向的value
            get_multi(key1,key2,key3)   # 可以非同步地同时取得多个键值， 比循环调用get快数十倍

    python使用mongodb

        # 新版本
        http://api.mongodb.org/python/2.7.2/tutorial.html
        http://api.mongodb.org/python/current/examples/custom_type.html

        easy_install pymongo      # 安装

        import pymongo

        cl = pymongo.MongoClient("127.0.0.1", 27017)
        db = cl.ops             # 选择库
        db.name                 # 查看库名
        db.collection_names()   # 查看所有文档
        db.project              # 选择文档
        db.project.insert({'name':'live','group':'a'})
        db.project.insert({'name':'news','group':'b'})
        db.project.find_one({'group':'a'})
        for post in db.project.find():
           print post['name']
        db.project.remove()

    python使用redis

        https://pypi.python.org/pypi/redis                  # redis的python官网
        pip install redis  OR easy_install redis            # 安装
        http://redis.readthedocs.org/en/latest/index.html   # redis命令详解
        http://redis.readthedocs.org/en/2.4/index.html

        import redis
        rds = redis.Redis(host=host, port=port, password=passwd, socket_timeout=10,db=0)
        rds.info()                           # redis信息
        rds.set(key, value)                  # 将值value关联到key
        rds.get(key)                         # 取key值
        rds.del(key1,key2)                   # 删除key
        rds.rename(key,new_key2)             # 将key改名 存在覆盖
        rds.seten(key,value)                 # 将值value关联到key,如果key存在不做任何动作
        rds.setex(key, value, 10800)         # 将值value关联到key,并设置key的过期时间
        rds.mset()                           # 同时设置一个或多个key-value对  如果key存在则覆盖
        rds.msetnx()                         # 同时设置一个或多个key-value对  如果有key存在则失败
        rds.mget(key1, key2, key3)           # 取多个key值   不存在返回nil
        rds.expire(key seconds)              # 设置key的过期时间
        rds.persist(key)                     # 移除key的过期时间
        rds.ttl(key)                         # 查看超时时间 -1为不过期
        rds.sadd(key,value1)                 # 将value1加入集合中  集合不重复
        rds.smembers(key)                    # 返回key中所有成员
        rds.scard(key)                       # 集合中元素的数量
        rds.srandmember(key)                 # 对集合随机返回一个元素 而不对集合改动  当key不存在或key是空集时，返回nil
        rds.sinter(key1,key2)                # 两个集合的交集
        rds.sdiff(key1,key2)                 # 两个集合的差集
        rds.sismember(key,value)             # 判断value元素是否是集合key的成员 1存在 0不存在
        rds.lpush(key,value1)                # 将value1加入列表中  从左到右
        rds.lpop(key,value1)                 # 移除并返回列表key的头元素
        rds.llen(key)                        # 返回列表长度
        rds.sort(key)                        # 对列表、集合、有序集合排序[大列表排序非常影响性能，甚至把redis拖死]
        rds.append(key,value)                # 字符串拼接为新的value
        rds.ltrim(key, 0, -10)               # 保留指定区间内的元素，不在都被删除 0第一个 -1最后一个
        rds.incr(key , amount=1)             # 计数加1 默认1或请先设置key的数值
        rds.decr(key)                        # 计数减1 请先设置key的数值
        rds.save()                           # 保存数据

    python使用kestrel队列

        # pykestrel
        import kestrel

        q = kestrel.Client(servers=['127.0.0.1:22133'],queue='test_queue')
        q.add('some test job')
        job = q.get()    # 从队列读取工作
        job = q.peek()   # 读取下一份工作
        # 读取一组工作
        while True:
            job = q.next(timeout=10) # 完成工作并获取下一个工作，如果没有工作，则等待10秒
            if job is not None:
                try:
                    # 流程工作
                except:
                    q.abort() # 标记失败工作

        q.finish()  # 完成最后工作
        q.close()   # 关闭连接

        kestrel状态检查
            # kestrel支持memcache协议客户端
            #!/usr/local/bin/python
            # 10.13.81.125 22133  10000

            import memcache
            import sys
            import traceback

            ip="%s:%s" % (sys.argv[1],sys.argv[2])
            try:
                mc = memcache.Client([ip,])
                st=mc.get_stats()
            except:
                print "kestrel connection exception"
                sys.exit(2)

            if st:
                for s in st[0][1].keys():
                    if s.startswith('queue_') and s.endswith('_mem_items'):
                        num = int(st[0][1][s])
                        if num > int(sys.argv[3]):
                            print "%s block to %s" %(s[6:-6],num)
                            sys.exit(2)
                print "kestrel ok!"
                sys.exit(0)
            else:
                print "kestrel down"
                sys.exit(2)

    python使用tarantool

        # pip install tarantool-queue

        from tarantool_queue import Queue
        queue = Queue("localhost", 33013, 0)     # 连接读写端口 空间0
        tube = queue.tube("name_of_tube")        #
        tube.put([1, 2, 3])

        task = tube.take()
        task.data     # take task and read data from it
        task.ack()    # move this task into state DONE

7 web页面操作

    urllib2        [网络资源访问]

        import urllib2
        response = urllib2.urlopen('http://baidu.com')
        print response.geturl()       # url
        headers = response.info()
        print headers                 # web页面头部信息
        print headers['date']         # 头部信息中的时间
        date = response.read()        # 返回页面所有信息[字符串]
        # date = response.readlines() # 返回页面所有信息[列表]

        for i in urllib2.urlopen('http://qq.com'):    # 可直接迭代
            print i,

        下载文件

            #!/usr/bin/env python
            #encoding:utf8
            import urllib2

            url = 'http://www.01happy.com/wp-content/uploads/2012/09/bg.png'
            file("./pic/%04d.png" % i, "wb").write(urllib2.urlopen(url).read())

        抓取网页解析指定内容

            #!/usr/bin/env python
            #encoding:utf8

            import urllib2
            import urllib
            import random
            from bs4 import BeautifulSoup

            url='http://www.aaammm.com/aaa/'

            ua=["Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.0)",
            "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)",
            "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; WOW64; Trident/4.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; InfoPath.2; .NET4.0C; .NET4.0E)",
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.125 Safari/537.36",
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.125 Safari/537.36",
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.125 Safari/537.36",
            "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.143 Safari/537.36",
            "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/37.0.2062.120 Safari/537.36",
            "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/37.0.2062.120 Safari/537.36",
            "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/37.0.2062.120 Safari/537.36",
            "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/37.0.2062.120 Safari/537.36",
            "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:31.0) Gecko/20100101 Firefox/31.0",
            "Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.143 Safari/537.36"]

            browser = random.choice(ua)

            req_header = {'User-Agent':browser,
            'Accept':'text/html;q=0.9,*/*;q=0.8',
            'Cookie':'BAIDUID=4C8274B52CFB79DEB4FBA9A7EC76A1BC:FG=1; BDUSS=1dCdU1WNFdxUll0R09XcnBZTkRrVVVNbWVnSkRKSVRPeVljOUswclBoLUNzVEpVQVFBQUFBJCQAAAAAAAAAAAEAAADEuZ8BcXVhbnpob3U3MjIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIIIkC1SCJAtUY; BD_UPN=123143; BD_HOME=1',    # 添真实登陆后的Cookie 谷歌浏览器[F12  Network  Documents  Headers]
            'Accept-Charset':'ISO-8859-1,utf-8;q=0.7,*;q=0.3',
            'Connection':'close',
            }
            #data = urllib.urlencode({'name':'xuesong','id':'30' })          # urllib 的处理参数的方法，可以再urllib2中使用
            data = urllib2.quote("pgv_ref=im.perinfo.perinfo.icon&rrr=pppp")
            req_timeout = 10
            try:
                req = urllib2.Request(url,data=data,headers=req_header)      # data为None 则方法为get，有date为post方法
                html = urllib2.urlopen(req,data=None,req_timeout).read()
            except urllib2.HTTPError as err:
                print str(err)
            except:
                print "timeout"
            print(html)

            # 百度带Cookie后查看自己的用户
            #for i in html.split('\n'):
            #    if 'bds.comm.user=' in i:
            #        print i

            soup = BeautifulSoup(html)
            for i in  soup.find_all(target="_blank",attrs={"class": "usr-pic"}):   # 条件看情况选择
                if i.img:
                    print(i.get('href'))

        模拟浏览器访问web页面 python3
            #! /usr/bin/env python
            # -*- coding=utf-8 -*-
            import urllib.request

            url = "http://www.baidu.com"
            # AppleWebKit/537.11 (KHTML, like Gecko) Chrome/23.0.1271.64 Safari/537.11
            headers = {'User-Agent':'Mozilla/5.0 (Windows NT 6.1)',
            'Accept':'text/html;q=0.9,*/*;q=0.8',
            'Accept-Charset':'ISO-8859-1,utf-8;q=0.7,*;q=0.3',
            'Connection':'close',
            'Referer':None #注意如果依然不能抓取的话，这里可以设置抓取网站的host
            }

            opener = urllib.request.build_opener()
            opener.addheaders = [headers]
            data = opener.open(url).read()

            print(data)

    requests       [替代urllib2]

        # Requests是一个Python的HTTP客户端库
        # 官方中文文档 http://cn.python-requests.org/zh_CN/latest/user/quickstart.html#id2
        # 安装: sudo pip install requests
        import requests

        # get方法提交表单
        url = r'http://dict.youdao.com/search?le=eng&q={0}'.format(word.strip())
        r = requests.get(url,timeout=2)

        # get方法带参数 http://httpbin.org/get?key=val
        payload = {'key1': 'value1', 'key2': 'value2'}
        r = requests.get("http://httpbin.org/get", params=payload)

        # post方法提交表单
        QueryAdd='http://www.anti-spam.org.cn/Rbl/Query/Result'
        r = requests.post(url=QueryAdd, data={'IP':'211.211.54.54'})

        # 定制请求头post请求
        payload = {'some': 'data'}
        headers = {'content-type': 'application/json'}
        r = requests.post(url, data=json.dumps(payload), headers=headers)

        # https 需登录加auth
        r = requests.get('https://baidu.com', auth=('user', 'pass'))

        if r.ok:    # 判断请求是否正常
            print r.url             # u'http://httpbin.org/get?key2=value2&key1=value1'
            print r.status_code     # 状态码
            print r.content         # 获取到的原始内容  可使用 BeautifulSoup4 解析处理判定结果
            print r.text            # 把原始内容转unicode编码
            print r.headers         # 响应头
            print r.headers['content-type']          # 网页头信息 不存在为None
            print r.cookies['example_cookie_name']   # 查看cookie
            print r.history         # 追踪重定向 [<Response [301]>]  开启重定向 allow_redirects=True

        获取JSON
            r = requests.get('https://github.com/timeline.json')
            r.json()

        获取图片
            from PIL import Image
            from StringIO import StringIO
            i = Image.open(StringIO(r.content))

        发送cookies到服务器
            url = 'http://httpbin.org/cookies'
            cookies = dict(cookies_are='working')
            r = requests.get(url, cookies=cookies)
            r.text         '{"cookies": {"cookies_are": "working"}}'

        在同一个Session实例发出的所有请求之间保持cookies
            s = requests.Session()
            s.get('http://httpbin.org/cookies/set/sessioncookie/123456789')
            r = s.get("http://httpbin.org/cookies")
            print r.text

        会话对象能够跨请求保持某些参数
            s = requests.Session()
            s.auth = ('user', 'pass')
            s.headers.update({'x-test': 'true'})
            s.get('http://httpbin.org/headers', headers={'x-test2': 'true'})  # both 'x-test' and 'x-test2' are sent

        ssl证书验证
            requests.get('https://github.com', verify=True)
            requests.get('https://kennethreitz.com', verify=False)   # 忽略证书验证
            requests.get('https://kennethreitz.com', cert=('/path/server.crt', '/path/key'))   # 本地指定一个证书 正确 <Response [200]>  错误 SSLError

        流式上传
            with open('massive-body') as f:
                requests.post('http://some.url/streamed', data=f)

        流式请求
            import requests
            import json

            r = requests.post('https://stream.twitter.com/1/statuses/filter.json',
                data={'track': 'requests'}, auth=('username', 'password'), stream=True)

            for line in r.iter_lines():
                if line: # filter out keep-alive new lines
                    print json.loads(line)

        自定义身份验证
            from requests.auth import AuthBase
            class PizzaAuth(AuthBase):
                """Attaches HTTP Pizza Authentication to the given Request object."""
                def __init__(self, username):
                    # setup any auth-related data here
                    self.username = username
                def __call__(self, r):
                    # modify and return the request
                    r.headers['X-Pizza'] = self.username
                    return r
            requests.get('http://pizzabin.org/admin', auth=PizzaAuth('kenneth'))

        基本身份认证
            from requests.auth import HTTPBasicAuth
            requests.get('https://api.github.com/user', auth=HTTPBasicAuth('user', 'pass'))

        摘要式身份认证
            from requests.auth import HTTPDigestAuth
            url = 'http://httpbin.org/digest-auth/auth/user/pass'
            requests.get(url, auth=HTTPDigestAuth('user', 'pass'))

        代理
            import requests
            proxies = {
              "http": "http://10.10.1.10:3128",
              # "http": "http://user:pass@10.10.1.10:3128/",  # 用户名密码
              "https": "http://10.10.1.10:1080",
            }
            requests.get("http://example.org", proxies=proxies)
            #也可以设置环境变量之间访问
            export HTTP_PROXY="http://10.10.1.10:3128"
            export HTTPS_PROXY="http://10.10.1.10:1080"

    BeautifulSoup  [html\xml解析器]

        # BeautifulSoup中文官方文档
        # http://www.crummy.com/software/BeautifulSoup/bs3/documentation.zh.html
        # http://www.crummy.com/software/BeautifulSoup/bs4/doc/index.zh.html
        # Beautiful Soup将复杂HTML文档转换成一个复杂的树形结构,每个节点都是Python对象,所有对象可以归纳为4种: Tag , NavigableString , BeautifulSoup , Comment

        导入模块
            from BeautifulSoup import BeautifulSoup          # For processing HTML  版本3.0 已停止更新
            from BeautifulSoup import BeautifulStoneSoup     # For processing XML
            import BeautifulSoup                             # To get everything
            from bs4 import BeautifulSoup                    # 版本4.0 bs4 安装: pip install BeautifulSoup4

        from bs4 import BeautifulSoup
        soup = BeautifulSoup(html_doc)         # 解析html文本 可以是 requests 提交返回的页面 results.content
        print(soup.prettify())                 # 输出解析后的结构
        print(soup.title)                      # 指定标签内容
        print(soup.title.name)                 # 标签名
        print(soup.title.string)               # 标签内容
        print(soup.title.parent.name)          # 上层标签名
        print(soup.p)                          # <p class="title"><b>The Dormouse's story</b></p>
        print(soup.p['class'])                 # u'title'  class属性值
        print(soup.a)                          # 找到第一个a标签的标签行
        print(soup.find_all('a',limit=2))      # 找到a标签的行,最多为limit个
        print(soup.find(id="link3"))           # 标签内id为link3的标签行
        print(soup.get_text())                 # 从文档中获取所有文字内容
        soup.find_all("a", text="Elsie")       # 从文档中搜索关键字
        soup.find(text=re.compile("sisters"))  # 从文档中正则搜索关键字
        soup.find_all("a", class_="sister")    # 按CSS搜索
        soup.find_all(id='link2',"table",attrs={"class": "status"},href=re.compile("elsie"))   # 搜索方法
        for i in  soup.find_all('a',attrs={"class": "usr-pic"}):    # 循环所有a标签的标签行
                if i.a.img:
                        print(i.a.img.get("src"))                   # 取出当前a标签中的连接
        Tag
            # find_all 后循环的值是 Tag 不是字符串 不能直接截取
            tag.text                     # 文本
            tag.name
            tag.name = "blockquote"      # 查找name为 blockquote 的
            tag['class']
            tag.attrs                    # 按熟悉查找
            tag['class'] = 'verybold'

            del tag['class']             # 删除
            print(tag.get('class'))      # 打印属性值
            print(i.get('href'))         # 打印连接

    cookielib      [保留cookie登录页面]

        ck = cookielib.CookieJar()   # 通过 这个就可以实现请求带过去的COOKIE与发送回来的COOKIE值了。
        opener = urllib2.build_opener(urllib2.HTTPCookieProcessor(ck))   # 获取到COOKIE
        urllib2.install_opener(opener)   # 此句设置urllib2的全局opener
        content = urllib2.urlopen(url).read()

        登录cacti取图片
            #encoding:utf8
            import urllib2
            import urllib
            import cookielib
            def renrenBrower(url,user,password):
                #查找form标签中的action提交地址
                login_page = "http://10.10.10.19/cacti/index.php"
                try:
                    #获得一个cookieJar实例
                    cj = cookielib.CookieJar()
                    #cookieJar作为参数，获得一个opener的实例
                    opener=urllib2.build_opener(urllib2.HTTPCookieProcessor(cj))
                    #伪装成一个正常的浏览器，避免有些web服务器拒绝访问
                    opener.addheaders = [('User-agent','Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)')]
                    #生成Post数据,含有登陆用户名密码,所有表单内的input中name值
                    data = urllib.urlencode({"action":"login","login_username":user,"login_password":password})
                    #以post的方法访问登陆页面，访问之后cookieJar会自定保存cookie
                    opener.open(login_page,data)
                    #以带cookie的方式访问页面
                    op=opener.open(url)
                    #读取页面源码
                    data=op.read()
                    #将图片写到本地
                    #file("1d.png" , "wb").write(data)
                    return data
                except Exception,e:
                    print str(e)
            print renrenBrower("http://10.10.10.19/cacti/graph_image.php?local_graph_id=1630&rra_id=0&view_type=tree&graph_start=1397525517&graph_end=1397611917","admin","admin")

        例子2
            import urllib, urllib2, cookielib
            import os, time

            headers = []

            def login():
                cj = cookielib.CookieJar()
                opener = urllib2.build_opener(urllib2.HTTPCookieProcessor(cj))
                login_url = r'http://zhixing.bjtu.edu.cn/member.php?mod=logging&action=login&loginsubmit=yes&infloat=yes&lssubmit=yes&inajax=1'
                login_data = urllib.urlencode({'cookietime': '2592000', 'handlekey': 'ls', 'password': 'xxx',
                        'quickforward': 'yes', 'username': 'GuoYuan'})
                opener.addheaders = [('Host', 'zhixing.bjtu.edu.cn'),
                                   ('User-Agent', 'Mozilla/5.0 (Ubuntu; X11; Linux i686; rv:8.0) Gecko/20100101 Firefox/8.0'),
                                   ('Accept', 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'),
                                   ('Accept-Language', 'en-us,en;q=0.5'),
                                   ('Accept-Encoding', 'gzip, deflate'),
                                   ('Accept-Charset', 'ISO-8859-1,utf-8;q=0.7,*;q=0.7'),
                                   ('Connection', 'keep-alive'),
                                   ('Referer', 'http://zhixing.bjtu.edu.cn/forum.php'),]
                opener.open(login_url, login_data)
                return opener

            if __name__ == '__main__':
                opener = login()

                url = r'http://zhixing.bjtu.edu.cn/forum.php?mod=topicadmin&action=moderate&optgroup=2&modsubmit=yes&infloat=yes&inajax=1'
                data = {'fid': '601', 'formhash': '0cdd1596', 'frommodcp': '', 'handlekey': 'mods',
                         'listextra': 'page%3D62', 'moderate[]': '496146', 'operations[]': 'type', 'reason': '...',
                         'redirect': r'http://zhixing.bjtu.edu.cn/thread-496146-1-1.html', 'typeid': '779'}
                data2 = [(k, v) for k,v in data.iteritems()]

                cnt = 0
                for tid in range(493022, 496146 + 1):
                    cnt += 1
                    if cnt % 20 == 0: print
                    print tid,

                    data2.append(('moderate[]', str(tid)))
                    if cnt % 40 == 0 or cnt == 496146:
                        request = urllib2.Request(url=url, data=urllib.urlencode(data2))
                        print opener.open(request).read()
                        data2 = [(k, v) for k,v in data.iteritems()]

    httplib        [http协议的客户端]

        import httplib
        conn3 = httplib.HTTPConnection('www.baidu.com',80,True,10)

    aiohttp        [检索网页的客户端]

        # 需要python3.3+
        # http://aiohttp.readthedocs.org/en/v0.12.0/

        import aiohttp

        def get_body(url):
            response = yield from aiohttp.request('GET', url)
            return (yield from response.read())

        response = yield from aiohttp.request('GET', 'http://python.org')
        body = yield from response.read()
        print(body)

        # 用 asyncio 配合协程抓取页面
        yield from asyncio.wait_for(request('GET', url), 10)

        http_server

            import asyncio
            from aiohttp import web

            @asyncio.coroutine
            def handle(request):
                name = request.match_info.get('name', "Anonymous")
                text = "Hello, " + name
                return web.Response(body=text.encode('utf-8'))

            @asyncio.coroutine
            def init(loop):
                app = web.Application(loop=loop)
                app.router.add_route('GET', '/{name}', handle)

                srv = yield from loop.create_server(app.make_handler(),
                                                    '127.0.0.1', 8080)
                print("Server started at http://127.0.0.1:8080")
                return srv

            loop = asyncio.get_event_loop()
            loop.run_until_complete(init(loop))
            loop.run_forever()

    查看网页图片尺寸类型

        #将图片读入内存
        #!/usr/bin/env python
        #encoding=utf-8
        import cStringIO, urllib2, Image
        url = 'http://www.01happy.com/wp-content/uploads/2012/09/bg.png'
        file = urllib2.urlopen(url)
        tmpIm = cStringIO.StringIO(file.read())
        im = Image.open(tmpIm)
        print im.format, im.size, im.mode

    爬虫

        #!/usr/bin/env python
        #encoding:utf-8
        #sudo pip install BeautifulSoup

        import requests
        from BeautifulSoup import BeautifulSoup
        import re

        baseurl = 'http://blog.sina.com.cn/s/articlelist_1191258123_0_1.html'

        r = requests.get(baseurl)

        for url in re.findall('<a.*?</a>', r.content, re.S):
            if url.startswith('<a title='):
                with open(r'd:/final.txt', 'ab') as f:
                    f.write(url + '\n')

        linkfile = open(r'd:/final.txt', 'rb')
        soup = BeautifulSoup(linkfile)
        for link in soup.findAll('a'):
            #print link.get('title') + ':    ' + link.get('href')
            ss = requests.get(link.get('href'))
            for content in re.findall('<div id="sina_keyword_ad_area2" class="articalContent  ">.*?</div>', ss.content, re.S):
                with open(r'd:/myftp/%s.txt'%link.get('title').strip('<>'), 'wb') as f:
                    f.write(content)
                    print '%s   has been copied.' % link.get('title')

    反垃圾邮件提交申诉

        #很遗憾，反垃圾邮件联盟改版后加了验证码

        #!/usr/bin/env python
        #encoding:utf-8
        import requests
        import re

        IpList=['113.212.91.25','113.212.91.23']
        QueryAdd='http://www.anti-spam.org.cn/Rbl/Query/Result'
        ComplaintAdd='http://www.anti-spam.org.cn/Rbl/Getout/Submit'
        data = {
        'CONTENT':'''我们是一家正规的XXX。xxxxxxx。恳请将我们的发送服务器IP移出黑名单。谢谢！
        处理措施：
        1.XXXX。
        2.XXXX。''',
        'CORP':'abc.com',
        'WWW':'www.abc.cm',
        'NAME':'def',
        'MAIL':'def@163.com.cn',
        'TEL':'010-50000000',
        'LEVEL':'0',
        }

        for Ip in IpList:
            query = requests.post(url=QueryAdd, data={'IP':Ip})                   # 黑名单查询
            if query.ok:
                if re.findall(u'\u7533\u8bc9\u8131\u79bb', query.text, re.S):     # 查找关键字 申诉脱离 既表明在黑名单中
                    data['IP']=Ip
                    complaint = requests.post(url=ComplaintAdd, data=data)        # 提交申诉
                    if complaint.ok:
                        if re.findall(u'\u60a8\u7684\u9ed1\u540d\u5355\u8131\u79bb\u7533\u8bf7\u5df2\u63d0\u4ea4', complaint.text, re.S):
                            status='申请提交'
                        elif re.findall(u'\u8131\u79bb\u7533\u8bf7\u5df2\u88ab\u4ed6\u4eba\u63d0\u4ea4', complaint.text, re.S):
                            status='重复提交'
                        elif re.findall(u'\u7533\u8bf7\u7531\u4e8e\u8fd1\u671f\u5185\u6709\u88ab\u62d2\u7edd\u7684\u8bb0\u5f55', complaint.text, re.S):
                            status='近期拒绝'
                        else:
                            status='异常'
                else:
                    status='正常'
                print '%s  %s' %(Ip,status)

    有道词典

        #!/usr/bin/env python
        import requests
        from bs4 import BeautifulSoup
        # bs4安装: pip install BeautifulSoup4

        def youdao(word):
            url = r'http://dict.youdao.com/search?le=eng&q={0}'.format(word.strip())
            r = requests.get(url)
            if r.ok:
                soup = BeautifulSoup(r.content)
                div = soup.find_all('div', class_='trans-container')[:1]    # find_all是bs4的方法
                ul = BeautifulSoup(str(div[0]))
                li = ul.find_all('li')
                for mean in li:
                    print mean.text

        def query():
            print('Created by @littlepy, QQ:185635687')
            while True:
                word = raw_input('>>>')
                youdao(word)

        if __name__ == '__main__':
            query()

    python启动http服务提供访问或下载

        python -m SimpleHTTPServer  9900

8 并发

    #线程安全/竞争条件,锁/死锁检测,线程池,生产消费模型,伪并发,微线程,协程
    #Stackless Python 是Python编程语言的一个增强版本，它使程序员从基于线程的编程方式中获得好处，并避免传统线程所带来的性能与复杂度问题。Stackless为 Python带来的微线程扩展，是一种低开销、轻量级的便利工具

    threading多线程

        thread
            start_new_thread(function,args kwargs=None)    # 产生一个新的线程
            allocate_lock()                                # 分配一个LockType类型的锁对象
            exit()                                         # 让线程退出
            acquire(wait=None)                             # 尝试获取锁对象
            locked()                                       # 如果获取了锁对象返回True
            release()                                      # 释放锁

        thread例子

            #!/usr/bin/env python
            #thread_test.py
            #不支持守护进程
            import thread
            from time import sleep,ctime

            loops = [4,2]

            def loop(nloop,nsec,lock):
                print 'start loop %s at:%s' % (nloop,ctime())
                sleep(nsec)
                print 'loop %s done at: %s' % (nloop, ctime())
                lock.release()              # 分配已获得的锁,操作结束后释放相应的锁通知主线程

            def main():
                print 'starting at:',ctime()
                locks = []
                nloops = range(len(loops))

                for i in nloops:
                    lock = thread.allocate_lock()     # 创建一个锁
                    lock.acquire()                    # 调用各个锁的acquire()函数获得锁
                    locks.append(lock)                # 把锁放到锁列表locks中
                for i in nloops:
                    thread.start_new_thread(loop,(i,loops[i],locks[i]))   # 创建线程
                for i in nloops:
                    while locks[i].locked():pass      # 等待全部解锁才继续运行
                print 'all DONE at:',ctime()

            if __name__ == '__main__':
                main()

        thread例子1

            #coding=utf-8
            import thread,time,os

            def f(name):
                    i =3
                    while i:
                            time.sleep(1)
                            print name
                            i -= 1
                    # os._exit()   会把整个进程关闭
                    os._exit(22)

            if __name__ == '__main__':
                    thread.start_new_thread(f,("th1",))
                    while 1:
                            pass
                    os._exit(0)

        threading
            Thread                   # 表示一个线程的执行的对象
                start()              # 开始线程的执行
                run()                # 定义线程的功能的函数(一般会被子类重写)
                join(timeout=None)   # 允许主线程等待线程结束,程序挂起,直到线程结束;如果给了timeout,则最多等待timeout秒.
                getName()            # 返回线程的名字
                setName(name)        # 设置线程的名字
                isAlive()            # 布尔标志,表示这个线程是否还在运行中
                isDaemon()           # 返回线程的daemon标志
                setDaemon(daemonic)  # 后台线程,把线程的daemon标志设置为daemonic(一定要在调用start()函数前调用)
                # 默认主线程在退出时会等待所有子线程的结束。如果希望主线程不等待子线程，而是在退出时自动结束所有的子线程，就需要设置子线程为后台线程(daemon)
            Lock              # 锁原语对象
            Rlock             # 可重入锁对象.使单线程可以在此获得已获得了的锁(递归锁定)
            Condition         # 条件变量对象能让一个线程停下来,等待其他线程满足了某个条件.如状态改变或值的改变
            Event             # 通用的条件变量.多个线程可以等待某个事件的发生,在事件发生后,所有的线程都会被激活
            Semaphore         # 为等待锁的线程提供一个类似等候室的结构
            BoundedSemaphore  # 与Semaphore类似,只是不允许超过初始值
            Time              # 与Thread相似,只是他要等待一段时间后才开始运行
            activeCount()     # 当前活动的线程对象的数量
            currentThread()   # 返回当前线程对象
            enumerate()       # 返回当前活动线程的列表
            settrace(func)    # 为所有线程设置一个跟踪函数
            setprofile(func)  # 为所有线程设置一个profile函数

        threading例子1

            #!/usr/bin/env python
            #encoding:utf8
            import threading
            from Queue import Queue
            from time import sleep,ctime

            class ThreadFunc(object):
                    def __init__(self,func,args,name=''):
                            self.name=name
                            self.func=func                    # loop
                            self.args=args                    # (i,iplist[i],queue)
                    def __call__(self):
                            apply(self.func,self.args)        # 函数apply() 执行loop函数并传递元组参数
            def loop(nloop,ip,queue):
                    print 'start',nloop,'at:',ctime()
                    queue.put(ip)
                    sleep(2)
                    print 'loop',nloop,'done at:',ctime()
            if __name__ == '__main__':
                    threads = []
                    queue = Queue()
                    iplist = ['192.168.1.2','192.168.1.3','192.168.1.4','192.168.1.5','192.168.1.6','192.168.1.7','192.168.1.8']
                    nloops = range(len(iplist))

                    for i in nloops:
                            t = threading.Thread(target=ThreadFunc(loop,(i,iplist[i],queue),loop.__name__))
                            threads.append(t)
                    for i in nloops:
                            threads[i].start()
                    for i in nloops:
                            threads[i].join()
                    for i in nloops:
                            print queue.get()

        threading例子2

            #!/usr/bin/env python
            #encoding:utf8
            from Queue import Queue
            import random,time,threading

            class Producer(threading.Thread):
                def __init__(self, t_name, queue):
                    threading.Thread.__init__(self, name=t_name)
                    self.data=queue
                def run(self):
                    for i in range(5):
                        print "%s: %s is producing %d to the queue!\n" %(time.ctime(), self.getName(), i)
                        self.data.put(i)
                        self.data.put(i*i)
                        time.sleep(2)
                    print "%s: %s finished!" %(time.ctime(), self.getName())

            class Consumer(threading.Thread):
                def __init__(self, t_name, queue):
                    threading.Thread.__init__(self, name=t_name)
                    self.data=queue
                def run(self):
                    for i in range(10):
                        val = self.data.get()
                        print "%s: %s is consuming. %d in the queue is consumed!\n" %(time.ctime(), self.getName(), val)
                    print "%s: %s finished!" %(time.ctime(), self.getName())

            if __name__ == '__main__':
                queue = Queue()
                producer = Producer('Pro.', queue)
                consumer = Consumer('Con.', queue)
                producer.start()
                consumer.start()
                producer.join()
                consumer.join()

        threading例子3

            # 启动线程后自动执行 run函数其他不可以
            import threading
            import time

            class Th(threading.Thread):
                def __init__(self,name):
                    threading.Thread.__init__(self)
                    self.t_name=name
                    self.daemon = True     # 默认为false，让主线程等待处理完成
                def run(self):
                    time.sleep(1)
                    print "this is " + self.t_name

            if __name__ == '__main__':
                thread1 = Th("Th_1")
                thread1.start()

        threading例子4

            import threading
            import time
            class Th(threading.Thread):
                def __init__(self,thread_name):
                    threading.Thread.__init__(self)
                    self.setName(thread_name)
                def run(self):
                    threadLock.acquire()
                    print self.getName()
                    for i in range(3):
                        time.sleep(1)
                        print str(i)
                    print self.getName() +  " is over"
                    threadLock.release()

            if __name__ == '__main__':
                threadLock = threading.Lock()
                thread1 = Th("Th_1")
                thread2 = Th("Th_2")
                thread1.start()
                thread2.start()

        后台线程

            import threading
            import time,random

            class MyThread(threading.Thread):
                def run(self):
                    wait_time=random.randrange(1,10)
                    print "%s will wait %d seconds" % (self.name, wait_time)
                    time.sleep(wait_time)
                    print "%s finished!" % self.name

            if __name__=="__main__":
                for i in range(5):
                    t = MyThread()
                    t.setDaemon(True)    # 设置为后台线程,主线程完成时不等待子线程完成就结束
                    t.start()

        threading控制最大并发_查询日志中IP信息

            #!/usr/bin/env python
            #coding:utf-8
            import urllib2
            import json
            import threading
            import time

            '''
            by:某大牛
            QQ:185635687
            这个是多线程并发控制. 如果要改成多进程，只需把threading 换成 mulitprocessing.Process ， 对， 就是换个名字而已.
            '''

            #获取ip 及其出现次数
            def ip_dic(file_obj, dic):
                for i in file_obj:
                    if i:
                        ip=i.split('-')[0].strip()
                        if ip in dic.keys():
                            dic[ip]=dic[ip] + 1
                        else:
                            dic[ip]=1
                return dic.iteritems()

            #目标函数
            def get_data(url, ipcounts):
                data=urllib2.urlopen(url).read()
                datadict=json.loads(data)
                fdata = u"ip:%s---%s,%s,%s,%s,%s" %(datadict["data"]["ip"],ipcounts,datadict["data"]["country"],datadict["data"]["region"],datadict["data"]["city"],datadict["data"]["isp"])
                print fdata

            #多线程
            def threads(iters):
                thread_pool = []
                for k in iters:
                    url = "http://ip.taobao.com/service/getIpInfo.php?ip="
                    ipcounts = k[1]
                    url = (url + k[0]).strip()
                    t = threading.Thread(target=get_data, args=(url, ipcounts))
                    thread_pool.append(t)
                return thread_pool

            #控制多线程
            def startt(t_list, max,second):
                l = len(t_list)
                n = max
                while l > 0:
                    if l > max:
                        nl = t_list[:max]
                        t_list = t_list[max:]
                        for t in nl:
                            t.start()
                        time.sleep(second)
                        for t in nl:
                            t.join()
                        print '*'*15,  str(n)+ ' ip has been queried'+'*'*15
                        n += max
                        l = len(t_list)
                        continue
                    elif l <= max:
                        nl = t_list
                        for t in nl:
                            t.start()
                        for t in nl:
                            t.join()
                        print '>>> Totally ' + str(n+l ) + ' ip has been queried'
                        l = 0

            if __name__ =="__main__":
                dic={}
                with open('access.log') as file_obj:
                    it = ip_dic(file_obj, dic)
                    t_list= threads(it)
                    startt(t_list, 15, 1)

        多线程取队列

            #!/usr/bin/python

            import Queue
            import threading
            import time

            exitFlag = 0

            class myThread(threading.Thread):
                def __init__(self, threadID, name, q):
                    threading.Thread.__init__(self)
                    self.threadID = threadID
                    self.name = name
                    self.q = q
                def run(self):
                    print "Starting " + self.name
                    process_data(self.name, self.q)
                    print "Exiting " + self.name

            def process_data(threadName, q):
                while not exitFlag:      # 死循环等待
                    queueLock.acquire()
                    if not q.empty():    # 判断队列是否为空
                        data = q.get()
                        print "%s processing %s" % (threadName, data)
                    queueLock.release()
                    time.sleep(1)

            nameList = ["One", "Two", "Three", "Four", "Five"]
            queueLock = threading.Lock()     # 锁与队列并无任何关联，其他线程也进行取锁操作的时候就会检查是否有被占用，有就阻塞等待解锁为止
            workQueue = Queue.Queue(10)
            threads = []
            threadID = 1

            # Create new threads
            for threadID in range(100):
                thread = myThread(threadID, 'tName%s' % threadID, workQueue)
                thread.start()
                threads.append(thread)
                threadID += 1

            # Fill the queue
            queueLock.acquire()
            for word in nameList:
                workQueue.put(word)
            queueLock.release()

            # Wait for queue to empty
            while not workQueue.empty():   # 死循环判断队列被处理完毕
                pass

            # Notify threads it's time to exit
            exitFlag = 1

            # Wait for all threads to complete
            for t in threads:
                t.join()
            print "Exiting Main Thread"

    Queue通用队列

        q=Queue(size)       # 创建大小size的Queue对象
        qsize()             # 返回队列的大小(返回时候,可能被其他进程修改,近似值)
        empty()             # 如果队列为空返回True，否则Fales
        full()              # 如果队列已满返回True，否则Fales
        put(item,block0)    # 把item放到队列中,如果给了block(不为0),函数会一直阻塞到队列中有空间为止
        get(block=0)        # 从队列中取一个对象,如果给了block(不为0),函数会一直阻塞到队列中有对象为止
        get_nowait          # 默认get阻塞，这个不阻塞

    multiprocessing [多进程并发]

        线程池

            import urllib2
            from multiprocessing.dummy import Pool as ThreadPool

            urls=['http://www.baidu.com','http://www.sohu.com']

            pool=ThreadPool(4)   # 线程池
            results=pool.map(urllib2.urlopen,urls)
            pool.close()
            pool.join()

        进程并发

            #!/usr/bin/env python
            #encoding:utf8
            from multiprocessing import Process
            import time,os
            def f(name):
                time.sleep(1)
                print 'hello ',name
                print os.getppid()   # 取得父进程ID
                print os.getpid()    # 取得进程ID
            process_list = []

            for i in range(10):
                p = Process(target=f,args=(i,))
                p.start()
                process_list.append(p)
            for j in process_list:
                j.join()

        进程池

            #!/usr/bin/env python
            #encoding:utf8
            from multiprocessing import Pool
            import time,os
            def f(name):
                time.sleep(1)
                print 'hello ',name
                print os.getppid()
                print os.getpid()
            process_list = []

            pool = Pool(4)
            res = pool.map(f, range(1,10))
            pool.close()
            pool.join()

        Queue进程间通信

            from multiprocessing import Process,Queue
            import time
            def f(name):
                time.sleep(1)
                q.put(['hello'+str(name)])
            process_list = []
            q = Queue()
            if __name__ == '__main__':
                for i in range(10):
                    p = Process(target=f,args=(i,))
                    p.start()
                    process_list.append(p)
                for j in process_list:
                    j.join()
                for i in range(10):
                    print q.get()

        Pipe管道 # 单项通信

            from multiprocessing import Process,Pipe
            import time
            import os

            def f(conn,name):
                time.sleep(1)
                conn.send(['hello'+str(name)])
                print os.getppid(),'-----------',os.getpid()
            process_list = []
            parent_conn,child_conn = Pipe()
            if __name__ == '__main__':
                for i in range(10):
                    p = Process(target=f,args=(child_conn,i))
                    p.start()
                    process_list.append(p)
                for j in process_list:
                    j.join()
                for p in range(10):
                    print parent_conn.recv()

        进程间同步
            #加锁,使某一时刻只有一个进程,其他在调用同一个锁就会被阻塞
            from multiprocessing import Process,Lock
            import time
            import os

            def f(name):
                lock.acquire()
                time.sleep(1)
                print 'hello--'+str(name)
                print os.getppid(),'-----------',os.getpid()
                lock.release()
            process_list = []
            lock = Lock()
            if __name__ == '__main__':
                for i in range(10):
                    p = Process(target=f,args=(i,))
                    p.start()
                    process_list.append(p)
                for j in process_list:
                    j.join()

        共享内存 # 双向通信

            # 通过使用Value或者Array把数据存储在一个共享的内存表中
            # 'd'和'i'参数是num和arr用来设置类型，d表示一个双精浮点类型，i表示一个带符号的整型。
            from multiprocessing import Process,Value,Array
            import time
            import os

            def f(n,a,name):
                time.sleep(1)
                n.value = name * name
                for i in range(len(a)):
                    a[i] = -i
            process_list = []
            if __name__ == '__main__':
                num = Value('d',0.0)
                arr = Array('i',range(10))
                for i in range(10):
                    p = Process(target=f,args=(num,arr,i))
                    p.start()
                    process_list.append(p)
                for j in process_list:
                    j.join()
                print num.value
                print arr[:]

        manager

            # 比共享内存灵活,但缓慢
            # 支持list,dict,Namespace,Lock,Semaphore,BoundedSemaphore,Condition,Event,Queue,Ｖalue,Array
            from multiprocessing import Process,Manager
            import time
            import os

            def f(d,name):
                time.sleep(1)
                d[name] = name * name
                print d
            process_list = []
            if __name__ == '__main__':
                manager = Manager()
                d = manager.dict()
                for i in range(10):
                    p = Process(target=f,args=(d,i))
                    p.start()
                    process_list.append(p)
                for j in process_list:
                    j.join()
                    print d

        最大并发数

            import multiprocessing
            import time,os

            result = []
            def run(h):
                print 'threading:' ,h,os.getpid()
            p = multiprocessing.Pool(processes=20)

            for i in range(100):
                result.append(p.apply_async(run,(i,)))
            p.close()

            for res in result:
                res.get(timeout=5)

    gevent          [轻量级协程]

        # 在gevent中用到的主要模式是Greenlet, 它是以C扩展模块形式接入Python的轻量级协程。 Greenlet全部运行在主程序操作系统进程的内部，但它们被协作式地调度。
        # http://xlambda.com/gevent-tutorial/

        锁的使用

            # 同时允许多个协程操作对象的锁,通过互斥访问,保证资源只在程序上下文被单次使用
            from gevent import sleep
            from gevent.pool import Pool
            from gevent.coros import BoundedSemaphore

            sem = BoundedSemaphore(2)        # 超过2就会阻塞等待

            def worker1(n):
                sem.acquire()
                print('Worker %i acquired semaphore' % n)
                sleep(0)
                sem.release()
                print('Worker %i released semaphore' % n)

            def worker2(n):
                with sem:
                    print('Worker %i acquired semaphore' % n)
                    sleep(0)
                print('Worker %i released semaphore' % n)

            pool = Pool()
            pool.map(worker1, xrange(0,2))
            pool.map(worker2, xrange(3,6))

        事件

            # Event 阻塞事件
            import gevent
            from gevent.event import Event

            evt = Event()

            def setter():
                '''After 3 seconds, wake all threads waiting on the value of evt'''
                print('A: Hey wait for me, I have to do something')
                gevent.sleep(3)
                print("Ok, I'm done")
                evt.set()                 # 表示事件完成

            def waiter():
                '''After 3 seconds the get call will unblock'''
                print("I'll wait for you")
                evt.wait()                # 阻塞等待事件完成
                print("It's about time")

            gevent.joinall([
                gevent.spawn(setter),
                gevent.spawn(waiter),
                gevent.spawn(waiter),
                gevent.spawn(waiter),
                gevent.spawn(waiter),
                gevent.spawn(waiter)
            ])

            # AsyncResult 可传值的事件
            import gevent
            from gevent.event import AsyncResult
            a = AsyncResult()

            def setter():
                gevent.sleep(3)
                a.set('Hello!')            # 事件传值

            def waiter():
                """
                After 3 seconds the get call will unblock after the setter
                puts a value into the AsyncResult.
                """
                print(a.get())             # 获取时间值

            gevent.joinall([
                gevent.spawn(setter),
                gevent.spawn(waiter),
            ])

        队列

            #/usr/local/python
            #encoding:utf8
            import gevent
            from gevent.pool import Pool
            from gevent.coros import BoundedSemaphore
            from gevent.queue import Queue, Empty
            import os

            tasks = Queue(maxsize=30)         # 队列 超过30引发 gevent.hub.LoopExit
            tasks1 = Queue()

            def boss():
                print '放队列任务'
                for i in xrange(1,25):
                    tasks.put(i)

            def worker1(n):
                print len(pool)
                while not tasks.empty():      # 判断队列是否为空
                    task = tasks.get()        # 获取队列内容
                    tasks1.put(os.popen('id').read())
                    print('Worker %s got task %s' % (n, task))
                    gevent.sleep(0)           # 放弃当前任务

            def worker2(name):
                try:
                    while True:
                        task = tasks1.get(timeout=2)
                        print '获取后释放:%s' % task
                        gevent.sleep(0)
                except Empty:                 # 等待超时报错完成
                    print('Quitting time!')

            gevent.spawn(boss).join()         # 执行单次协程任务

            pool = Pool(5)                    # 协程池大小
            pool.map(worker1, xrange(0,20))   # 通过map方法把多个任务分发给池中的5个协程

            gevent.joinall([                  # 同时执行多个协程任务
                gevent.spawn(worker2, 'steve'),
                gevent.spawn(worker2, 'john'),
                gevent.spawn(worker2, 'nancy'),
            ])

9 框架

    flask           [微型网络开发框架]

        # http://dormousehole.readthedocs.org/en/latest/
        # http://www.pythonhosted.org/Flask-Bootstrap/basic-usage.html#templates
        # html放在 ./templates/   js放在 ./static/

        #pip install Flask-Login
        #pip install Flask-OpenID
        #pip install Flask-WTF
        #pip install flask-bootstrap
        #pip install flask-sqlalchemy
        #pip install flask-script
        #pip install flask-migrate

        request.args.get('page', 1)          # 获取参数 ?page=1
        request.json                         # 获取传递的整个json数据
        request.form.get("host",'127')       # 获取表单值
        request.form.getlist('client')       # 获取表单列表

        简单实例 # 接收数据和展示

            import MySQLdb as mysql
            from flask import Flask, request

            app = Flask(__name__)
            db.autocommit(True)
            c = db.cursor()

            """
            CREATE TABLE `statusinfo` (
              `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
              `hostname` varchar(32) NOT NULL,
              `load` float(10) NOT NULL DEFAULT 0.00,
              `time` int(15) NOT NULL,
              `memtotal` int(15) NOT NULL,
              `memusage` int(15) NOT NULL,
              `memfree` int(15) NOT NULL,
              PRIMARY KEY (`id`)
            ) ENGINE=InnoDB AUTO_INCREMENT=161 DEFAULT CHARSET=utf8;
            """

            @app.route("/collect", methods=["GET", "POST"])
            def collect():
                sql = ""
                if request.method == "POST":
                    data = request.json                      # 获取传递的json
                    hostname = data["Host"]
                    load = data["LoadAvg"]
                    time = data["Time"]
                    memtotal = data["MemTotal"]
                    memusage = data["MemUsage"]
                    memfree = data["MemFree"]

                    try:
                        sql = "INSERT INTO `statusinfo` (`hostname`,`load`,`time`,`memtotal`,`memusage`,`memfree`) VALUES('%s', %s, %s, %s, %s, %s);" % (hostname, load,time,memtotal,memusage,memfree)
                        ret = c.execute(sql)
                        return 'ok'
                    except mysql.IntegrityError:
                        return 'errer'

            @app.route("/show", methods=["GET", "POST"])
            def show():
                try:
                    hostname = request.form.get("hostname")     # 获取表单方式的变量值
                    sql = "SELECT `load` FROM `statusinfo` WHERE hostname = '%s';" % (hostname)
                    c.execute(sql)
                    ones = c.fetchall()
                    return render_template("sysstatus.html", data=ones, sql = sql)
                except:
                    print 'hostname null'

            from flask import render_template
            @app.route("/xxx/<name>")
            def hello_xx(name):
                return render_template("sysstatus.html", name='teach')

            if __name__ == "__main__":
                app.run(host="0.0.0.0", port=50000, debug=True)

    twisted         [非阻塞异步服务器框架]

        # 较老 推荐使用 协程框架 或 微线程框架
        # 用来进行网络服务和应用程序的编程。虽然 Twisted Matrix 中有大量松散耦合的模块化组件，但该框架的中心概念还是非阻塞异步服务器这一思想。对于习惯于线程技术或分叉服务器的开发人员来说，这是一种新颖的编程风格，但它却能在繁重负载的情况下带来极高的效率。
        pip install twisted

        from twisted.internet import protocol, reactor, endpoints

        class Echo(protocol.Protocol):
            def dataReceived(self, data):
                self.transport.write(data)
        class EchoFactory(protocol.Factory):
            def buildProtocol(self, addr):
                return Echo()

        endpoints.serverFromString(reactor, "tcp:1234").listen(EchoFactory())
        reactor.run()

        服务端

            #!/usr/bin/env python

            from twisted.application import service, internet
            from txjsonrpc.netstring import jsonrpc

            class Example(jsonrpc.JSONRPC):
                """An example object to be published."""
                def jsonrpc_echo(self,  x):
                    """Return all passed args."""
                    return x
                def jsonrpc_add(self, a, b):
                    """Return sum of arguments."""
                    print "add", a, b
                    return a + b

            factory = jsonrpc.RPCFactory(Example())
            application = service.Application("Example JSON-RPC Server")
            jsonrpcServer = internet.TCPServer(7080, factory)
            jsonrpcServer.setServiceParent(application)


        客户端
            #!/usr/bin/env python

            import os
            import sys
            sys.path.insert(0, os.getcwd())
            from twisted.internet import reactor
            from txjsonrpc.netstring.jsonrpc import Proxy

            def printValue(value):
                print "Result: %s" % str(value)
                reactor.stop()

            def printError(error):
                print 'error', error
                reactor.stop()

            proxy = Proxy('127.0.0.1', 7080)
            proxy.callRemote('add', 3, 5).addCallbacks(printValue, printError)
            reactor.run()

    Celery          [分布式任务队列]

        # http://docs.jinkan.org/docs/celery/getting-started/introduction.html
        pip install -U Celery

    tornado         [极轻量级Web服务器框架]

        # 高可伸缩性和epoll非阻塞IO,响应快速,可处理数千并发连接,特别适用用于实时的Web服务 底层是gevent协程
        # http://www.tornadoweb.cn/documentation
        # http://old.sebug.net/paper/books/tornado/#_2

        pip install tornado

        tornado 源码分析系列目录

            tornado 简介: http://www.cnblogs.com/Bozh/archive/2012/07/17/2596458.html
            tornado 网络层IOLoop: http://www.cnblogs.com/Bozh/archive/2012/07/18/2597114.html
            tornado 网络层IOLoop: http://www.cnblogs.com/Bozh/archive/2012/07/19/2598696.html
            tornado Buffer层IOStream: http://www.cnblogs.com/Bozh/archive/2012/07/20/2600520.html
            tornado HTTPServer层: http://www.cnblogs.com/Bozh/archive/2012/07/22/2603963.html
            tornado HTTPServer详解: http://www.cnblogs.com/Bozh/archive/2012/07/24/2606765.html


        get_argument()                # 方法来获取查询字符串参数，以及解析 POST 的内容
        self.request.arguments        # 所有的 GET 或 POST 的参数
        self.request.files            # 所有通过 multipart/form-data POST 请求上传的文件
        self.request.path             # 请求的路径（ ? 之前的所有内容）
        self.request.headers          # 请求的开头信息
        callback                      # 执行完成后执行回调函数

        @tornado.web.asynchronous     # 非阻塞异步装饰器
        self.finish()                 # 使用非阻塞异步 必须调用 self.finish() 已完成 HTTTP 请求
        # 异步 HTTP 客户端 两种模式 默认 SimpleAsyncHTTPClient  如果要修改为 CurlAsyncHTTPClient
        AsyncHTTPClient.configure('tornado.curl_httpclient.CurlAsyncHTTPClient')

        import tornado.ioloop
        import tornado.web

        class MainHandler(tornado.web.RequestHandler):
        import tornado.ioloop
        import tornadotornado.web
        import tornado.httpclient


        class MainHandler(tornado.web.RequestHandler):
            def get(self):
                self.write("Hello, world")

            def post(self):
                self.set_header("Content-Type", "text/plain")
                self.write("You wrote " + self.get_argument("message"))

        class Template(tornado.web.RequestHandler):
            def get(self):
                items = ["Item 1", "Item 2", "Item 3"]
                self.render("template.html", title="My title", items=items)

        class urlhttp(tornado.web.RequestHandler):
            @tornado.web.asynchronous
            def get(self):
                http = tornado.httpclient.AsyncHTTPClient()
                http.fetch("http://friendfeed-api.com/v2/feed/bret", callback=self.on_response)

            def on_response(self, response):
                if response.error: raise tornado.web.HTTPError(500)
                json = tornado.escape.json_decode(response.body)
                self.write("Fetched " + str(len(json["entries"])) + " entries "
                           "from the FriendFeed API")
                self.finish()

        class StoryHandler(tornado.web.RequestHandler):
            def get(self, story_id):
                self.write("You requested the story " + story_id)

        def make_app():
            return tornado.web.Application([
                (r"/", MainHandler),
                (r"/template", Template),
                (r"/story/([0-9]+)", StoryHandler),
            ])

        if __name__ == "__main__":
            app = make_app()
            app.listen(8888)
            tornado.ioloop.IOLoop.current().start()


    Scrapy          [web抓取框架]

        # Python开发的一个快速,高层次的屏幕抓取和web抓取框架，用于抓取web站点并从页面中提取结构化的数据。Scrapy用途广泛，可以用于数据挖掘、监测和自动化测试。
        pip install scrapy

        from scrapy import Spider, Item, Field

        class Post(Item):
            title = Field()

        class BlogSpider(Spider):
            name, start_urls = 'blogspider', ['http://blog.scrapinghub.com']

            def parse(self, response):
                return [Post(title=e.extract()) for e in response.css("h2 a::text")]

        scrapy runspider myspider.py

    django          [重量级web框架]

    bottle          [轻量级的Web框架]

    stackless       [增强版python]

        微线程扩展，是一种低开销、轻量级的便利工具  避免传统线程所带来的性能与复杂度问题

    greenlet        [微线程/协程框架]

        # 更加原始的微线程的概念,没有调度,或者叫做协程。这在你需要控制你的代码时很有用。你可以自己构造微线程的 调度器；也可以使用"greenlet"实现高级的控制流。例如可以重新创建构造器；不同于Python的构造器，我们的构造器可以嵌套的调用函数，而被嵌套的函数也可以 yield 一个值。
        pip install greenlet

    asyncio         [异步I/O协同]

        # https://docs.python.org/3/library/asyncio.html
        需要python3.4+
        asyncio: 协同程序和事件循环。协同程序像是方法，但是它们可以在代码中的特定点暂停和继续。当在等待一个IO（比如一个HTTP请求），同时执行另一个请求的时候，可以用来暂停一个协同程序。我们使用关键字yield from来设定一个状态，表明我们需要一个协同程序的返回值。而事件循环则被用来安排协同程序的执行。

10例子

    小算法

        斐波那契
            #将函数结果作为列表可用于循环
            def fab(max):
            n, a, b = 0, 0, 1
            while n < max:
                yield b
                a, b = b, a + b
                n = n + 1
            for n in fab(5):
                print n

        乘法口诀

            #!/usr/bin/python
            for i in range(1,10):
                for j in range(1,i+1):
                    print j,'*',i,'=',j*i,
                else:
                    print ''

        最小公倍数

            # 1-70的最小公倍数
            def c(m,n):
                    a1=m
                    b1=n
                    r=n%m
                    while r!=0:
                            n=m
                            m=r
                            r=n%m
                    return (a1*b1)/m
            d=1
            for i in range(3,71,2):
                    d = c(d,i)
            print d

        排序算法

            插入排序
                def insertion_sort(sort_list):
                    iter_len = len(sort_list)
                    if iter_len < 2:
                        return sort_list
                    for i in range(1, iter_len):
                        key = sort_list[i]
                        j = i - 1
                        while j>=0 and sort_list[j]>key:
                            sort_list[j+1] = sort_list[j]
                            j -= 1
                        sort_list[j+1] = key
                    return sort_list

            选择排序
                def selection_sort(sort_list):
                    iter_len = len(sort_list)
                    if iter_len < 2:
                        return sort_list
                    for i in range(iter_len-1):
                        smallest = sort_list[i]
                        location = i
                        for j in range(i, iter_len):
                            if sort_list[j] < smallest:
                                smallest = sort_list[j]
                                location = j
                        if i != location:
                            sort_list[i], sort_list[location] = sort_list[location], sort_list[i]
                    return sort_list

            冒泡排序
                def bubblesort(numbers):
                    for j in range(len(numbers)-1,-1,-1):
                        for i in range(j):
                            if numbers[i]>numbers[i+1]:
                                numbers[i],numbers[i+1] = numbers[i+1],numbers[i]
                            print(i,j)
                            print(numbers)

            快速排序

                # 先从数列中取出一个数作为基准数。
                # 分区过程，将比这个数大的数全放到它的右边，小于或等于它的数全放到它的左边。
                # 再对左右区间重复第二步，直到各区间只有一个数。
                #!/usr/bin/python
                # -*- coding: utf-8 -*-

                def sub_sort(array,low,high):
                    key = array[low]
                    while low < high:
                        while low < high and array[high] >= key:
                            high -= 1
                        while low < high and array[high] < key:
                            array[low] = array[high]
                            low += 1
                            array[high] = array[low]
                    array[low] = key
                    return low

                def quick_sort(array,low,high):
                     if low < high:
                        key_index = sub_sort(array,low,high)
                        quick_sort(array,low,key_index)
                        quick_sort(array,key_index+1,high)

                if __name__ == '__main__':
                    array = [8,10,9,6,4,16,5,13,26,18,2,45,34,23,1,7,3]
                    print array
                    quick_sort(array,0,len(array)-1)
                    print array

        二分算法

            #python 2f.py 123456789 4
            # list('123456789')  =  ['1', '2', '3', '4', '5', '6', '7', '8', '9']
            #!/usr/bin/env python
            import sys

            def search2(a,m):
                low = 0
                high = len(a) - 1
                while(low <= high):
                    mid = (low + high)/2
                    midval = a[mid]

                    if midval < m:
                        low = mid + 1
                    elif midval > m:
                        high = mid - 1
                    else:
                        print mid
                        return mid
                print -1
                return -1

            if __name__ == "__main__":
                a = [int(i) for i in list(sys.argv[1])]
                m = int(sys.argv[2])
                search2(a,m)

        全排序

            def Mideng(li):
                if(type(li)!=list):
                    return
                if(len(li)==1):
                    return [li]
                result=[]
                for i in range(0,len(li[:])):
                    bak=li[:]
                    head=bak.pop(i)
                    for j in Mideng(bak):
                        j.insert(0,head)
                        result.append(j)
                return result
            def MM(n):
                if(type(n)!=int or n<2):
                    return
                return Mideng(list(range(1,n)))

            MM(6)

    1000以内是3或者是5的倍数的值的和

        sum([ num for num in range(1, 1000) if num % 3 == 0 or num % 5 == 0 ])

    打印如下列表
        1
        2 1
        3 2 1
        4 3 2 1
        5 4 3 2 1
        6 5 4 3 2 1

        #!/usr/local/python

        i=1
        while i < 7:
            a = ""
            n=1
            while n <= i:
                a = "%s %s" %(n, a)
                n = n + 1

            print a
            i = i + 1

    将字典中所有time去掉

        a={'version01': {'nba': {'timenba': 'valuesasdfasdf', 'nbanbac': 'vtimefasdf', 'userasdf': 'vtimasdf'}}}
        eval(str(a).replace("time",""))

    PIL图像处理

        import Image
        im = Image.open("j.jpg")            # 打开图片
        print im.format, im.size, im.mode   # 打印图像格式、像素宽和高、模式
        # JPEG (440, 330) RGB
        im.show()                           # 显示最新加载图像
        box = (100, 100, 200, 200)
        region = im.crop(box)               # 从图像中提取出某个矩形大小的图像

    图片等比缩小

        # -*- coding: cp936 -*-
        import Image
        import glob, os

        #图片批处理
        def timage():
            for files in glob.glob('D:\\1\\*.JPG'):
                filepath,filename = os.path.split(files)
                filterame,exts = os.path.splitext(filename)
                #输出路径
                opfile = r'D:\\22\\'
                #判断opfile是否存在，不存在则创建
                if (os.path.isdir(opfile)==False):
                    os.mkdir(opfile)
                im = Image.open(files)
                w,h = im.size
                #im_ss = im.resize((400,400))
                #im_ss = im.convert('P')
                im_ss = im.resize((int(w*0.12), int(h*0.12)))
                im_ss.save(opfile+filterame+'.jpg')

        if __name__=='__main__':
            timage()

    取系统返回值赋给序列

        cmd = os.popen("df -Ph|awk 'NR!=1{print $5}'").readlines();
        cmd = os.popen('df -h').read().split('\n')
        cmd = os.popen('lo 2>&1').read()

        #取磁盘使用空间
        import commands
        df = commands.getoutput("df -hP")
        [ x.split()[4] for x in df.split("\n") ]
        [ (x.split()[0],x.split()[4]) for x in df.split("\n") if x.split()[4].endswith("%") ]

    切片获取星星

        def getRating(rating):
            return '★★★★★☆☆☆☆☆'.decode('utf8')[5-rating:10-rating]
        print getRating(1)
        print getRating(3)

    打印表格

        map = [["a","b","c"],
               ["d","e","f"],
               ["g","h","i"]]
        def print_board():
            for i in range(0,3):
                for j in range(0,3):
                    print "|",map[i][j],
                    #if j != 2:
                print '|'

    生成html文件表格

        log_file = file('check.html', 'w')
        log_file.write("""
        <!DOCTYPE HTML>
        <html lang="utr-8">
        <head>
        <meta charset="UTF-8">
        <title></title>
        </head>
        <body>
        <table align='center' border='0' cellPadding='0'  style='font-size:24px;'><tr ><td>状态统计</td></tr></table>
        <style>.font{font-size:13px}</style>
        <table  align='center' border='1' borderColor=gray cellPadding=3 width=1350  class='font'>
        <tr style='background-color:#666666'>
          <th width=65>IP</th>
          <th width=65>状态</th>
        </tr>
        """)
        for i in list:
            log_file.write('<tr><td>%s</td><td>%s</td></tr>\n' %(i.split()[0],i.split()[1]) )
        log_file.write("""
        </table>
        </body>
        </html>
        """)
        log_file.flush()
        log_file.close()

    井字游戏

        #!/usr/bin/python
        # http://www.admin10000.com/document/2506.html
        def print_board():
            for i in range(0,3):
                for j in range(0,3):
                    print map[2-i][j],
                    if j != 2:
                        print "|",
                print ""

        def check_done():
            for i in range(0,3):
                if map[i][0] == map[i][1] == map[i][2] != " " \
                or map[0][i] == map[1][i] == map[2][i] != " ":
                    print turn, "won!!!"
                    return True

            if map[0][0] == map[1][1] == map[2][2] != " " \
            or map[0][2] == map[1][1] == map[2][0] != " ":
                print turn, "won!!!"
                return True

            if " " not in map[0] and " " not in map[1] and " " not in map[2]:
                print "Draw"
                return True

            return False

        turn = "X"
        map = [[" "," "," "],
               [" "," "," "],
               [" "," "," "]]
        done = False

        while done != True:
            print_board()

            print turn, "'s turn"
            print

            moved = False
            while moved != True:
                print "Please select position by typing in a number between 1 and 9, see below for which number that is which position..."
                print "7|8|9"
                print "4|5|6"
                print "1|2|3"
                print

                try:
                    pos = input("Select: ")
                    if pos <=9 and pos >=1:
                        Y = pos/3
                        X = pos%3
                        if X != 0:
                            X -=1
                        else:
                             X = 2
                             Y -=1

                        if map[Y][X] == " ":
                            map[Y][X] = turn
                            moved = True
                            done = check_done()

                            if done == False:
                                if turn == "X":
                                    turn = "O"
                                else:
                                    turn = "X"

                except:
                    print "You need to add a numeric value"

    网段划分

        题目
            192.168.1
            192.168.3
            192.168.2
            172.16.3
            192.16.1
            192.16.2
            192.16.3
            10.0.4

            输出结果：
            192.16.1-192.16.3
            192.168.1-192.168.3
            172.16.3
            10.0.4

        答案
            #!/usr/bin/python

            f = file('a.txt')
            c = f.readlines()
            dic={}

            for i in c:
                a=i.strip().split('.')
                if a[0]+'.'+a[1] in dic.keys():
                    key=dic["%s.%s" %(a[0],a[1])]
                else:
                    key=[]
                key.append(a[2])
                dic[a[0]+'.'+a[1]]=sorted(key)

            for x,y in dic.items():
                if y[0] == y[-1]:
                    print '%s.%s' %(x,y[0])
                else:
                    print '%s.%s-%s.%s' %(x,y[0],x,y[-1])

    统计日志IP
        # 打印出独立IP，并统计独立IP数
        219.140.190.130 - - [23/May/2006:08:57:59 +0800] "GET /fg172.exe HTTP/1.1" 200 2350253
        221.228.143.52 - - [23/May/2006:08:58:08 +0800] "GET /fg172.exe HTTP/1.1" 206 719996
        221.228.143.52 - - [23/May/2006:08:58:08 +0800] "GET /fg172.exe HTTP/1.1" 206 713242

        #!/usr/bin/python
        dic={}
        a=open("a").readlines()
        for i in a:
            ip=i.strip().split()[0]
            if ip in dic.keys():
                dic[ip] = dic[ip] + 1
            else:
                dic[ip] = 1
        for x,y in dic.items():
            print x," ",y

    多线程下载http

        # 先从文件头中或取content-length的值,即文件大小,在用header中指定Range范围来下载文件中一段字符串
        # 'Range':'bytes=0-499'           # 表示头500个字节
        # 'Range':'bytes=-500'            # 表示最后500个字节
        # 'Range':'bytes=500-'            # 表示500字节以后的范围
        # 'Range':'bytes=0-0,-1'          # 第一个和最后一个字节
        # 'Range':'bytes=50-60,61-99'     # 同时指定几个范围

        #!/usr/bin/env python
        #encoding:utf8
        import urllib2
        import threading


        class myThread(threading.Thread):

            def __init__(self, url_file, scope, url):
                threading.Thread.__init__(self)
                self.url_file = url_file
                self.scope = scope
                self.url = url

            def run(self):

                req_header = {'User-Agent':"Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.0)",
                'Accept':'text/html;q=0.9,*/*;q=0.8',
                'Range':'bytes=%s' % self.scope,
                'Accept-Charset':'ISO-8859-1,utf-8;q=0.7,*;q=0.3',
                'Connection':'close',
                }

                req = urllib2.Request(self.url, headers=req_header)
                data = urllib2.urlopen(req, data=None).read()
                start_value = int(self.scope.split('-')[0])

                threadLock.acquire()

                self.url_file.seek(start_value)
                self.url_file.write(data)
                self.url_file.flush()
                threadLock.release()

        if __name__ == '__main__':

            url = 'http://dldir1.qq.com/qqfile/qq/QQ7.1/14522/QQ7.1.exe'
            size=int(urllib2.urlopen(url).info()['content-length'])
            print size
            threadnum = 4
            len = size / threadnum
            current = 0

            url_file = file(url.split('/')[-1],'wb+')
            threadLock = threading.Lock()
            threads = []
            for tName in range(1, threadnum + 1):

                if tName < threadnum:
                    scope = "%d-%d" %(current,len * tName - 1)
                    current = len * tName
                elif tName == threadnum:
                        scope = "%d-" %(current)
                print scope
                thread = myThread(url_file, scope, url)
                thread.start()
                threads.append(thread)

            for t in threads:
                t.join()

            url_file.flush()
            url_file.close()

    获取网卡流量

        #!/usr/bin/env python

        net = []
        f = open("/proc/net/dev")
        lines = f.readlines()
        f.close()
        for line in lines[3:]:
            con = line.split()
            intf = dict(
                zip(
                    ( 'interface', 'ReceiveBytes', 'ReceivePackets', 'TransmitBytes', 'TransmitPackets',),
                    ( con[0].split(":")[0], con[0].split(":")[1], int(con[1]), int(con[8]), int(con[9]),)
                )
            )
            net.append(intf)
        print net

    获取系统监控信息

        #!/usr/bin/env python
        import inspect
        import os,time,socket

        class mon:
            def __init__(self):
                self.data = {}
            def getLoadAvg(self):
                with open('/proc/loadavg') as load_open:
                    a = load_open.read().split()[:3]
                    #return "%s %s %s" % (a[0],a[1],a[2])
                    return   float(a[0])
            def getMemTotal(self):
                with open('/proc/meminfo') as mem_open:
                    a = int(mem_open.readline().split()[1])
                    return a / 1024
            def getMemUsage(self, noBufferCache=True):
                if noBufferCache:
                    with open('/proc/meminfo') as mem_open:
                        T = int(mem_open.readline().split()[1]) #Total
                        F = int(mem_open.readline().split()[1]) #Free
                        B = int(mem_open.readline().split()[1]) #Buffer
                        C = int(mem_open.readline().split()[1]) #Cache
                        return (T-F-B-C)/1024
                else:
                    with open('/proc/meminfo') as mem_open:
                        a = int(mem_open.readline().split()[1]) - int(mem_open.readline().split()[1])
                        return a / 1024
            def getMemFree(self, noBufferCache=True):
                if noBufferCache:
                    with open('/proc/meminfo') as mem_open:
                        T = int(mem_open.readline().split()[1])
                        F = int(mem_open.readline().split()[1])
                        B = int(mem_open.readline().split()[1])
                        C = int(mem_open.readline().split()[1])
                        return (F+B+C)/1024
                else:
                    with open('/proc/meminfo') as mem_open:
                        mem_open.readline()
                        a = int(mem_open.readline().split()[1])
                        return a / 1024
            def getDiskTotal(self):
                disk = os.statvfs("/")
                Total = disk.f_bsize * disk.f_blocks / 1024 / 1024
                return Total
            def getDiskFree(self):
                disk = os.statvfs("/")
                Free = disk.f_bsize * disk.f_bavail / 1024 / 1024
                return Free
            def getTraffic(self):
                traffic = {}
                f = open("/proc/net/dev")
                lines = f.readlines()
                f.close()
                for line in lines[3:]:
                    con = line.split()
                    intf = dict(
                        zip(
                            ('ReceiveBytes', 'TransmitBytes',),
                            (con[0].split(":")[1], int(con[8]),)
                        )
                    )
                    traffic[con[0].split(":")[0]] = intf
                return traffic
            def getHost(self):
                #return ['host1', 'host2', 'host3', 'host4', 'host5'][int(time.time() * 1000.0) % 5]
                return socket.gethostname()
            def getTime(self):
                return int(time.time())
            def runAllGet(self):
                for fun in inspect.getmembers(self, predicate=inspect.ismethod):
                    if fun[0][:3] == 'get':
                        self.data[fun[0][3:]] = fun[1]()
                return self.data

        if __name__ == "__main__":
            print mon().runAllGet()

    获取主机名

        #!/usr/bin/env python
        # -*- coding: utf8 -*-
        #python network.py --host

        import os
        import socket

        """
        copy from:
        http://stackoverflow.com/questions/11735821/python-get-localhost-ip
        """

        if os.name != "nt":
            import fcntl
            import struct

            def get_interface_ip(ifname):
                s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
                return socket.inet_ntoa(fcntl.ioctl(s.fileno(), 0x8915, struct.pack('256s', ifname[:15]))[20:24])

        def lan_ip():
            ip = socket.gethostbyname(socket.gethostname())
            if ip.startswith("127.") and os.name != "nt":
                interfaces = [
                    "eth0",
                    "eth1",
                    "eth2",
                    "wlan0",
                    "wlan1",
                    "wifi0",
                    "ath0",
                    "ath1",
                    "ppp0",
                ]
                for ifname in interfaces:
                    try:
                        ip = get_interface_ip(ifname)
                        break
                    except IOError:
                        pass
            return ip

        if __name__ == '__main__':
            import sys
            if len(sys.argv) > 1:
                print socket.gethostname()
                sys.exit(0)
            print lan_ip()

    LazyManage并发批量操作(判断非root交互到root操作)

        #!/usr/bin/python
        #encoding:utf8
        # LzayManage.py
        # config file: serverlist.conf

        import paramiko
        import multiprocessing
        import sys,os,time,socket,re

        def Ssh_Cmd(host_ip,Cmd,user_name,user_pwd,port=22):
            s = paramiko.SSHClient()
            s.load_system_host_keys()
            s.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            s.connect(hostname=host_ip,port=port,username=user_name,password=user_pwd)
            stdin,stdout,stderr = s.exec_command(Cmd)
            Result = '%s%s' %(stdout.read(),stderr.read())
            q.put('successful')
            s.close()
            return Result.strip()

        def Ssh_Su_Cmd(host_ip,Cmd,user_name,user_pwd,root_name,root_pwd,port=22):
            s = paramiko.SSHClient()
            s.load_system_host_keys()
            s.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            s.connect(hostname=host_ip,port=port,username=user_name,password=user_pwd)
            ssh = s.invoke_shell()
            time.sleep(0.1)
            ssh.send('su - %s\n' %(root_name))
            buff = ''
            while not buff.endswith('Password: '):
                resp = ssh.recv(9999)
                buff +=resp
            ssh.send('%s\n' %(root_pwd))
            buff = ''
            while True:
                resp = ssh.recv(9999)
                buff +=resp
                if ': incorrect password' in buff:
                    su_correct='passwd_error'
                    break
                elif buff.endswith('# '):
                    su_correct='passwd_correct'
                    break
            if su_correct == 'passwd_correct':
                ssh.send('%s\n' %(Cmd))
                buff = ''
                while True:
                    resp = ssh.recv(9999)
                    if resp.endswith('# '):
                        buff +=re.sub('\[.*@.*\]# $','',resp)
                        break
                    buff +=resp
                Result = buff.lstrip('%s' %(Cmd))
                q.put('successful')
            elif su_correct == 'passwd_error':
                Result = "\033[31mroot密码错误\033[m"
            s.close()
            return Result.strip()

        def Send_File(host_ip,PathList,user_name,user_pwd,Remote='/tmp',port=22):
            s=paramiko.Transport((host_ip,port))
            s.connect(username=user_name,password=user_pwd)
            sftp=paramiko.SFTPClient.from_transport(s)
            for InputPath in PathList:
                LocalPath = re.sub('^\./','',InputPath.rstrip('/'))
                RemotePath = '%s/%s' %( Remote , os.path.basename( LocalPath ))
                try:
                    sftp.rmdir(RemotePath)
                except:
                    pass
                try:
                    sftp.remove(RemotePath)
                except:
                    pass
                if os.path.isdir(LocalPath):
                    sftp.mkdir(RemotePath)
                    for path,dirs,files in os.walk(LocalPath):
                        for dir in dirs:
                            dir_path = os.path.join(path,dir)
                            sftp.mkdir('%s/%s' %(RemotePath,re.sub('^%s/' %LocalPath,'',dir_path)))
                        for file in files:
                            file_path = os.path.join(path,file)
                            sftp.put( file_path,'%s/%s' %(RemotePath,re.sub('^%s/' %LocalPath,'',file_path)))
                else:
                    sftp.put(LocalPath,RemotePath)
            q.put('successful')
            sftp.close()
            s.close()
            Result = '%s  \033[32m传送完成\033[m' % PathList
            return Result

        def Ssh(host_ip,Operation,user_name,user_pwd,root_name,root_pwd,Cmd=None,PathList=None,port=22):
            msg = "\033[32m-----------Result:%s----------\033[m" % host_ip
            try:
                if Operation == 'Ssh_Cmd':
                    Result = Ssh_Cmd(host_ip=host_ip,Cmd=Cmd,user_name=user_name,user_pwd=user_pwd,port=port)
                elif Operation == 'Ssh_Su_Cmd':
                    Result = Ssh_Su_Cmd(host_ip=host_ip,Cmd=Cmd,user_name=user_name,user_pwd=user_pwd,root_name=root_name,root_pwd=root_pwd,port=port)
                elif Operation == 'Ssh_Script':
                    Send_File(host_ip=host_ip,PathList=PathList,user_name=user_name,user_pwd=user_pwd,port=port)
                    Script_Head = open(PathList[0]).readline().strip()
                    LocalPath = re.sub('^\./','',PathList[0].rstrip('/'))
                    Cmd = '%s /tmp/%s' %( re.sub('^#!','',Script_Head), os.path.basename( LocalPath ))
                    Result = Ssh_Cmd(host_ip=host_ip,Cmd=Cmd,user_name=user_name,user_pwd=user_pwd,port=port)
                elif Operation == 'Ssh_Su_Script':
                    Send_File(host_ip=host_ip,PathList=PathList,user_name=user_name,user_pwd=user_pwd,port=port)
                    Script_Head = open(PathList[0]).readline().strip()
                    LocalPath = re.sub('^\./','',PathList[0].rstrip('/'))
                    Cmd = '%s /tmp/%s' %( re.sub('^#!','',Script_Head), os.path.basename( LocalPath ))
                    Result = Ssh_Su_Cmd(host_ip=host_ip,Cmd=Cmd,user_name=user_name,user_pwd=user_pwd,root_name=root_name,root_pwd=root_pwd,port=port)
                elif Operation == 'Send_File':
                    Result = Send_File(host_ip=host_ip,PathList=PathList,user_name=user_name,user_pwd=user_pwd,port=port)
                else:
                    Result = '操作不存在'

            except socket.error:
                Result = '\033[31m主机或端口错误\033[m'
            except paramiko.AuthenticationException:
                Result = '\033[31m用户名或密码错误\033[m'
            except paramiko.BadHostKeyException:
                Result = '\033[31mBad host key\033[m['
            except IOError:
                Result = '\033[31m远程主机已存在非空目录或没有写权限\033[m'
            except:
                Result = '\033[31m未知错误\033[m'
            r.put('%s\n%s\n' %(msg,Result))

        def Concurrent(Conf,Operation,user_name,user_pwd,root_name,root_pwd,Cmd=None,PathList=None,port=22):
            # 读取配置文件
            f=open(Conf)
            list = f.readlines()
            f.close()
            # 执行总计
            total = 0
            # 并发执行
            for host_info in list:
                # 判断配置文件中注释行跳过
                if host_info.startswith('#'):
                    continue
                # 取变量,其中任意变量未取到就跳过执行
                try:
                    host_ip=host_info.split()[0]
                    #user_name=host_info.split()[1]
                    #user_pwd=host_info.split()[2]
                except:
                    print('Profile error: %s' %(host_info) )
                    continue
                try:
                    port=int(host_info.split()[3])
                except:
                    port=22
                total +=1
                p = multiprocessing.Process(target=Ssh,args=(host_ip,Operation,user_name,user_pwd,root_name,root_pwd,Cmd,PathList,port))
                p.start()
            # 打印执行结果
            for j in range(total):
                print(r.get() )
            if Operation == 'Ssh_Script' or Operation == 'Ssh_Su_Script':
                successful = q.qsize() / 2
            else:
                successful = q.qsize()
            print('\033[32m执行完毕[总执行:%s 成功:%s 失败:%s]\033[m' %(total,successful,total - successful) )
            q.close()
            r.close()

        def Help():
            print('''    1.执行命令
            2.执行脚本      \033[32m[位置1脚本(必须带脚本头),后可带执行脚本所需要的包\文件\文件夹路径,空格分隔]\033[m
            3.发送文件      \033[32m[传送的包\文件\文件夹路径,空格分隔]\033[m
            退出: 0\exit\quit
            帮助: help\h\?
            注意: 发送文件默认为/tmp下,如已存在同名文件会被强制覆盖,非空目录则中断操作.执行脚本先将本地脚本及包发送远程主机上,发送规则同发送文件
            ''')

        if __name__=='__main__':
            # 定义root账号信息
            root_name = 'root'
            root_pwd = 'peterli'
            user_name='peterli'
            user_pwd='<++(3Ie'
            # 配置文件
            Conf='serverlist.conf'
            if not os.path.isfile(Conf):
                print('\033[33m配置文件 %s 不存在\033[m' %(Conf) )
                sys.exit()
            Help()
            while True:
                i = raw_input("\033[35m[请选择操作]: \033[m").strip()
                q = multiprocessing.Queue()
                r = multiprocessing.Queue()
                if i == '1':
                    if user_name == root_name:
                        Operation = 'Ssh_Cmd'
                    else:
                        Operation = 'Ssh_Su_Cmd'
                    Cmd = raw_input('CMD: ').strip()
                    if len(Cmd) == 0:
                        print('\033[33m命令为空\033[m')
                        continue
                    Concurrent(Conf=Conf,Operation=Operation,user_name=user_name,user_pwd=user_pwd,root_name=root_name,root_pwd=root_pwd,Cmd=Cmd)
                elif i == '2':
                    if user_name == root_name:
                        Operation = 'Ssh_Script'
                    else:
                        Operation = 'Ssh_Su_Script'
                    PathList = raw_input('\033[36m本地脚本路径: \033[m').strip().split()
                    if len(PathList) == 0:
                        print('\033[33m路径为空\033[m')
                        continue
                    if not os.path.isfile(PathList[0]):
                        print('\033[33m本地路径 %s 不存在或不是文件\033[m' %(PathList[0]) )
                        continue
                    for LocalPath in PathList[1:]:
                        if not os.path.exists(LocalPath):
                            print('\033[33m本地路径 %s 不存在\033[m' %(LocalPath) )
                            break
                    else:
                        Concurrent(Conf=Conf,Operation=Operation,user_name=user_name,user_pwd=user_pwd,root_name=root_name,root_pwd=root_pwd,PathList=PathList)
                elif i == '3':
                    Operation = 'Send_File'
                    PathList = raw_input('\033[36m本地路径: \033[m').strip().split()
                    if len(PathList) == 0:
                        print('\033[33m路径为空\033[m')
                        continue
                    for LocalPath in PathList:
                        if not os.path.exists(LocalPath):
                            print('\033[33m本地路径 %s 不存在\033[m' %(LocalPath) )
                            break
                    else:
                        Concurrent(Conf=Conf,Operation=Operation,user_name=user_name,user_pwd=user_pwd,root_name=root_name,root_pwd=root_pwd,PathList=PathList)
                elif i == '0' or i == 'exit' or i == 'quit':
                    print("\033[34m退出LazyManage脚本\033[m")
                    sys.exit()
                elif i == 'help' or i == 'h' or i == '?':
                    Help()

    epoll非阻塞长链接

        server

            #!/usr/bin/python
            #-*- coding:utf-8 -*-

            import socket, select, logging, errno
            import os, sys, json

            def cmdRunner(input):
                import commands
                cmd_ret = commands.getstatusoutput(input)
                return json.dumps({'ret':cmd_ret[0], 'out':cmd_ret[1]}, separators=(',', ':'))

            class _State:
                def __init__(self):
                    self.state = "read"
                    self.have_read = 0
                    self.need_read = 10
                    self.have_write = 0
                    self.need_write = 0
                    self.data = ""

            __all__ = ['nbNet']

            class nbNet:

                def __init__(self, host, port, logic):
                    self.host = host
                    self.port = port
                    self.logic = logic
                    self.sm = {
                        "read":self.aread,
                        "write":self.awrite,
                        "process":self.aprocess,
                        "closing":self.aclose,
                    }

                def run(self):

                    try:
                        self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM, 0)
                    except socket.error, msg:
                        print("create socket failed")

                    try:
                        self.sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
                    except socket.error, msg:
                        print("setsocketopt SO_REUSEADDR failed")

                    try:
                        self.sock.bind((self.host, self.port))
                    except socket.error, msg:
                        print("bind failed")

                    try:
                        self.sock.listen(10)
                    except socket.error, msg:
                        print(msg)

                    try:
                        self.epoll_fd = select.epoll()
                        # 向 epoll 句柄中注册 新来socket链接，监听可读事件
                        self.epoll_fd.register(self.sock.fileno(), select.EPOLLIN )
                    except select.error, msg:
                        print(msg)

                    self.STATE = {}

                    while True:
                        print self.STATE
                        # epoll 等待事件回调收发数据
                        epoll_list = self.epoll_fd.poll()
                        for fd, events in epoll_list:
                            if select.EPOLLHUP & events:
                                print 'EPOLLHUP'
                                self.STATE[fd][2].state = "closing"
                            elif select.EPOLLERR & events:
                                print 'EPOLLERR'
                                self.STATE[fd][2].state = "closing"
                            self.state_machine(fd)
                def state_machine(self, fd):
                    if fd == self.sock.fileno():
                        print "state_machine fd %s accept" % fd
                        # fd与初始监听的fd一致,新创建一个连接
                        conn, addr = self.sock.accept()
                        # 设置为非阻塞
                        conn.setblocking(0)
                        self.STATE[conn.fileno()] = [conn, addr, _State()]
                        # 将新建立的链接注册在epoll句柄中,监听可读事件,并设置为EPOLLET高速边缘触发,即触发后不会再次触发直到新接收数据
                        self.epoll_fd.register(conn.fileno(), select.EPOLLET | select.EPOLLIN )
                    else:
                        # 否则为历史已存在的fd，调用对应的状态方法
                        print "state_machine fd %s %s" % (fd,self.STATE[fd][2].state)
                        stat = self.STATE[fd][2].state
                        self.sm[stat](fd)
                def aread(self, fd):
                    try:
                        # 接收当前fd的可读事件中的数据
                        one_read = self.STATE[fd][0].recv(self.STATE[fd][2].need_read)
                        if len(one_read) == 0:
                            # 接收错误改变状态为关闭
                            self.STATE[fd][2].state = "closing"
                            self.state_machine(fd)
                            return
                        # 将历史接收的数据叠加
                        self.STATE[fd][2].data += one_read
                        self.STATE[fd][2].have_read += len(one_read)
                        self.STATE[fd][2].need_read -= len(one_read)
                        # 接收协议的10个字符
                        if self.STATE[fd][2].have_read == 10:
                            # 通过10个字符得知下次应该具体接收多少字节,存入状态字典中
                            self.STATE[fd][2].need_read += int(self.STATE[fd][2].data)
                            self.STATE[fd][2].data = ''
                            # 调用状态机重新处理
                            self.state_machine(fd)
                        elif self.STATE[fd][2].need_read == 0:
                            # 当接全部收完毕,改变状态,去执行具体服务
                            self.STATE[fd][2].state = 'process'
                            self.state_machine(fd)
                    except socket.error, msg:
                        self.STATE[fd][2].state = "closing"
                        print(msg)
                        self.state_machine(fd)
                        return

                def aprocess(self, fd):
                    # 执行具体执行方法 cmdRunner 得到符合传输协议的返回结果
                    response = self.logic(self.STATE[fd][2].data)
                    self.STATE[fd][2].data = "%010d%s"%(len(response), response)
                    self.STATE[fd][2].need_write = len(self.STATE[fd][2].data)
                    # 改变为写的状态
                    self.STATE[fd][2].state = 'write'
                    # 改变监听事件为写
                    self.epoll_fd.modify(fd, select.EPOLLET | select.EPOLLOUT)
                    self.state_machine(fd)

                def awrite(self, fd):
                    try:
                        last_have_send = self.STATE[fd][2].have_write
                        # 发送返回给客户端的数据
                        have_send = self.STATE[fd][0].send(self.STATE[fd][2].data[last_have_send:])
                        self.STATE[fd][2].have_write += have_send
                        self.STATE[fd][2].need_write -= have_send
                        if self.STATE[fd][2].need_write == 0 and self.STATE[fd][2].have_write != 0:
                            # 发送完成,重新初始化状态,并将监听写事件改回读事件
                            self.STATE[fd][2] = _State()
                            self.epoll_fd.modify(fd, select.EPOLLET | select.EPOLLIN)
                    except socket.error, msg:
                        self.STATE[fd][2].state = "closing"
                        self.state_machine(fd)
                        print(msg)
                        return

                def aclose(self, fd):
                    try:
                        print 'Error: %s:%d' %(self.STATE[fd][1][0] ,self.STATE[fd][1][1])
                        # 取消fd的事件监听
                        self.epoll_fd.unregister(fd)
                        # 关闭异常链接
                        self.STATE[fd][0].close()
                        # 删除fd的状态信息
                        self.STATE.pop(fd)
                    except:
                        print 'Close the abnormal'

            if __name__ == "__main__":
                HOST = '0.0.0.0'
                PORT = 50005
                nb = nbNet(HOST, PORT, cmdRunner)
                nb.run()

        client

            #!/usr/bin/env python

            import socket, sys, os

            HOST = '0.0.0.0'
            PORT = 50005

            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.connect((HOST, PORT))

            cmd = sys.argv[1]
            while True:
                s.sendall("%010d%s"%(len(cmd), cmd))
                print cmd
                count = s.recv(10)
                if not count:
                    print '-----------'
                    print count
                    sys.exit()
                count = int(count)
                buf = s.recv(count)
                print buf



不定期更新下载地址：
http://pan.baidu.com/s/1sjsFrmX
https://github.com/liquanzhou/ops_doc

请勿删除信息, 植入广告, 抵制不道德行为

