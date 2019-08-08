
FROM envoyproxy/envoy:v1.10.0
RUN mkdir -p /opt/scytale/conf/agent
RUN mkdir -p /opt/scytale/data/agent
COPY conf/envoy.yaml /etc/envoy/envoy.yaml
COPY conf/agent.key.pem /opt/scytale/conf/agent/agent.key.pem
COPY conf/agent.crt.pem /opt/scytale/conf/agent/agent.crt.pem
COPY web-server /usr/local/bin/web-server

RUN apt-get update
RUN apt-get install -y vim curl sudo

RUN curl http://download.scytaleio.com/tar/scytale-agent-1.1.0-0-linux-x86_64-glibc.tar.gz > /root/scytale-agent-1.1.0-0-linux-x86_64-glibc.tar.gz
RUN useradd scytale-agent
RUN tar -C / -xvf /root/scytale-agent-1.1.0-0-linux-x86_64-glibc.tar.gz
RUN chown scytale-agent:scytale-agent /opt/scytale/data/agent
RUN chown scytale-agent:scytale-agent /opt/scytale/sockets/agent
RUN mkdir /opt/scytale/conf/agent/keys
RUN chown scytale-agent:scytale-agent /opt/scytale/conf/agent/keys
RUN chown scytale-agent:scytale-agent /opt/scytale/data

RUN mkdir -p /run/scytale/sockets

COPY conf/scytale-agent.conf /opt/scytale/conf/agent/agent.conf
### it's very possible this bootstrap_ca.crt in the tarball is bad news... rcn
RUN mv /opt/scytale/conf/bootstrap_ca.crt /opt/scytale/conf/agent/bootstrap_ca.crt






WORKDIR /opt/scytale
CMD /usr/local/bin/envoy -l debug -c /etc/envoy/envoy.yaml --log-path /tmp/envoy.log

