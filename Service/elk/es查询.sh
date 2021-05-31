es查询


https://www.elastic.co/guide/cn/elasticsearch/guide/cn/_most_important_queries.html

GET _search
data = {
    "query": {
        "bool": {
            "must": [
                {
                    "terms": {
                        "http_host": ["api.ippzone.com", "pipi.izuiyou.com"]
                    }
                },
                {
                    "range": {
                        "@timestamp": {
                            "gt": "now-15m",
                            "lt": "now"
                        }
                    }
                },
                {
                    "range": {
                        "status": {
                            "gte": "500",
                            "lt": "600"
                        }
                    }
                }
            ]
        }
    }
}




gt   # 不包含
gte  # 包含 





