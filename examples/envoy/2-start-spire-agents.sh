#!/bin/bash

set -e

bb=$(tput bold)
nn=$(tput sgr0)

# Bootstrap trust to the SPIRE server for each agent by copying over the
# trust bundle into each agent container. Alternatively, an upstream CA could
# be configured on the SPIRE server and each agent provided with the upstream
# trust bundle (see UpstreamCA under
# https://github.com/spiffe/spire/blob/master/doc/spire_server.md#plugin-types)

echo "first, paste this into the console!!! "
docker-compose exec -T se-server /opt/scytale/bin/scytale-server bundle show 

echo "then hit return to continue.... after a bit."
read dummy
##echo sleeping 30....
##sleep 30


echo "${bb}Bootstrapping trust between SPIRE agents and SPIRE server...${nn}"
docker-compose exec -T se-server /opt/scytale/bin/scytale-server bundle show |
	docker-compose exec -T web tee /opt/scytale/conf/agent/bootstrap.crt > /dev/null
### also put this bundle into bootstrap_ca.crt , and we'll turn off the upstream biz for now
docker-compose exec -T se-server /opt/scytale/bin/scytale-server bundle show |
	docker-compose exec -T web tee /opt/scytale/conf/agent/bootstrap_ca.crt > /dev/null

docker-compose exec -T se-server /opt/scytale/bin/scytale-server bundle show |
	docker-compose exec -T echo tee /opt/scytale/conf/agent/bootstrap.crt > /dev/null
### also put this bundle into bootstrap_ca.crt , and we'll turn off the upstream biz for now
docker-compose exec -T se-server /opt/scytale/bin/scytale-server bundle show |
	docker-compose exec -T echo tee /opt/scytale/conf/agent/bootstrap_ca.crt > /dev/null


##   generate a join token for the webnode:
webnodesJT=$(docker-compose exec -T se-server /opt/scytale/bin/scytale-server token generate -spiffeID spiffe://trust.mydomainrcn.com/webnodes  | awk '{print $2}' )

##   generate a join token for the echonode:
echonodesJT=$(docker-compose exec -T se-server /opt/scytale/bin/scytale-server token generate -spiffeID spiffe://trust.mydomainrcn.com/echonodes | awk '{print $2}'   )



# Start up the web server SPIRE agent.
echo "${bb}Starting web server SPIRE agent...${nn}"
echo ${webnodesJT} |
	docker-compose exec -T web tee /tmp/webnodes-jointoken  > /dev/null
sleep 2
docker-compose exec -d web sh -c "sudo -u scytale-agent /opt/scytale/bin/scytale-agent run -config /opt/scytale/conf/agent/agent.conf -joinToken \`cat /tmp/webnodes-jointoken\` "
sleep 2
docker-compose exec -d web sh -c "ps -ef | grep -i agent"

# Start up the echo server SPIRE agent.
echo "${bb}Starting echo server SPIRE agent...${nn}"
echo ${echonodesJT} |
	docker-compose exec -T echo tee /tmp/echonodes-jointoken  >  /dev/null
sleep 2
docker-compose exec -d echo sh -c "cat /tmp/echonodes-jointoken"
docker-compose exec -d echo sh -c "sudo -u scytale-agent /opt/scytale/bin/scytale-agent run -config /opt/scytale/conf/agent/agent.conf -joinToken \`cat /tmp/echonodes-jointoken\` "
docker-compose exec -d echo sh -c "ps -ef | grep -i agent"
