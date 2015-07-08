#!/bin/sh

EXEC=/usr/bin/scribed
CTRLEXEC=/usr/bin/scribe_ctrl
LOG=/dev/null
CONF="/opt/scribe/conf/scribe.conf"
PORT=1464

case "$1" in
    start)
        echo "Starting scribe at port ${PORT}......"
        retval=0
        ${CTRLEXEC} status > /dev/null
        if [ $? -eq 2 ];
        then
            echo "Process Already Running......"
        else
            ${EXEC} ${CONF} 2>>${LOG} >>${LOG} &
            echo "Started."
        fi
        ;;
    stop)
        ${CTRLEXEC} stop ${PORT} > /dev/null
        if [ $? -eq 0 ]; 
        then
            echo "Stoped."
        else
            echo "Fail to stop..."
        fi
        ;;
    counters)
        ${CTRLEXEC} counters
        ;;
    status)
        ${CTRLEXEC} status 
        ;;
    alive)
        ${CTRLEXEC} alive
        ;;
    *)
        echo 'Usage: sh scribe_admin.sh command'
        echo 'commands: [start | stop | counters | status | alive]'
        ;;
esac
