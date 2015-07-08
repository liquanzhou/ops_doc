#!/usr/bin/python
import json,sys
import urllib2

dic = {"agif":["test1"],
	"news_comment_0":["chan1"],
	"news_comment_1":["chan1"],
	"news_comment_2":["chan1"],
	"news_comment_3":["chan1"],
	"news_comment_4":["chan1"],
	"news_comment_5":["chan1"],
	"news_comment_6":["chan1"],
	"news_comment_7":["chan1"],
	}

browser='Mozilla/5.0 (Windows NT 6.1)'

req_header = {'User-Agent':browser,
'Accept':'text/html;q=0.9,*/*;q=0.8',
'Accept-Charset':'ISO-8859-1,utf-8;q=0.7,*;q=0.3',
'Connection':'close',
'Referer':None
}

results = ""
json_status=0
for link,key in dic.items() :
	url="http://10.16.12.25:4172/topic/json/%s" %(link)
	
	req_timeout = 5
	req = urllib2.Request(url,None,req_header)
	try:
		resp = urllib2.urlopen(req,None,req_timeout)
		json_content = resp.read()
		s = json.loads(json_content)

		for i in key:
			try:
				status = s["ChannelStats"][i]['BackendDepth']
				if status != 0:
					results = "%s [%s %s:%s] " %(results,link,i,status)
					json_status = json_status + 1
			except:
				results = "%s [%s %s NULL] " %(results,link,i)
				json_status = json_status + 1
	except:
		results = "%s [%s timeout]" %(results,link)
		json_status = json_status + 1

if json_status == 0:
	print "nsq OK"
	sys.exit(0)
else:
	print "nsq CRITICAL%s" %results
	sys.exit(2)
				
