#!/usr/bin/python
# coding:utf-8

import json
import pycurl
import StringIO
import os
import ast
import sys
import requests

class check_rabbitmq():
    host_list=['update_search_data','policy_engine','anti_spam_text','anti_spam_snapshot_callback','anti_spam_text','anti_spam_video','proc_express','proc_post','proc_review','report','lite_invite_share_img','ratelimitprocess']
    rb_url='http://172.20.80.217:15672/api/queues/action_vhost'

    def check_message_ready(self):
        err_list='ERROR: pipi rabbitmq blocking. '
        try:
            r = requests.get(self.rb_url, auth=('mon', 'mon')).json()
            for Q in r:
                i = Q['name']
                if i in self.host_list:
                    messages_ready = Q['messages_ready']
                    if i == 'lite_invite_share_img':
                        num = 5
                    elif i == 'ratelimitprocess' or i == 'update_search_data':
                        num = 10000
                    else:
                        num = 500
                    if messages_ready > num:
                        err_list = err_list + "[%s:%s]" %(i, messages_ready)
        except:
            err_list = 'ERROR: pipi rabbitmq check requests %s fail' %self.rb_url

        if err_list != 'ERROR: pipi rabbitmq blocking. ':
            print err_list
            headers = {'Content-Type':'application/json'}
            ExpansionHost = {
                    "msgtype": "text",
                    "text": {
                        "content": err_list
                    }
                }
            RobotURL = 'https://oapi.dingtalk.com/robot/send?access_token=5b48d8828c249da5a5f236a6568d3bf7fbdd0540ca33964d6575245eca12d3ea'

            try:
                requests.post(url=RobotURL, headers=headers, data=json.dumps(ExpansionHost))
            except Exception as err:
                print str(err)

if __name__ == '__main__':
    sre=check_rabbitmq()
    sre.check_message_ready()