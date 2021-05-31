Alertmanager普罗米修斯报警





https://github.com/prometheus/alertmanager



https://prometheus.io/download/






https://github.com/prometheus/alertmanager/releases/download/v0.17.0/alertmanager-0.17.0.linux-amd64.tar.gz



./alertmanager  --config.file alertmanager.yml


172.20.82.3:9093


/app/alertmanager-0.17.0.linux-amd64/alertmanager   --config.file   /app/alertmanager-0.17.0.linux-amd64/alertmanager.yml








http://172.20.82.3:9090/api/v1/query?query=sum(irate(hystrix_go_errors%7Buri!~%22%2Fadsrv%2Fhttpapi%2Ffetch_feed_ad%7C%2Frecommend%2Franking%7C%2Frecrank%2Fhttpapi%2Frank_with_pb%22%2C%20job!~%22pp-gateway-search%7Csearch-api-c%22%7D%5B1m%5D))%20by(job%2C%20uri)%20*%2030&time=1561983526.258&_=1561983303969

2019-07-01 20:18:46
2019-07-01 20:15:03


http://172.20.82.3:9090/api/v1/query?query=sum(irate(hystrix_go_errors%7Buri!~%22%2Fadsrv%2Fhttpapi%2Ffetch_feed_ad%7C%2Frecommend%2Franking%7C%2Frecrank%2Fhttpapi%2Frank_with_pb%22%2C%20job!~%22pp-gateway-search%7Csearch-api-c%22%7D%5B1m%5D))%20by(job%2C%20uri)%20*%2030&time=1562033829.982&_=1561983303970


2019-07-02 10:17:09
2019-07-01 20:15:03



http://172.20.82.3:9090/api/v1/query?query=sum(irate(hystrix_go_errors%7Buri!~%22%2Fadsrv%2Fhttpapi%2Ffetch_feed_ad%7C%2Frecommend%2Franking%7C%2Frecrank%2Fhttpapi%2Frank_with_pb%22%2C%20job!~%22pp-gateway-search%7Csearch-api-c%22%7D%5B1m%5D))%20by(job%2C%20uri)%20*%2030&time=1562033931.254&_=1562033918652

2019-07-02 10:18:51
2019-07-02 10:18:38



int(round(float(result['value'][1]),0))




http://pp-grafana.ixiaochuan.cn/d/j16attLmz/gatewaygai-lan?orgId=1&from=1562034456543&to=1562038056544




http://pp-grafana.ixiaochuan.cn/d/j16attLmz/gatewaygai-lan?orgId=1&from=1562034456543&to=1562038056544&fullscreen&panelId=10







http://pp-grafana.ixiaochuan.cn/d/j16attLmz/gatewaygai-lan?fullscreen&edit&tab=alert&panelId=10&orgId=1








http://pp-grafana.ixiaochuan.cn/d/j16attLmz/gatewaygai-lan?fullscreen&edit&tab=alert&panelId=10&orgId=1





http://pp-grafana.ixiaochuan.cn/d/j16attLmz/gatewaygai-lan?fullscreen&panelId=10&orgId=1





