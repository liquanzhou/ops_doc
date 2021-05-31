开启nginx状态页面


server {
    listen 9999;
    server_name _;

    location /server-status {
            stub_status on;
            access_log off;
            allow 127.0.0.1;
            allow 192.168.0.0/16;
            allow 10.0.0.0/8;
            deny all;
    }
    location /resin_status {
            check_status;
            access_log   off;
            allow 10.0.0.0/8;
            allow 192.168.0.0/16;
            allow 127.0.0.1;
            deny all;
    }
}