#!/usr/bin/python
#encoding:utf8
import json,sys
import urllib2
import traceback

items=sys.argv[1]
if items == 'commentNotify':
        list='comment_notify=comment_submit_post'
elif items == 'commentDataTransfer':
        list='comment_data_transfer=channel1'
elif items == 'commentContent':
        list='event_comment_0=event_online+event_comment_1=event_online+event_comment_2=event_online+event_comment_3=event_online+event_comment_4=event_online+event_comment_5=event_online+event_comment_6=event_online+event_comment_7=event_online'
elif items == 'liveCommentV1':
        list='live_comment_v1=online_live'
elif items == 'liveUserInfo':
        list='live_user_info=10.10.68.153-37451,10.10.68.160-37451,10.10.68.161-37451,10.10.68.162-37451,10.10.68.163-37451,10.13.80.123-37451,10.13.80.124-37451'
elif items == 'newCommentSys':
        list='new_comment_sys=new_comment_distribution_online'
elif items == 'liveCommentV2':
        list='live_comment_v2=10.10.68.160-37451,10.10.68.161-37451,10.10.68.162-37451,10.10.68.163-37451,10.13.80.123-37451,10.13.80.124-37451'
elif items == 'newsComment':
        list='news_comment_0=chan1+news_comment_1=chan1+news_comment_2=chan1+news_comment_3=chan1+news_comment_4=chan1+news_comment_5=chan1+news_comment_7=chan1+news_comment_6=chan1'
elif items == 'agif':
        list='agif=test1'
elif items == 'operate':
        list='operate=op1'
else:
	print '%s error' %items
	sys.exit(1)
	

browser='Mozilla/5.0 (Windows NT 6.1)'

req_header = {'User-Agent':browser,
'Accept':'text/html;q=0.9,*/*;q=0.8',
'Accept-Charset':'ISO-8859-1,utf-8;q=0.7,*;q=0.3',
'Connection':'close',
'Referer':None
}

results = ""
mem = ""
disk = ""
json_status=0
for jsons in list.split('+'):
	link=jsons.split('=')[0]
	url="http://10.16.12.25:4172/topic/json/%s" %(link)
	req_timeout = 10
	req = urllib2.Request(url,None,req_header)
	try:
		resp = urllib2.urlopen(req,None,req_timeout)
		json_content = resp.read()
		s = json.loads(json_content)

		for i in jsons.split('=')[1].split(','):
			try:
				if sys.argv[2] == "null":
					status = s["ChannelStats"][i]['BackendDepth']
					if status != 0:
						results = "%s [%s %s:disk %s] " %(results,link,i,status)
						json_status = json_status + 1
					disk = "%s [%s] " %(disk,i)
				else:
					status = s["ChannelStats"][i]['MemoryDepth']
					if status > int(sys.argv[2]):
						results = "%s [%s %s:mem %s] " %(results,link,i,status)
						json_status = json_status + 1
					mem = "%s [%s %s] " %(mem,i,status)
			except Exception as err:
                		fff=file('/usr/local/nagios/libexec/check_nsq.log1','a')
                		fff.write('\n1111--------------------\n')
                		fff.write(str(err))
                		fff.write('\n1111--------------------\n')
                		fff.flush()
                		fff.close()
				results = "%s [%s %s NULL] " %(results,link,i)
				json_status = json_status + 1
	except Exception as err:
                fff=file('/usr/local/nagios/libexec/check_nsq.log1','a')
                fff.write('\n22222--------------------\n')
                fff.write(str(err))
                fff.write('\n22222--------------------\n')
                fff.flush()
                fff.close()

		print "nsq url timeout" 
		sys.exit(1)
if json_status == 0:
	if sys.argv[2] == "null":
		print "nsq OK %s" %disk
		sys.exit(0)
	else:
		print "nsq OK %s" %mem
		sys.exit(0)
else:
	print "nsq CRITICAL%s" %results
	sys.exit(2)
				


