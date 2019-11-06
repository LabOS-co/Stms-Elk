apk add curl
apk add util-linux


fetchstatus() {
  curl \
    -o /dev/null \
    --silent \
    --head \
    --write-out '%{http_code}' \
    "kibana:5601/status"
}

urlstatus=$(fetchstatus)          # initialize to actual value before we sleep even once
until [ "$urlstatus" = 200 ]; do  # until our result is success...
  sleep 5                         # wait 5 seconds...
  echo 'Kibana is not ready... sleeping for 5';
  echo $urlstatus
  urlstatus=$(fetchstatus)        # then poll again.
done

# we dont want to create the index pattern over and over again, so I am cheching if it exists first

code=$(curl -X GET "kibana:5601/api/saved_objects/_find?type=index-pattern&search_fields=title&search=logstash*" -H 'kbn-xsrf: true')
if [[ $code =~ '"total":0' ]] ; then

	curl -X POST -D- 'kibana:5601/api/saved_objects/index-pattern' \
		-H 'Content-Type: application/json' \
		-H 'kbn-version: 7.4.0' \
		-d '{"attributes":{"title":"logstash*","timeFieldName":"@timestamp"}}'
		
	echo "Creating Index Template"
		
	curl -X PUT "elasticsearch:9201/_template/softov_log" -H 'Content-Type: application/json' -d @index_template.cfg

fi

echo wait 60 secs and send dummy msg to create index 
sleep 60
logger -n logstash -P 5014 -d "<24>daemon::[1] 14064 FATAL test:1111 1000 2282113801|11067 NO_VAL "start test" 787 [0] no_error - sample"

echo msg sent!

# Update Fields properties for existing indexes

curl -X PUT "elasticsearch:9201/logstash*/_mapping?pretty" -H 'Content-Type: application/json' -d '
{
  "properties": {
        "message": { "type": "text"  },
		    "duration": { "type": "long"  },
		    "service_duration": { "type": "long"  },
        "seq": { "type": "long"  }
  }
}'


# Create the Clean Policy

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

# Assign the Clean Policy to the index

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



