Build:
    docker build -t "192.168.11.247:5000/centos-6-6/nginx" .

Run:
    docker run -ti -d -v /root/nginx/file:/etc/nginx/file -p 2222:22 -p 8888:80 --name nginx 192.168.11.247:5000/centos-6-6/nginx
