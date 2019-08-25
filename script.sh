apk add curl

# we dont want to create the index pattern over and over again, so I am cheching if it exists first

code=$(curl -X GET "kibana:5601/api/saved_objects/_find?type=index-pattern&search_fields=title&search=logstash*" -H 'kbn-xsrf: true')
if [[ $code =~ '"total":0' ]] ; then

	curl -X POST -D- 'kibana:5601/api/saved_objects/index-pattern' \
		-H 'Content-Type: application/json' \
		-H 'kbn-version: 7.2.0' \
		-d '{"attributes":{"title":"logstash*","timeFieldName":"@timestamp"}}'
		
	echo "Creating Index Template"
		
	curl -X PUT "elasticsearch:9201/_template/softov_log" -H 'Content-Type: application/json' -d @index_template.cfg

fi
	
	
curl -X PUT 'elasticsearch:9201/_ilm/policy/logstash_clean_policy?pretty' -H 'Content-Type: application/json' -d '
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

curl -X PUT 'elasticsearch:9201/_template/logstash_clean_policy1?pretty' -H 'Content-Type: application/json' -d '
{
  "index_patterns": [
    "logstash*"
  ],
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 1,
    "index.lifecycle.name": "logstash_clean_policy"
  }
}'

curl -X PUT "elasticsearch:9201/logstash*/_mapping?pretty" -H 'Content-Type: application/json' -d '
{
  "index_patterns": [
    "logstash*"
  ],
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 1,
    "index.lifecycle.name": "logstash_clean_policy"
  }
}'


curl -X PUT "localhost:9200/twitter/_mapping?pretty" -H 'Content-Type: application/json' -d '
{
  "properties": {
        "message": { "type": "text"  },
		    "duration": { "type": "long"  },
		    "service_duration": { "type": "long"  },
        "seq": { "type": "long"  }
  }
}'

