#!/usr/bin/python
#!-*- coding:utf8 -*-
import time

from bs4 import BeautifulSoup
import urllib2
import requests
import re
import cPickle
import json


# 'group::topic':500,
AlarmList= {
'snookerGroup:social_like_event_online_topic:ZK':2000,
'sanda:sanda_product_push:KF':10000000,
}

TestList = [
'flume:sanda_hive:KF',
'test:keep-ping:KF'
]

topiclist='http://p-kafka-01:9000/clusters/kafka/topics'
r = requests.get(topiclist).content

rs = BeautifulSoup(r, "html.parser")

trs = rs.find_all("table")[1]

OffsetAll = {}

try:
    pkl_file = open('/tmp/kafka.pkl','rb')
    OffsetOld = cPickle.load(pkl_file)
    pkl_file.close()
except:
    pass
#print OffsetOld

#Alarm = ''

payload = []

log = {}

for t in trs.find_all('a'):
    topic = t.text
    if topic != '__consumer_offsets':
        topicurl='http://p-kafka-01:9000/clusters/kafka/topics/%s' %topic
        g = requests.get(topicurl).content
        gs = BeautifulSoup(g, "html.parser")
        tgs = gs.find_all("table")[4]
        for tr in tgs.find_all('tr'):
            group = tr.find_all("td")[0].a.text
            Type = tr.find_all("td")[1].text
            if not group.startswith('console-consumer-') and not group.startswith('Python-consumer'):
                lagurl = 'http://p-kafka-01:9000/clusters/kafka/consumers/%s/topic/%s/type/%s' %(group, topic, Type)
                l = requests.get(lagurl).content
                ls = BeautifulSoup(l, "html.parser")

                lag = ls.find_all("table")[0].find_all("td")[1].text
                #print lag
                #print "%s   %s   %s" %(group, topic, lag)
                GroupKey = '%s:%s:%s' %(group, topic, Type)

                Offset = 0
                for f in ls.find_all("table")[1].find_all("tr")[1:]:
                    #print f.find_all("td")[2].text
                    PartitionOffset = int(f.find_all("td")[2].text.strip())
                    Offset = Offset + PartitionOffset
  print GroupKey,Offset
                OffsetAll[GroupKey] = Offset
                try:
                    rate = Offset - OffsetOld[GroupKey]
                except:
                    rate = 0
  try:
                    log[GroupKey] = [int(lag), Offset, rate]
                except:
                    continue

                if GroupKey in AlarmList:
                    if int(lag) > AlarmList[GroupKey]:

                        if GroupKey == 'sanda:sanda_push:KF':
                            if rate < 500:
                                #Alarm = '%s[%s] %s' %(GroupKey, lag, Alarm)
                                value = lag
                            else:
                                value = 0
                        else:
                            #Alarm = '%s[%s] %s' %(GroupKey, lag, Alarm)
                            value = lag
                    else:
                        value = 0

                elif GroupKey in TestList:
                    continue
                else:
                    if int(lag) > 1000:
                        #Alarm = '%s[%s] %s' %(GroupKey, lag, Alarm)
                        value = lag
                    else:
                        value = 0


                ts = int(time.time())
                payload.append(
                    {
                        "endpoint": "p-kafka-01",
                        "metric": "kafka.group.lag.alarm",
                        "timestamp": ts,
                        "step": 60,
                        "value": value,
                        "counterType": "GAUGE",
                        "tags": "topic=%s,group=%s,type=%s" %(topic,group,Type),
                    }
                )

                payload.append(
                    {
                        "endpoint": "p-kafka-01",
                        "metric": "kafka.group.lag",
                        "timestamp": ts,
                        "step": 60,
                        "value": lag,
                        "counterType": "GAUGE",
                        "tags": "topic=%s,group=%s,type=%s" %(topic,group,Type),
                    }
                )
                #print GroupKey,value




    #raw_input()
#print OffsetAll
pkl_file = open('/tmp/kafka.pkl','wb')
cPickle.dump(OffsetAll,pkl_file)
pkl_file.close()


f = file('/tmp/kafka.log', 'a')
f.write(json.dumps(log))
f.write('\n')
f.flush()
f.close()

r = requests.post("http://127.0.0.1:1988/v1/push", data=json.dumps(payload))