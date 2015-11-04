#!/bin/sh

check_time_line=`ps -ef|grep $1|grep -v grep|grep -v $0`

if [ -z  "$check_time_line" ]
then
  echo "process die!"
  exit 2
else
  echo " $1 run ok"
  exit 0
fi