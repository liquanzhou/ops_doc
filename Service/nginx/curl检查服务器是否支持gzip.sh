
curl检查服务器是否支持gzip


方法如下

curl -I -H ‘Accept-Encoding: gzip,deflate’ -H “Host:域名”  http://ip/url
如果结果是
HTTP/1.1 200 OK
Server: nginx/0.8.52
Date: Tue, 05 Jul 2011 01:28:30 GMT
Content-Type: application/x-javascript
Last-Modified: Tue, 10 Aug 2010 00:33:24 GMT
Connection: keep-alive
Vary: Accept-Encoding
Expires: Thu, 04 Aug 2011 01:28:30 GMT
Cache-Control: max-age=2592000
Content-Encoding: gzip  很好支持

如果没有 Content-Encoding: gzip 就不支持gzip