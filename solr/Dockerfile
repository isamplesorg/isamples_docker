# syntax=docker/dockerfile:1
FROM solr:latest
COPY ./jts-core-1.15.0.jar /opt/solr/server/solr-webapp/webapp/WEB-INF/lib/
# uncomment this if we want to run a solr replication cluster with local zookeeper
# COPY ./zoo.cfg /opt/solr/server/solr/zoo.cfg