nginx正则规则详解


摘要: nginx正则规则详解 1.正则表达式匹配,其中: Nginx的Location可以有以下几个匹配： 1. =   严格匹配这个查询。如果找到，停止搜索。 2. ^~ 匹配路径的前缀，如果找到，停止搜索。 3. ~  ...

nginx正则规则详解
1.正则表达式匹配,其中:
Nginx的Location可以有以下几个匹配：
1. =   严格匹配这个查询。如果找到，停止搜索。
2. ^~ 匹配路径的前缀，如果找到，停止搜索。
3. ~   为区分大小写的正则匹配  
4. ~* 为不区分大小写匹配
5. !~和!~*分别为区分大小写不匹配及不区分大小写不匹配

2.文件及目录匹配,其中:
-f和!-f用来判断是否存在文件
-d和!-d用来判断是否存在目录
-e和!-e用来判断是否存在文件或目录
-x和!-x用来判断文件是否可执行

3.flag标记有:
跳转型的
redirect:  302跳转到rewrite后的地址
permanent: 301永久定向到rewrite后的地址,对搜索引擎更友好

代理型的
last:  重新将rewrite后的地址在server标签中执行
break: 将rewrite后的地址在当前location标签中执行

last      相当于Apache里的[L]标记,表示完成rewrite
break     终止匹配, 不再匹配后面的规则
redirect  返回302临时重定向,地址栏会显示跳转后的地址
permanent 返回301永久重定向,地址栏会显示跳转后的地址

4.一些可用的全局变量有,可以用做条件判断
$args              此变量与请求行中的参数相等
$content_length    等于请求行的"Content_Length"的值。
$content_type      等同与请求头部的"Content_Type"的值
$document_root     等同于当前请求的root指令指定的值
$document_uri      与$uri一样
$host              与请求头部中"Host"行指定的值或是request到达的server的名字（没有Host行）一样
$limit_rate        允许限制的连接速率
$request_method    等同于request的method,通常是"GET"或"POST"
$remote_addr       客户端ip
$remote_port       客户端port
$remote_user       等同于用户名,由ngx_http_auth_basic_module认证
$request_filename  当前请求的文件的路径名,由root或alias和URI request组合而成
$request_body_file
$request_uri       含有参数的完整的初始URI
$query_string      与$args一样
$server_protocol   等同于request的协议,使用"HTTP/1.0"或"HTTP/1.1"
$server_addr request  到达的server的ip,一般获得此变量的值的目的是进行系统调用。为了避免系统调用,有必要在listen指令中指明ip,并使用bind参数。
$server_name       请求到达的服务器名
$server_port       请求到达的服务器的端口号
$uri               等同于当前request中的URI,可不同于初始值,例如内部重定向时或使用index

5.常用分组语法
捕获
(exp)   匹配exp,并捕获文本到自动命名的组里
(?exp)  匹配exp,并捕获文本到名称为name的组里,也可以写成(?'name'exp)
(?:exp) 匹配exp,不捕获匹配的文本,也不给此分组分配组号

零宽断言
(?=exp)  匹配exp前面的位置
(?<=exp) 匹配exp后面的位置
(?!exp)  匹配后面跟的不是exp的位置
(?<!exp) 匹配前面不是exp的位置