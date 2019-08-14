#!/bin/bash


#set -x 

set -e

echo "this should show you no servers running...."
docker ps | grep Up || echo "no servers running" 

echo ; echo "hit return to continue"  ; read dummy

###

echo "confirm no rules for your trust-domain exist in the console, please"
echo ; echo "hit return to continue"  ; read dummy

###

echo "building and startup up web, echo, and scytale-enterprise containers in docker-compose..."
./0-build-and-start-up.sh

echo "you should see envoys running on web and echo here..."
echo ; echo "hit return to continue"  ; read dummy

###

./1-start-services.sh

docker-compose exec web ps -ef
docker-compose exec echo ps -ef

echo "you should see web and echo servers running on web and echo here..."
echo ; echo "hit return to continue"  ; read dummy

###

echo "now, you should be able to reach http://localhost:8080/?route=direct and see green request and response... others will be still red."

echo ; echo "hit return to continue"  ; read dummy

###
echo "paste this into the console, to renew the trust-bundle for your trust-domain...."
docker-compose exec -T se-server /opt/scytale/bin/scytale-server bundle show


echo ; echo "hit return to continue"  ; read dummy

###

echo "putting the trust bundle into a local file:"
docker-compose exec -T se-server /opt/scytale/bin/scytale-server bundle show > se-server-bundle.txt


echo ; echo "hit return to continue"  ; read dummy

###

echo "inject that trust bundle into the web and echo server, in several places:"

cat se-server-bundle.txt  | docker-compose exec -T web tee /opt/scytale/conf/agent/bootstrap_ca.crt 
cat se-server-bundle.txt  | docker-compose exec -T web tee /opt/scytale/conf/agent/bootstrap.crt 
	
cat se-server-bundle.txt  | docker-compose exec -T echo tee /opt/scytale/conf/agent/bootstrap_ca.crt 
cat se-server-bundle.txt  | docker-compose exec -T echo tee /opt/scytale/conf/agent/bootstrap.crt 
	
echo ; echo "hit return to continue"  ; read dummy

###

echo "create join tokens for web and echo nodes, and put them in their respective containers:"
webnodesJT=$(docker-compose exec -T se-server /opt/scytale/bin/scytale-server token generate -spiffeID spiffe://trust01.ryan.net/webnodes  | awk '{print $2}' )
echo $webnodesJT  | docker-compose exec -T web tee /tmp/webnodes-jointoken

echonodesJT=$(docker-compose exec -T se-server /opt/scytale/bin/scytale-server token generate -spiffeID spiffe://trust01.ryan.net/echonodes | awk '{print $2}'   )
echo $echonodesJT  | docker-compose exec -T echo tee /tmp/echonodes-jointoken
	
echo ; echo "hit return to continue"  ; read dummy

###

echo "start the web agent, and confirm it's running"
docker-compose exec -d -T web sh -c "sudo -u scytale-agent /opt/scytale/bin/scytale-agent run -config /opt/scytale/conf/agent/agent.conf -joinToken \`cat /tmp/webnodes-jointoken\` "
	
docker-compose exec -T web tail -50 /tmp/agent.log
docker-compose exec -T web cat /tmp/agent.log | grep spiffe

echo "start the echo agent, and confirm it's running"
docker-compose exec -d -T echo sh -c "sudo -u scytale-agent /opt/scytale/bin/scytale-agent run -config /opt/scytale/conf/agent/agent.conf -joinToken \`cat /tmp/echonodes-jointoken\` "
docker-compose exec -T echo tail -50 /tmp/agent.log
docker-compose exec -T echo cat /tmp/agent.log | grep spiffe

echo ; echo "hit return to continue"  ; read dummy

###

echo "now, we're pretty much set up..."
echo "create node-sets in the console UI, for:"
echo "custom:   name: echonodeset    parentID: spiffe://trust01.ryan.net/echonodes"
echo "custom:   name: webnodeset    parentID: spiffe://trust01.ryan.net/webnodes"
echo 
echo "register workloads in each for"
echo "/echo-server , selector unix:uid:0" 
echo "/web-server , selector unix:uid:0" 


	
