#!/bin/sh

./build.sh

docker-compose up -d

echo "starting envoys... if you need to exec in, and re-start them, the start command is on web and echo at /root/start-envoy-command.sh"
echo


## loop and restart the web envoy every 120 seconds.
docker exec -d $(docker ps | grep envoy_web | awk '{print $1}' ) sh -c "while true ; do timeout 120 sh -c \"bash /root/start-envoy-command.sh\" ; done"

## loop and restart the echo envoy every 120 seconds.
docker exec -d $(docker ps | grep envoy_echo | awk '{print $1}' ) sh -c "while true ; do timeout 120 sh -c \"bash /root/start-envoy-command.sh\" ; done"

echo "-------" 
docker exec -it $(docker ps | grep envoy_web | awk '{print $1}' ) sh -c "hostname ; ps -ef | grep envoy"
docker exec -it $(docker ps | grep envoy_echo | awk '{print $1}' ) sh -c "hostname ; ps -ef | grep envoy"

