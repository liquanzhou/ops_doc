twemproxy 

https://github.com/twitter/twemproxy



$ ./configure
$ make
$ sudo make install



Usage: nutcracker [-?hVdDt] [-v verbosity level] [-o output file]
                  [-c conf file] [-s stats port] [-a stats addr]
                  [-i stats interval] [-p pid file] [-m mbuf size]

Options:
  -h, --help             : this help
  -V, --version          : show version and exit
  -t, --test-conf        : test configuration for syntax errors and exit
  -d, --daemonize        : run as a daemon
  -D, --describe-stats   : print stats description and exit
  -v, --verbosity=N      : set logging level (default: 5, min: 0, max: 11)
  -o, --output=S         : set logging file (default: stderr)
  -c, --conf-file=S      : set configuration file (default: conf/nutcracker.yml)
  -s, --stats-port=N     : set stats monitoring port (default: 22222)
  -a, --stats-addr=S     : set stats monitoring ip (default: 0.0.0.0)
  -i, --stats-interval=N : set stats aggregation interval in msec (default: 30000 msec)
  -p, --pid-file=S       : set pid file (default: off)
  -m, --mbuf-size=N      : set size of mbuf chunk in bytes (default: 16384 bytes)


Configuration

nutcracker can be configured through a YAML file specified by the -c or --conf-file command-line argument on process start. The configuration file is used to specify the server pools and the servers within each pool that nutcracker manages. The configuration files parses and understands the following keys:

    listen: The listening address and port (name:port or ip:port) for this server pool.
    hash: The name of the hash function. Possible values are:
        one_at_a_time
        md5
        crc16
        crc32 (crc32 implementation compatible with libmemcached)
        crc32a (correct crc32 implementation as per the spec)
        fnv1_64
        fnv1a_64
        fnv1_32
        fnv1a_32
        hsieh
        murmur
        jenkins
    hash_tag: A two character string that specifies the part of the key used for hashing. Eg "{}" or "$$". Hash tag enable mapping different keys to the same server as long as the part of the key within the tag is the same.
    distribution: The key distribution mode. Possible values are:
        ketama
        modula
        random
    timeout: The timeout value in msec that we wait for to establish a connection to the server or receive a response from a server. By default, we wait indefinitely.
    backlog: The TCP backlog argument. Defaults to 512.
    preconnect: A boolean value that controls if nutcracker should preconnect to all the servers in this pool on process start. Defaults to false.
    redis: A boolean value that controls if a server pool speaks redis or memcached protocol. Defaults to false.
    server_connections: The maximum number of connections that can be opened to each server. By default, we open at most 1 server connection.
    auto_eject_hosts: A boolean value that controls if server should be ejected temporarily when it fails consecutively server_failure_limit times. See liveness recommendations for information. Defaults to false.
    server_retry_timeout: The timeout value in msec to wait for before retrying on a temporarily ejected server, when auto_eject_host is set to true. Defaults to 30000 msec.
    server_failure_limit: The number of consecutive failures on a server that would lead to it being temporarily ejected when auto_eject_host is set to true. Defaults to 2.
    servers: A list of server address, port and weight (name:port:weight or ip:port:weight) for this server pool.

For example, the configuration file in conf/nutcracker.yml, also shown below, configures 5 server pools with names - alpha, beta, gamma, delta and omega. Clients that intend to send requests to one of the 10 servers in pool delta connect to port 22124 on 127.0.0.1. Clients that intend to send request to one of 2 servers in pool omega connect to unix path /tmp/gamma. Requests sent to pool alpha and omega have no timeout and might require timeout functionality to be implemented on the client side. On the other hand, requests sent to pool beta, gamma and delta timeout after 400 msec, 400 msec and 100 msec respectively when no response is received from the server. Of the 5 server pools, only pools alpha, gamma and delta are configured to use server ejection and hence are resilient to server failures. All the 5 server pools use ketama consistent hashing for key distribution with the key hasher for pools alpha, beta, gamma and delta set to fnv1a_64 while that for pool omega set to hsieh. Also only pool beta uses nodes names for consistent hashing, while pool alpha, gamma, delta and omega use 'host:port:weight' for consistent hashing. Finally, only pool alpha and beta can speak redis protocol, while pool gamma, deta and omega speak memcached protocol.

alpha:
  listen: 127.0.0.1:22121
  hash: fnv1a_64
  distribution: ketama
  auto_eject_hosts: true
  redis: true
  server_retry_timeout: 2000
  server_failure_limit: 1
  servers:
   - 127.0.0.1:6379:1

beta:
  listen: 127.0.0.1:22122
  hash: fnv1a_64
  hash_tag: "{}"
  distribution: ketama
  auto_eject_hosts: false
  timeout: 400
  redis: true
  servers:
   - 127.0.0.1:6380:1 server1
   - 127.0.0.1:6381:1 server2
   - 127.0.0.1:6382:1 server3
   - 127.0.0.1:6383:1 server4

gamma:
  listen: 127.0.0.1:22123
  hash: fnv1a_64
  distribution: ketama
  timeout: 400
  backlog: 1024
  preconnect: true
  auto_eject_hosts: true
  server_retry_timeout: 2000
  server_failure_limit: 3
  servers:
   - 127.0.0.1:11212:1
   - 127.0.0.1:11213:1

delta:
  listen: 127.0.0.1:22124
  hash: fnv1a_64
  distribution: ketama
  timeout: 100
  auto_eject_hosts: true
  server_retry_timeout: 2000
  server_failure_limit: 1
  servers:
   - 127.0.0.1:11214:1
   - 127.0.0.1:11215:1
   - 127.0.0.1:11216:1
   - 127.0.0.1:11217:1
   - 127.0.0.1:11218:1
   - 127.0.0.1:11219:1
   - 127.0.0.1:11220:1
   - 127.0.0.1:11221:1
   - 127.0.0.1:11222:1
   - 127.0.0.1:11223:1

omega:
  listen: /tmp/gamma
  hash: hsieh
  distribution: ketama
  auto_eject_hosts: false
  servers:
   - 127.0.0.1:11214:100000
   - 127.0.0.1:11215:1

Finally, to make writing syntactically correct configuration file easier, nutcracker provides a command-line argument -t or --test-conf that can be used to test the YAML configuration file for any syntax error.
