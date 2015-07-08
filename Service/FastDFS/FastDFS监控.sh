[root@localhost ~]# /usr/local/fastdfs/bin/fdfs_monitor /usr/local/fastdfs/conf/storage.conf

[2014-05-27 15:14:58] DEBUG - base_path=/opt/fastdfs/contact, connect_timeout=30, network_timeout=60, tracker_server_count=2, anti_steal_token=0, anti_steal_secret_key length=0, use_connection_pool=0, g_connection_pool_max_idle_time=3600s, use_storage_id=0, storage server id count: 0

server_count=2, server_index=1

tracker server is 10.0.0.57:22122

group count: 1

Group 1:
group name = contact
disk total space = 1380838 MB
disk free space = 812573 MB
trunk free space = 0 MB
storage server count = 1
active server count = 1
storage server port = 23000
storage HTTP port = 8888
store path count = 1
subdir count per path = 256
current write server index = 0
current trunk file id = 0

        Storage 1:
                id = 10.0.0.58
                ip_addr = 10.0.0.58  ACTIVE
                http domain = 
                version = 4.07
                join time = 2013-08-07 14:05:30
                up time = 2013-12-31 09:48:17
                total storage = 1380838 MB
                free storage = 812573 MB
                upload priority = 10
                store_path_count = 1
                subdir_count_per_path = 256
                storage_port = 23000
                storage_http_port = 8888
                current_write_path = 0
                source storage id= 
                if_trunk_server= 0
                total_upload_count = 145463987
                success_upload_count = 145463987
                total_append_count = 0
                success_append_count = 0
                total_modify_count = 0
                success_modify_count = 0
                total_truncate_count = 0
                success_truncate_count = 0
                total_set_meta_count = 0
                success_set_meta_count = 0
                total_delete_count = 55020068
                success_delete_count = 55020068
                total_download_count = 0
                success_download_count = 0
                total_get_meta_count = 0
                success_get_meta_count = 0
                total_create_link_count = 0
                success_create_link_count = 0
                total_delete_link_count = 0
                success_delete_link_count = 0
                total_upload_bytes = 55349210207
                success_upload_bytes = 55349210207
                total_append_bytes = 0
                success_append_bytes = 0
                total_modify_bytes = 0
                success_modify_bytes = 0
                stotal_download_bytes = 0
                success_download_bytes = 0
                total_sync_in_bytes = 17409030985
                success_sync_in_bytes = 17371905709
                total_sync_out_bytes = 19884312270
                success_sync_out_bytes = 19867906118
                total_file_open_count = 195455141
                success_file_open_count = 190330634
                total_file_read_count = 0
                success_file_read_count = 0
                total_file_write_count = 190330634
                success_file_write_count = 190330634
                last_heart_beat_time = 2014-05-27 15:14:31
                last_source_update = 2014-05-27 15:14:25
                last_sync_update = 2013-10-14 14:18:36
                last_synced_timestamp = 2013-08-16 23:54:41 


# 主要是这里 只要是active的就没有问题

        Storage 1:
                id = 10.0.0.58
                ip_addr = 10.0.0.58  ACTIVE
                http domain = 



#!/bin/bash

results=""
statusValue=0
storageAll=`/usr/local/fastdfs/bin/fdfs_monitor /usr/local/fastdfs/conf/storage.conf|awk '/ip_addr/||/last_synced_timestamp/{print $3"=="$4}'|sed '$!N;s/\n/==/'`
currentTimeStamp=$(date +%s)
for storage in $storageAll
do
	IP=$(echo $storage |awk -F '==' '{print $1}')
	status=$(echo $storage |awk -F '==' '{print $2}')
	Time=$(echo $storage |awk -F '==' '{print $3,$4}')
	timeStamp=$(date -d "$Time" +%s)
	timeout=$((currentTimeStamp-timeStamp))

	if [ "$status" != "ACTIVE" -o $timeout -gt 120 ];then
		statusValue=$((statusValue+1))
	fi 
	results="$results[$IP $status timeout:$timeout]"
done

if [ $statusValue -eq 0 ];then
	echo "fastdfs OK $results"
	exit 0
else
	echo "fastdfs CRITICAL $results"
	exit 2
fi



