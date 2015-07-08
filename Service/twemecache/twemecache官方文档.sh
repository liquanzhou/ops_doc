twemecache

https://github.com/twitter/twemcache

Twemcache: Twitter Memcached Build Status

Twemcache (pronounced "two-em-cache") is the Twitter Memcached. Twemcache is based on a fork of Memcached v.1.4.4 that has been heavily modified to make to suitable for the large scale production environment at Twitter.
Build

To build twemcache from distribution tarball:

$ ./configure
$ make
$ sudo make install

To build twemcache from distribution tarball with a non-standard path to libevent install:

$ ./configure --with-libevent=<path>
$ make
$ sudo make install

To build twemcache from distribution tarball with a statically linked libevent:

$ ./configure --enable-static=libevent
$ make
$ sudo make install

To build twemcache from distribution tarball in debug mode with assertion panics enabled:

$ CFLAGS="-ggdb3 -O0" ./configure --enable-debug=full
$ make
$ sudo make install

To build twemcache from source with debug logs enabled and assertions disabled:

$ git clone git@github.com:twitter/twemcache.git
$ cd twemcache
$ autoreconf -fvi
$ ./configure --enable-debug=log
$ make V=1
$ src/twemcache -h

Help

Usage: twemcache [-?hVCELdkrDS] [-o output file] [-v verbosity level]
           [-A stats aggr interval]
           [-t threads] [-P pid file] [-u user]
           [-x command logging entry] [-X command logging file]
           [-R max requests] [-c max conns] [-b backlog] [-p port] [-U udp port]
           [-l interface] [-s unix path] [-a access mask] [-M eviction strategy]
           [-f factor] [-m max memory] [-n min item chunk size] [-I slab size]
           [-z slab profile]

Options:
  -h, --help                  : this help
  -V, --version               : show version and exit
  -E, --prealloc              : preallocate memory for all slabs
  -L, --use-large-pages       : use large pages if available
  -k, --lock-pages            : lock all pages and preallocate slab memory
  -d, --daemonize             : run as a daemon
  -r, --maximize-core-limit   : maximize core file limit
  -C, --disable-cas           : disable use of cas
  -D, --describe-stats        : print stats description and exit
  -S, --show-sizes            : print slab and item struct sizes and exit
  -o, --output=S              : set the logging file (default: stderr)
  -v, --verbosity=N           : set the logging level (default: 5, min: 0, max: 11)
  -A, --stats-aggr-interval=N : set the stats aggregation interval in usec (default: 100000 usec)
  -t, --threads=N             : set number of threads to use (default: 4)
  -P, --pidfile=S             : set the pid file (default: off)
  -u, --user=S                : set user identity when run as root (default: off)
  -x, --klog-entry=N          : set the command logging entry number per thread (default: 512)
  -X, --klog-file=S           : set the command logging file (default: off)
  -R, --max-requests=N        : set the maximum number of requests per event (default: 20)
  -c, --max-conns=N           : set the maximum simultaneous connections (default: 1024)
  -b, --backlog=N             : set the backlog queue limit (default 1024)
  -p, --port=N                : set the tcp port to listen on (default: 11211)
  -U, --udp-port=N            : set the udp port to listen on (default: 11211)
  -l, --interface=S           : set the interface to listen on (default: all)
  -s, --unix-path=S           : set the unix socket path to listen on (default: off)
  -a, --access-mask=O         : set the access mask for unix socket in octal (default: 0700)
  -M, --eviction-strategy=N   : set the eviction strategy on OOM (default: 2, random)
  -f, --factor=D              : set the growth factor of slab item sizes (default: 1.25)
  -m, --max-memory=N          : set the maximum memory to use for all items in MB (default: 64 MB)
  -n, --min-item-chunk-size=N : set the minimum item chunk size in bytes (default: 72 bytes)
  -I, --slab-size=N           : set slab size in bytes (default: 1048576 bytes)
  -z, --slab-profile=S        : set the profile of slab item chunk sizes (default: off)

Features

    Supports the complete memcached ASCII protocol.
    Supports tcp, udp and unix domain sockets.
    Observability through lock-less stats collection and klogger.
    Pluggable eviction strategies.
    Easy debuggability through assertions and logging.

Slabs and Items

Memory in twemcache is organized into fixed sized slabs whose size is configured using the -I or --slab-size=N command-line argument. Every slab is carved into a collection of contiguous, equal size items. All slabs that are carved into items of a given size belong to a given slabclass. The number of slabclasses and the size of items they serve can be configured either from a geometric sequence with the inital item size set using -n or --min-item-chunk-size=N argument and growth ratio set using -f or --factor=D argument, or from a profile string set using -z or --slab-profile=S argument.
Eviction

Eviction is triggered when a cache reaches full memory capacity. This happens when all cached items are unexpired and there is no space available to store newer items. Twemcache supports the following eviction strategies, configured using the -M or --eviction-strategy=N command-line argument:

    No eviction (0) - do not evict, respond with server error reply.
    Item LRU eviction (1) - evict only existing items in the same slab class, least recently updated first; essentially a per-slabclass LRU eviction.
    Random eviction (2) - evict all items from a randomly chosen slab.
    Slab LRA eviction (4) - choose the least recently accessed slab, and evict all items from it to reuse the slab.
    Slab LRC eviction (8) - choose the least recently created slab, and evict all items from it to reuse the slab. Eviction ignores freeq & lruq to make sure the eviction follows the timestamp closely. Recommended if cache is updated on the write path.

Eviction strategies can be stacked, in the order of higher to lower bit. For example, -M 5 means that if slab LRU eviciton fails, Twemcache will try item LRU eviction.
Observability
Stats

Stats are the primary form of observability in twemcache. Stats collection in twemcache is lock-less in a sense that each worker thread only updates its thread-local metrics, and a background aggregator thread collects metrics from all threads periodically, holding only one thread-local lock at a time. Once aggregated, stats polling comes for free. There is a slight trade-off between how up-to-date stats are and how much burden stats collection puts on the system, which can be controlled by the aggregation interval -A or --stats-aggr-interval=N command-line argument. By default, the aggregation interval is set to 100 msec. You can set the aggregation interval at run time using config aggregate <num>\r\n command. Stats collection can be disabled at run time by passing a negative aggregation interval or at build time through the --disable-stats configure option.

Metrics exposed by twemcache are of three types - timestamp, counter and gauge and are collected both at the global level and per slab level. You can read about the description of all stats exposed by twemcache using the -D or --describe-stats command-line argument.

The following commands can be used to query stats from a running twemcache

    stats\r\n
    stats settings\r\n
    stats slabs\r\n
    stats sizes\r\n
    stats cachedump <id> <limit>\r\n

Klogger (Command Logger)

Command logger allows users to capture the details of every incoming request. Each line of the command log gives precise information on the client, the time when a request was received, the command header including the command, key, flags and data length, a return code, and reply message length. Few example klog lines look as follows:

172.25.135.205:55438 - [09/Jul/2012:18:15:45 -0700] "set foo 0 0 3" 1 6
172.25.135.205:55438 - [09/Jul/2012:18:15:46 -0700] "get foo" 0 14
172.25.135.205:55438 - [09/Jul/2012:18:15:57 -0700] "incr num 1" 3 9
172.25.135.205:55438 - [09/Jul/2012:18:16:05 -0700] "set num 0 0 1" 1 6
172.25.135.205:55438 - [09/Jul/2012:18:16:09 -0700] "incr num 1" 0 1
172.25.135.205:55438 - [09/Jul/2012:18:16:13 -0700] "get num" 0 12

The command logger supports lockless read/write into ring buffers, whose size can be configured with -x or --klog-entry=N command-line argument. Each worker thread logs to a thread-local buffer as they process incoming queries, and a background thread asynchronously dumps buffer contents to a file configured with -X or --klog-file=S command-line argument.

Since this feature has the capability of generating hundreds of MBs of data per minute, the use must be planned carefully. An enabled klog moduled can be started or stopped by sending config klog run start\r\n and config klog run stop\r\n respectively. To control the speed of log generation, the command logger also supports sampling. Sample rate can be set over with config klog sampling <num>\r\n command, which samples one of num commands.
Logging

Logging in twemcache is only available when it is built with logging enabled (--enable-debug=[full|yes|log]). By default logs are written to stderr. Twemcache can also be configured to write logs to a specific file through the -o or --output=S command-line argument.

On a running twemcache, we can turn log levels up and down by sending it SIGTTIN and SIGTTOU signals respectively and reopen log files by sending it SIGHUP signal. Logging levels can be set to a specific value using the verbosity <num>\r\n command.
Issues and Support

Have a bug? Please create an issue here on GitHub!

https://github.com/twitter/twemcache/issues
Versioning

For transparency and insight into our release cycle, releases are be numbered with the semantic versioning format: <major>.<minor>.<patch> and constructed with the following guidelines:

    Breaking backwards compatibility bumps the major
    New additions without breaking backwards compatibility bumps the minor
    Bug fixes and misc changes bump the patch

Other Work

    twemproxy - a fast, light-weight proxy for memcached.
    twemperf - a tool for measuring memcached server performance.
    twctop.rb - a tool like top for monitoring a cluster of twemcache servers.

Contributors

    Manju Rajashekhar (@manju)
    Yao Yue (@thinkingfish)

License

Copyright 2003, Danga Interactive, Inc.

Copyright 2012 Twitter, Inc.

Licensed under the New BSD License, see the LICENSE file.