#/bin/bash




set -e

bb=$(tput bold)
nn=$(tput sgr0)

fingerprint() {
	# calculate the SHA1 digest of the DER bytes of the certificate using the
	# "coreutils" output format (`-r`) to provide uniform output from
	# `openssl sha1` on macOS and linux.
	cat $1 | openssl x509 -outform DER | openssl sha1 -r | awk '{print $1}'
}

WEB_AGENT_FINGERPRINT=$(fingerprint docker/se-web-rcn/conf/agent.crt.pem)
ECHO_AGENT_FINGERPRINT=$(fingerprint docker/se-echo-rcn/conf/agent.crt.pem)

echo "HEY!!   don't use this.... do the entries in the console instead...."

echo "make custom node-sets using these parent id's:   "
echo "spiffe://trust01.ryan.net/echonodes"
echo "spiffe://trust01.ryan.net/webnodes"


echo "then, create entries for spiffe://trust01.ryan.net/web-server, and spiffe://trust01.ryan.net/echo-server, for uid=0"
exit

echo "${bb}Creating registration entry for the web server...${nn}"
echo . -----    docker-compose exec se-server bin/scytale-server entry create \
	-parentID spiffe://domain.test/spire/agent/x509pop/${WEB_AGENT_FINGERPRINT} \
	-spiffeID spiffe://domain.test/web-server \
	-selector unix:user:root

echo "${bb}Creating registration entry for the echo server...${nn}"
echo . -----    docker-compose exec se-server bin/scytale-server entry create \
	-parentID spiffe://domain.test/spire/agent/x509pop/${ECHO_AGENT_FINGERPRINT} \
	-spiffeID spiffe://domain.test/echo-server \
	-selector unix:user:root
