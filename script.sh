apk add curl

curl -X PUT "http://localhost:9200/_template/softov_log" -H 'Content-Type: application/json' -d @index_template.cfg

# we dont want to create the index pattern over and over again, so I am cheching if it exists first

code=$(curl -X GET "localhost:5601/api/saved_objects/_find?type=index-pattern&search_fields=title&search=logstash*" -H 'kbn-xsrf: true')
if [[ $code =~ '"total":0' ]] ; then

	curl -X POST -D- 'http://localhost:5601/api/saved_objects/index-pattern' \
		-H 'Content-Type: application/json' \
		-H 'kbn-version: 7.2.0' \
		-d '{"attributes":{"title":"logstash*","timeFieldName":"@timestamp"}}'

fi
	
curl -X PUT 'localhost:9200/_ilm/policy/logstash_clean_policy?pretty' -H 'Content-Type: application/json' -d '
{ 
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

curl -X PUT 'localhost:9200/_template/logstash_clean_policy1?pretty' -H 'Content-Type: application/json' -d '
{
  "index_patterns": [
    "logstash-*"
  ],
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 1,
    "index.lifecycle.name": "logstash_clean_policy"
  }
}'