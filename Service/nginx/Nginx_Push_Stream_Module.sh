Nginx Push Stream Module 介绍

https://github.com/wandenberg/nginx-push-stream-module

Nginx Push Stream Module
A pure stream http push technology for your Nginx setup.

Comet made easy and really scalable.

Supports EventSource, WebSocket, Long Polling, and Forever Iframe. See some examples bellow.

This module is not distributed with the Nginx source. See the installation instructions.

Available on github at nginx_push_stream_module

Basic Configuration
    # add the push_stream_shared_memory_size to your http context
    http {
       push_stream_shared_memory_size 32M;

        # define publisher and subscriber endpoints in your server context
        server {
            location /channels-stats {
                # activate channels statistics mode for this location
                push_stream_channels_statistics;

                # query string based channel id
                push_stream_channels_path               $arg_id;
            }

            location /pub {
                # activate publisher mode for this location, with admin support
                push_stream_publisher admin;

                # query string based channel id
                push_stream_channels_path               $arg_id;

                # store messages in memory
                push_stream_store_messages              on;

                # Message size limit
                # client_max_body_size MUST be equal to client_body_buffer_size or
                # you will be sorry.
                client_max_body_size                    32k;
                client_body_buffer_size                 32k;
            }

            location ~ /sub/(.*) {
                # activate subscriber mode for this location
                push_stream_subscriber;

                # positional channel path
                push_stream_channels_path                   $1;
                if ($arg_tests = "on") {
                  push_stream_channels_path                 "test_$1";
                }

                # header to be sent when receiving new subscriber connection
                push_stream_header_template                 "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">\r\n<meta http-equiv=\"Cache-Control\" content=\"no-store\">\r\n<meta http-equiv=\"Cache-Control\" content=\"no-cache\">\r\n<meta http-equiv=\"Pragma\" content=\"no-cache\">\r\n<meta http-equiv=\"Expires\" content=\"Thu, 1 Jan 1970 00:00:00 GMT\">\r\n<script type=\"text/javascript\">\r\nwindow.onError = null;\r\ntry{ document.domain = (window.location.hostname.match(/^(\d{1,3}\.){3}\d{1,3}$/)) ? window.location.hostname : window.location.hostname.split('.').slice(-1 * Math.max(window.location.hostname.split('.').length - 1, (window.location.hostname.match(/(\w{4,}\.\w{2}|\.\w{3,})$/) ? 2 : 3))).join('.');}catch(e){}\r\nparent.PushStream.register(this);\r\n</script>\r\n</head>\r\n<body>";

                # message template
                push_stream_message_template                "<script>p(~id~,'~channel~','~text~','~event-id~', '~time~', '~tag~');</script>";
                # footer to be sent when finishing subscriber connection
                push_stream_footer_template                 "</body></html>";
                # content-type
                default_type                                "text/html; charset=utf-8";

                if ($arg_qs = "on") {
                  push_stream_last_received_message_time "$arg_time";
                  push_stream_last_received_message_tag  "$arg_tag";
                  push_stream_last_event_id              "$arg_eventid";
                }
            }

            location ~ /ev/(.*) {
                # activate event source mode for this location
                push_stream_subscriber eventsource;

                # positional channel path
                push_stream_channels_path                   $1;
                if ($arg_tests = "on") {
                  push_stream_channels_path                 "test_$1";
                }

                if ($arg_qs = "on") {
                  push_stream_last_received_message_time "$arg_time";
                  push_stream_last_received_message_tag  "$arg_tag";
                  push_stream_last_event_id              "$arg_eventid";
                }
            }

            location ~ /lp/(.*) {
                # activate long-polling mode for this location
                push_stream_subscriber      long-polling;

                # positional channel path
                push_stream_channels_path         $1;
                if ($arg_tests = "on") {
                  push_stream_channels_path                 "test_$1";
                }

                if ($arg_qs = "on") {
                  push_stream_last_received_message_time "$arg_time";
                  push_stream_last_received_message_tag  "$arg_tag";
                  push_stream_last_event_id              "$arg_eventid";
                }
            }

            location ~ /jsonp/(.*) {
                # activate long-polling mode for this location
                push_stream_subscriber      long-polling;

                push_stream_last_received_message_time "$arg_time";
                push_stream_last_received_message_tag  "$arg_tag";
                push_stream_last_event_id              "$arg_eventid";

                # positional channel path
                push_stream_channels_path         $1;
                if ($arg_tests = "on") {
                  push_stream_channels_path                 "test_$1";
                }
            }

            location ~ /ws/(.*) {
                # activate websocket mode for this location
                push_stream_subscriber websocket;

                # positional channel path
                push_stream_channels_path                   $1;
                if ($arg_tests = "on") {
                  push_stream_channels_path                 "test_$1";
                }

                # store messages in memory
                push_stream_store_messages              on;

                push_stream_websocket_allow_publish     on;

                if ($arg_qs = "on") {
                  push_stream_last_received_message_time "$arg_time";
                  push_stream_last_received_message_tag  "$arg_tag";
                  push_stream_last_event_id              "$arg_eventid";
                }
            }
        }
    }
Basic Usage
You can feel the flavor right now at the command line. Try using more than
one terminal and start playing http pubsub:

    # Subs
    curl -s -v 'http://localhost/sub/my_channel_1'
    curl -s -v 'http://localhost/sub/your_channel_1'
    curl -s -v 'http://localhost/sub/your_channel_2'

    # Pubs
    curl -s -v -X POST 'http://localhost/pub?id=my_channel_1' -d 'Hello World!'
    curl -s -v -X POST 'http://localhost/pub?id=your_channel_1' -d 'Hi everybody!'
    curl -s -v -X POST 'http://localhost/pub?id=your_channel_2' -d 'Goodbye!'

    # Channels Stats for publisher (json format)
    curl -s -v 'http://localhost/pub?id=my_channel_1'

    # All Channels Stats summarized (json format)
    curl -s -v 'http://localhost/channels-stats'

    # All Channels Stats detailed (json format)
    curl -s -v 'http://localhost/channels-stats?id=ALL'

    # Prefixed Channels Stats detailed (json format)
    curl -s -v 'http://localhost/channels-stats?id=your_channel_*'

    # Channels Stats (json format)
    curl -s -v 'http://localhost/channels-stats?id=my_channel_1'

    # Delete Channels
    curl -s -v -X DELETE 'http://localhost/pub?id=my_channel_1'

Some Examples  
Forever (hidden) iFrame
Event Source
WebSocket                   # https://github.com/wandenberg/nginx-push-stream-module/blob/master/docs/examples/websocket.textile#websocket
Long Polling                # https://github.com/wandenberg/nginx-push-stream-module/blob/master/docs/examples/long_polling.textile#long_polling
JSONP                       # https://github.com/wandenberg/nginx-push-stream-module/blob/master/docs/examples/long_polling.textile#jsonp
Other examples








用途
nginx的Push Stream Module使用http技术来实现连接管道，在项目里主要用于即时消息的推送，比如聊天功能。

Push Stream Module主要采用pub/sub模式来管理长连接，用户可以申请连接通道，通道建立订阅该通道，消息推送者可以向连接通道发送消息，这样订阅该通道的所有用户都可以接收到该消息。
安装

方法1：

[plain] view plaincopy
# clone the project  
git clone http://github.com/wandenberg/nginx-push-stream-module.git  
NGINX_PUSH_STREAM_MODULE_PATH=$PWD/nginx-push-stream-module  
cd nginx-push-stream-module  
  
# build with 1.0.x, 0.9.x, 0.8.x series  
./build.sh master 1.0.5  
cd build/nginx-1.0.5  
  
# install and finish  
sudo make install  
  
# check  
sudo /usr/local/nginx/sbin/nginx -v  
nginx version: nginx/1.0.5  
  
# test configuration  
sudo /usr/local/nginx/sbin/nginx -c $NGINX_PUSH_STREAM_MODULE_PATH/misc/nginx.conf -t  
the configuration file $NGINX_PUSH_STREAM_MODULE_PATH/misc/nginx.conf syntax is ok  
configuration file $NGINX_PUSH_STREAM_MODULE_PATH/misc/nginx.conf test is successful  
  
# run  
sudo /usr/local/nginx/sbin/nginx -c $NGINX_PUSH_STREAM_MODULE_PATH/misc/nginx.conf  
方法2：
[plain] view plaincopy
# clone the project  
git clone http://github.com/wandenberg/nginx-push-stream-module.git  
NGINX_PUSH_STREAM_MODULE_PATH=$PWD/nginx-push-stream-module  
  
# get desired nginx version (works with 1.0.x, 0.9.x, 0.8.x series)  
wget http://nginx.org/download/nginx-1.0.5.tar.gz  
  
# unpack, configure and build  
tar xzvf nginx-1.0.5.tar.gz  
cd nginx-1.0.5  
./configure --add-module=../nginx-push-stream-module  
make  
  
# install and finish  
sudo make install  
  
# check  
sudo /usr/local/nginx/sbin/nginx -v  
nginx version: nginx/1.0.5  
  
# test configuration  
sudo /usr/local/nginx/sbin/nginx -c $NGINX_PUSH_STREAM_MODULE_PATH/misc/nginx.conf -t  
the configuration file $NGINX_PUSH_STREAM_MODULE_PATH/misc/nginx.conf syntax is ok  
configuration file $NGINX_PUSH_STREAM_MODULE_PATH/misc/nginx.conf test is successful  
  
# run  
sudo /usr/local/nginx/sbin/nginx -c $NGINX_PUSH_STREAM_MODULE_PATH/misc/nginx.conf  
基本配置
1. 订阅通道，服务器收到订阅请求，如果通道不存在则会建立通道，配置如下：

[plain] view plaincopy
location ~ /sub/(.*) {  
        # activate subscriber (streaming) mode for this location  
        push_stream_subscriber;  
  
        # positional channel path  
        set $push_stream_channels_path              $1;  
}  
push_stream_subscriber指令用于指定该location用来订阅通道；$push_stream_channels_path参数指定要订阅的通道。

2. 向指定的通道发送发送消息，配置如下：

[plain] view plaincopy
location /pub {  
        # activate publisher (admin) mode for this location  
        push_stream_publisher admin;  
  
        # query string based channel id  
        set $push_stream_channel_id             $arg_id;  
}  
3. 查看通道状态，通过该设置可以查看服务器上的所有或者指定的通道数，通道的订阅数，发送过的消息数量等等，基本配置如下：
[plain] view plaincopy
location /stats {  
        # activate channels statistics mode for this location  
        push_stream_channels_statistics;  
  
        # query string based channel id  
        set $push_stream_channel_id             $arg_id;  
}  

基本用法
配置好并重启nginx之后就可以开始使用Push Stream Module了。

在session A中订阅通道：

[plain] view plaincopy
curl http://comet.com/sub/my_channel_1  

可以看见此时还未有任何返回信息；
在session B中向该通道发送消息：

[plain] view plaincopy
curl -d hello http://comet.com/pub?id=my_channel_1  
收到json格式的返回数据：{"channel": "my_channel_1", "published_messages": "1", "stored_messages": "0", "subscribers": "1"}；
切回session A可以看见接收到的消息hello；

在session B中查看通道状态：

[plain] view plaincopy
curl http://comet.com/stats；  
curl http://comet.com/stats?id=my_channel_1;  
curl http://comet.com/stats?id=my_channel_*;  
接收到统计数据：{"hostname": "local", "time": "2012-09-08T11:09:52", "channels": "0", "broadcast_channels": "0", "published_messages": "2", "subscribers": "0", "uptime": "867", "by_worker": [
{"pid": "12072", "subscribers": "0", "uptime": "719"}]}；
在session B中删除通道：

[plain] view plaincopy
curl -X DELETE 'http://comet.com/pub?id=my_channel_1'  
参考文章：http://wiki.nginx.org/HttpPushStreamModule