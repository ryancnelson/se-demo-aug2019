#FROM gcr.io/spiffe-io/spire-server:unstable
FROM ubuntu:latest

RUN apt-get update
RUN apt-get -y install curl sudo
RUN curl http://download.scytaleio.com/tar/scytale-server-1.1.0-0-linux-x86_64-glibc.tar.gz > /root/scytale-server-1.1.0-0-linux-x86_64-glibc.tar.gz

RUN useradd scytale-server
RUN tar -C / -xvf /root/scytale-server-1.1.0-0-linux-x86_64-glibc.tar.gz
RUN chown scytale-server:scytale-server /opt/scytale/data/server
RUN chown scytale-server:scytale-server /opt/scytale/sockets/server
RUN mkdir /opt/scytale/conf/keys
RUN chown scytale-server:scytale-server /opt/scytale/conf/keys
RUN mkdir /opt/scytale/data/server/keys
RUN chown scytale-server:scytale-server /opt/scytale/data/server/keys

RUN mkdir /opt/scytale/conf/data

RUN sudo -u scytale-server /opt/scytale/bin/scytale-server || echo "."


# Override spire configurations
COPY conf/server.conf /opt/scytale/conf/server.conf 
COPY conf/agent-cacert.pem /opt/scytale/conf/server/agent-cacert.pem
COPY conf/agent-cacert.pem /opt/scytale/conf/rootCA.crt 

##COPY conf/spire-server.conf /opt/spire/conf/server/server.conf
##COPY conf/agent-cacert.pem /opt/spire/conf/server/agent-cacert.pem

WORKDIR /opt/spire
