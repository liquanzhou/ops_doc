#/bin/bash
#saveToFile.sh

path='/opt/tarantool/'
port=33015

rm -f ${path}snap/*.bak
find ${path}snap/  -name "*.snap" -exec  rename .snap .bak {} \;

/usr/local/bin/tarantool -h 127.0.0.1 -p $port <<EOF
save snapshot
EOF

find ${path}xlog/ -name "*.xlog" -ctime +3 -exec rm -f {} \;