import os

def dat():
	data = os.popen(''' awk -v RS='servicestatus {' 'NR!=1{print $0}' /usr/local/nagios/var/status.dat|awk -F 'host_name=|service_description=|current_state=|[^_]plugin_output=' '$2!=""{print $2}' |awk '{if (NR%4==0){print $0} else {printf"%s ",$0"=="}}' ''').read().strip()
	return data

def all():
	statustmp = dat().split('\n')
	dic = {}
	for line in statustmp:
		i=line.split('== ')
		if len(i) == 4:
			if i[0] in dic.keys():
				key = dic[i[0]]
			else:
				key = []
			key.append([i[1],i[2],i[3]])
			dic[i[0]]=key
	return dic

def ipservice(ip):
	dic = all()

	if ip not in dic.keys():
		for i in dic.keys():
			if i.endswith(ip):
				ip=i
				break
	return dic[ip]

def dangerous():
	statustmp = dat().split('\n')
	dic = {}

	for line in statustmp:
		i=line.split('== ')
		if len(i) == 4 and i[2] != "0":
			if i[0] in dic.keys():
				key = dic[i[0]]
			else:
				key = []
			key.append([i[1],i[2],i[3]])
			dic[i[0]]=key
	print dic
	return dic

#if __name__ == '__main__':
	#ipservice('10.16.0.168')
	#dangerous()
	#all()
