curl -XPUT -D- '/_ilm/policy/logstash_clean_policy?pretty'  -H 'Content-Type: application/json' -d '{
    "policy": {
        "phases": {
            "hot": {
                "min_age": "0ms",
                "actions": {
                    "set_priority": {
                        "priority": 100
                    }
                }
            },
            "delete": {
                "min_age": "14d",
                "actions": {
                    "delete": {}
                }
            }
        }
    }
}'

