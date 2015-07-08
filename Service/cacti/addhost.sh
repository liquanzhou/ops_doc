#!/bin/bash
php_cmd="/usr/local/php/bin"
#cacti cli home
c_c_home="/opt/www/cacti/cli"

function add_graph(){
        h_id=$1
        t_id=$2
        $php_cmd/php ${c_c_home}/add_graphs.php --host-id=${h_id} --graph-type=cg --graph-template-id=${t_id} 
}

function add_interface(){
        h_id=$1
        /usr/local/php/bin/php ${c_c_home}/add_graphs.php   --host-id=${h_id} --graph-type=ds --graph-template-id=2 --snmp-query-id=1 --snmp-query-type-id=16 --snmp-field=ifDescr --snmp-value="em1"
        /usr/local/php/bin/php ${c_c_home}/add_graphs.php   --host-id=${h_id} --graph-type=ds --graph-template-id=2 --snmp-query-id=1 --snmp-query-type-id=16 --snmp-field=ifDescr --snmp-value="eth0"
}

function add_tree(){
        h_id=$1
        /usr/local/php/bin/php ${c_c_home}/add_tree.php --host-id=${h_id} --type=node --node-type=host --tree-id=2

}

for ip in `cat allhost.txt`
do
    ret=`$php_cmd/php ${c_c_home}/add_device.php --description=$ip --ip=$ip --template=3 --version=1 --avail=snmp --community=public`
    echo $ret
    echo $ret | grep 'Success'
    result=$?
    if [ "${result}" -eq 0 ]
    then
        host_id=$(echo $ret|sed 's/^.*(\(.*\))$/\1/')
        echo "Add graph for $host_id"
#        php ${c_c_home}/add_data_query.php --host-id=$host_id --data-query-id=1 --reindex-method=1
        add_graph $host_id 4
        add_graph $host_id 11
        add_graph $host_id 38
        add_graph $host_id 40
        add_interface $host_id
        add_tree $host_id
    else
        echo "Fail"
        exit 1
    fi
done

