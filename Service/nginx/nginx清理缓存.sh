清理此文件缓存
http://192.168.1.1/test.js

访问如下地址
curl -s http://192.168.1.1/purge/test.js



location ~ .*\.(apk|zip)$ {
		proxy_cache cache_two;
		proxy_cache_valid 200 304 12h;
		proxy_cache_key $uri;
		proxy_pass http://wap_pool;
		proxy_set_header Host $host;
		proxy_set_header X-Forwarded-For $remote_addr;
		expires 30d;
}


# 清楚nginx缓存
location ~ /purge(/.*) {
        allow    all;
        proxy_cache_purge    cache_one   $1;
}

location ~ /purge2(/.*) {
        allow    all;
        proxy_cache_purge    cache_two    $1;
}