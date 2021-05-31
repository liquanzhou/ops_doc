
./redis-cli -h 10.10.10.11 -p 6401

save  # 保存当前快照

# 列出所有当前配置
config get *

# 查看指定配置
config get maxmemory

# 动态修改配置参数
config set maxmemory  15360000000






