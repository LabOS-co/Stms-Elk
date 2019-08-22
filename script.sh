curl -XPUT '/_ilm/policy/logstash_clean_policy1?pretty'  \
-H 'Content-Type: application/json' \
-d '{ 
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


curl -XPUT /_template/logstash_clean_policy1?pretty \
-H 'Content-Type: application/json' \
-d '{
  "index_patterns": [
    "logstash-*"
  ],
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 1,
    "index.lifecycle.name": "logstash_clean_policy1"
  }
}'
