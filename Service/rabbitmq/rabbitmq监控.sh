
rabbitmq监控

https://pulse.mozilla.org/doc/stats.html



import requests
import json

r = requests.get('http://localhost:15672/api/overview', auth=('admin', 'pGgEz2V^Gjh#Ol-#-OBjcKJs1~3hh4'))
print r.text

json.loads(r.text)
json.loads(r.text)['queue_totals']['messages_ready']






host=192.168.1.197
port=5672   
username=admin
passwd=xxxxxxxxxxxxxxxx
rabbitmq的概念
http://blog.csdn.net/whycold/article/details/41119807
rabbitmq的api
https://pulse.mozilla.org/doc/stats.html
https://pulse.mozilla.org/api/


脚本
 
import requests
import json
r = requests.get('http://localhost:15672/api/overview', auth=('admin', 'xxxxxxxxx'))
print r.text
print type(r.text)
json.loads(r.text)
json.loads(r.text)['queue_totals']['messages_ready']
json.loads(requests.get('http://localhost:15672/api/overview', auth=('admin', 'pGgEz2V^Gjh#Ol-#-OBjcKJs1~3hh4')).text)['queue_totals']['messages_ready']
json.loads(requests.get('http://localhost:15672/api/overview', auth=('admin', 'pGgEz2V^Gjh#Ol-#-OBjcKJs1~3hh4')).text)['queue_totals']['messages_unacknowledged']
 json.loads(requests.get('http://localhost:15672/api/overview', auth=('admin', 'pGgEz2V^Gjh#Ol-#-OBjcKJs1~3hh4')).text)['queue_totals']['messages']