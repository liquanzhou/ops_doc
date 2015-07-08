

mysql主从同步报[ERROR] Slave: Error 'Duplicate entry '3975250' for key 1' on query.  Error_code: 1062    
如果用slave-skip-errors = 1062   以后数据同步还是完整的么？

答
定期使用 pt-table-checksum 校验下 然后使用 pt-table-sync 定期修复下就好 一直跳过错误 不是最终的解决办法
