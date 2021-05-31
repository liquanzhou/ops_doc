#!/usr/bin/python
import sys
import requests
try:
        url = sys.argv[1]
        r = requests.get('http://%s' %url ,timeout=3)
except requests.exceptions.Timeout:
        print 'url timeout\n%s' %url
        sys.exit(2)

except:
        print 'url error \n%s' %url
        sys.exit(2)

url_status = r.status_code

if url_status == 200:
        print 'url_status %s\n%s' %(url_status,url)
        sys.exit(0)

else:
        print 'url_status %s\n%s' %(url_status,url)
        sys.exit(2)