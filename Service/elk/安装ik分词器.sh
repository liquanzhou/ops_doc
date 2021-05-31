安装ik分词器

与es小版本也必须对应

地址：https://github.com/medcl/elasticsearch-analysis-ik/releases
wget https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v6.5.4/elasticsearch-analysis-ik-6.5.4.zip

将这个解压到 /app/elasticsearch/plugins/ik
# 目录下不要有zip包

拼音分词器
地址：https://github.com/medcl/elasticsearch-analysis-pinyin/releases
wget https://github.com/medcl/elasticsearch-analysis-pinyin/releases/download/v6.5.4/elasticsearch-analysis-pinyin-6.5.4.zip

解压到  /app/elasticsearch/plugins/pinyin


逐台重启集群