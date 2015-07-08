flush_all 这个最简单的命令仅用于清理缓存中的所有名称/值对。如果您需要将缓存重置到干净的状态，则 flush_all 能提供很大的用处。

view plaincopy to clipboardprint?
set userId 0 0 5 
55555 
STORED 
get userId 
VALUE userId 0 5 
55555 
END 
flush_all 
OK 
get userId 
END  