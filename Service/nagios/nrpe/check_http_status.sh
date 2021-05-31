#!/bin/sh

check=`curl -o /dev/null -s -m 10 --connect-timeout 10 -w %{http_code}  $1`


if [ "$check" == "200" ]
then
    echo "$1 is ok"
    exit 0
else
    echo "$1 Status: $check"
    exit 2
fi