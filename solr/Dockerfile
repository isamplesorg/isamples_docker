# syntax=docker/dockerfile:1
FROM solr:9.4.1

LABEL name="iSamples in a Box Solr Instance"
LABEL version=1.0

COPY ./jts-core-1.15.0.jar /opt/solr/server/solr-webapp/webapp/WEB-INF/lib/
# this exposes the embedded zookeeper on the Docker network, so other services can talk to it (like the prometheus exporter)
COPY ./zoo.cfg /opt/solr/server/solr/zoo.cfg