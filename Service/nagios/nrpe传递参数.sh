/usr/local/nagios/libexec/check_nrpe -H 10.16.12.25 -c  check_nsq -a commentNotify



define command {
        command_name    check_nrpe_arg
        command_line    $USER1$/check_nrpe -H $HOSTADDRESS$ -c $ARG1$ -a $ARG2$
}

define service{
        use                      smc-service
        host_name                10.10.10.25
        service_description      Nsq_Json
        check_command            check_nrpe_arg!check_nsq!commentNotify
        contact_groups           quanzhou_test
        service_groups           Nsq
}


#nrpe
command[check_nsq]=/usr/local/nagios/libexec/check_nsq.py $ARG1$