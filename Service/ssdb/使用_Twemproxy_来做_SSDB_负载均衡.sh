
使用 Twemproxy 来做 SSDB 负载均衡


Twemproxy 是由 Twitter 公司开发的一个支持 Redis 协议的代理服务器, 可用于 Redis 集群的负载均衡, 高可用性等.

SSDB 数据库也支持 Redis 协议, 所以可以直接使用 Twemproxy 而不需要做任何特殊改动, 如果你原来使用 Redis 现在切换到 SSDB 的话. 你不仅可以使用 Twemproxy + SSDB, 还可以使用 Twemproxy + SSDB + Redis.

已有多个用户在线上业务中使用了 Twemproxy + SSDB 的架构.

Twemproxy 项目地址: https://github.com/twitter/twemproxy
Related posts:

    SSDB 采用里程碑式版本发布机制
    SSDB 增加了 Compaction 限速功能
    SSDB 已经迁移到 github
    性能超越 Redis 的 NoSQL 数据库 SSDB
    SSDB 支持 TTL 过期机制

Posted by ideawu at 2014-06-30 14:54:59 Tags: Redis, twemproxy	