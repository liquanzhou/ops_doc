prometheus
普罗米修斯


https://prometheus.io/docs/introduction/comparison/

https://www.lijiaocn.com/%E9%A1%B9%E7%9B%AE/2018/08/03/prometheus-usage.html#%E8%AF%B4%E6%98%8E

# 存储数据默认 ./data 目录下
--storage.tsdb.path: This determines where Prometheus writes its database. Defaults to data/.
# 默认存储15天
--storage.tsdb.retention.time: This determines when to remove old data. Defaults to 15d. Overrides storage.tsdb.retention if this flag is set to anything other than default.
--storage.tsdb.retention.size: [EXPERIMENTAL] This determines the maximum number of bytes that storage blocks can use (note that this does not include the WAL size, which can be substantial). The oldest data will be removed first. Defaults to 0 or disabled. This flag is experimental and can be changed in future releases. Units supported: KB, MB, GB, PB. Ex: "512MB"



port  9090


# irate 斜率
# 定义变量  by(job, uri)   
# 显示变量  Legend format {{job}} {{uri}}


# hystrix_go_attempts    发出去的
sum(irate(hystrix_go_attempts{uri="/recdegrade/httpapi/recommend"}[1m])) by(job, uri) * 15

# xcmetrics_httpsrv_qps  接收到的
sum(irate(xcmetrics_httpsrv_qps{job="recdegrade.srv.ns",uri!="/recdegrade/httpapi/recommend"}[1m])) by(job,uri)


# 匹配5XX
sum (irate(nginx_http_requests_total{status=~"5.*"}[1m])*15) by(uri, status, src, tgt)



uri不匹配两个
uri!~"/audiospam/.*|/aa/bbb"

sum (irate(nginx_http_requests_total{status=~"5.*", job="srv-gateway", uri!~"/audiospam/.*|/aa/bbb"}[1m])*15)





http://172.20.82.3:9090/graph


dmz5xx
sum (irate(nginx_http_requests_total{status=~"5.*", job="dmz-gateway"}[1m])*30) by(uri, status, src, tgt)



srv5xx
sum (irate(nginx_http_requests_total{status=~"5.*", job="srv-gateway"}[1m])*30) by(uri, status, src, tgt)




http://172.20.82.3:9090/api/v1/query?query=sum%20(irate(nginx_http_requests_total%7Bstatus%3D~%225.*%22%2C%20job%3D%22dmz-gateway%22%7D%5B1m%5D)*30)%20by(uri%2C%20status%2C%20src%2C%20tgt)&time=1562813950.632&_=1562760305540



url = 'http://172.20.82.3:9090/api/v1/query?query=sum(irate(hystrix_go_errors%7Buri!~%22%2Fadsrv%2Fhttpapi%2Ffetch_review_ad%7C%2Fadsrv%2Fhttpapi%2Ffetch_feed_ad%7C%2Frecommend%2Franking%7C%2Frecrank%2Fhttpapi%2Frank_with_pb%22%2C%20job!~%22pp-gateway-search%7Csearch-api-c%22%7D%5B1m%5D))%20by(job%2C%20uri)%20*%2030&time={0}&_={1}'.format(timestamp, (timestamp - 60)*1000)













