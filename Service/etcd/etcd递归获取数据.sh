etcd递归获取数据


https://coreos.com/etcd/docs/0.4.7/etcd-api/

curl -s '10.252.44.111:2379/v2/keys/v1/production/services?recursive=true&sorted=true'


import json
import urllib2
response = urllib2.urlopen('http://10.252.44.111:2379/v2/keys/v1/production/services?recursive=true&sorted=true')
data = json.loads(response.read())
for i in data['node']['nodes']:
    print i['key']
    for u in i['nodes']:
        print u['key']
