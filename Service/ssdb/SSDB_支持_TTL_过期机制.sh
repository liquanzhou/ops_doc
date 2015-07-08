SSDB 支持 TTL 过期机制


从 SSDB 1.6.7 版本开始, 增加了 Key 过期功能, 可以支持 Key 到期自动删除, 这样, SSDB 就可以作为一个持久化的缓存服务来使用. 该功能和 Redis 的 ttl/expire 一样, 使用方法是:

$ssdb->setx('key', 'value', 60);

这段代码表示, 设置 key=value, 同时到 60 秒后, 自动删除 key. 需要注意的是, TTL 只支持 KV 数据结构, hash(map) 和 zset 不支持.