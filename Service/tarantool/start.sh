#!/bin/bash
#pid=`cat box.pid`
#kill -9 $pid
#tarantool_box -c tarantool.cfg --init-storage
tarantool_box -c tarantool.cfg --background

