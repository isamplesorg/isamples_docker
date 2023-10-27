# iSamples Central AWS Migration 10/24/23

Due to unforeseen circumstances, we needed to migrate all of iSamples of AWS with haste.  This document describes that process.

## What's running on iSamples Central?

```
ubuntu@ip-172-31-86-122:~$ docker ps
CONTAINER ID   IMAGE                                           COMMAND                  CREATED       STATUS                 PORTS                                       NAMES
5d84ca6049f2   isamples_modelserver_isamples_modelserver       "/app/isamples_model…"   7 weeks ago   Up 7 weeks             0.0.0.0:9000->9000/tcp, :::9000->9000/tcp   isamples_modelserver-isamples_modelserver-1
8dc5fddac5a7   isamples_inabox_isamples_inabox                 "/app/isb_container_…"   7 weeks ago   Up 7 weeks             0.0.0.0:8000->8000/tcp                      isamples_inabox-isamples_inabox-1
eb70fe6ebae5   isamples_inabox_solr_exporter                   "docker-entrypoint.s…"   7 weeks ago   Up 7 weeks             8983/tcp, 0.0.0.0:8989->8989/tcp            isamples_inabox-solr_exporter-1
e2863fb1a086   quay.io/prometheuscommunity/postgres-exporter   "/bin/postgres_expor…"   7 weeks ago   Up 7 weeks             0.0.0.0:9187->9187/tcp                      isamples_inabox-db_exporter-1
aab10f2e5d0f   isamples_inabox_solr                            "docker-entrypoint.s…"   7 weeks ago   Up 7 weeks (healthy)   127.0.0.1:8983->8983/tcp, 9983/tcp          isamples_inabox-solr-1
259e924436b8   isamples_inabox_db                              "docker-entrypoint.s…"   7 weeks ago   Up 7 weeks             127.0.0.1:5432->5432/tcp                    isamples_inabox-db-1
9ed688ebcf53   quay.io/prometheus/node-exporter:latest         "/bin/node_exporter …"   7 weeks ago   Up 7 weeks                                                         node_exporter
```

What are all these containers?

* `isamples_modelserver-isamples_modelserver-1` is the endpoint that handles all ML model invocations.  The `pytorch` dependencies were a mess and moving this to its own endpoint offered way out of that.
* `isamples_inabox-isamples_inabox-1` The main iSB container
*  `isamples_inabox-solr_exporter-1` The prometheus exporter for solr
*  `isamples_inabox-db_exporter-1` The prometheus exporter for postgresql
*  `isamples_inabox-solr-1` The solr container
*  `isamples_inabox-db-1` The postgresql container
*  `node_exporter ` The prometheus local machine exporter

## Dump the postgresql db
Dump the db on the db container

```
ubuntu@ip-172-31-86-122:~$ docker exec -it isamples_inabox-db-1 bash
root@259e924436b8:/# pg_dump -a --dbname="isb_1" --host=localhost --port=5432 --username=isb_writer >& isc_backup.sql
root@259e924436b8:/# gzip isc_backup.sql 
```
Copy the dump out of the container onto the host machine

```
ubuntu@ip-172-31-86-122:~$ docker cp isamples_inabox-db-1:/isc_backup.sql.gz .
```

## Dump the solr index
Go into the solr container

```
ubuntu@ip-172-31-86-122:~$ docker exec -it isamples_inabox-solr-1 bash
```

Then create the dump directory (note that this needs to be relative to `SOLR_HOME`)

```
solr@aab10f2e5d0f:/opt/solr-9.1.1$ echo $SOLR_HOME
/var/solr/data
solr@aab10f2e5d0f:/opt/solr-9.1.1$ mkdir /var/solr/data/solrbackup
```

Then issue the dump command, zip up the output, and copy off the container

```
solr@aab10f2e5d0f:/opt/solr-9.1.1$ curl "http://localhost:8983/solr/admin/collections?action=BACKUP&name=isb_core_records_backup&collection=isb_core_records2&location=file:///var/solr/data/backup"
{
  "responseHeader":{
    "status":0,
    "QTime":30426},
  "success":{
    "172.23.0.2:8983_solr":{
      "responseHeader":{
        "status":0,
        "QTime":29826},
      "response":{
        "startTime":"2023-10-24T18:31:55.715849820Z",
        "indexFileCount":363,
        "uploadedIndexFileCount":363,
        "indexSizeMB":2757.895,
        "uploadedIndexFileMB":2757.895,
        "shard":"shard1",
        "endTime":"2023-10-24T18:32:25.528166160Z",
        "shardBackupId":"md_shard1_1"}}},
  "response":{
    "collection":"isb_core_records2",
    "numShards":1,
    "backupId":1,
    "indexVersion":"9.3.0",
    "startTime":"2023-10-24T18:31:55.457235115Z",
    "indexFileCount":363,
    "uploadedIndexFileCount":363,
    "indexSizeMB":2757.895,
    "uploadedIndexFileMB":2757.895,
    "shardBackupIds":["md_shard1_1"],
    "endTime":"2023-10-24T18:32:25.611855136Z"}}
  
solr@aab10f2e5d0f:/opt/solr-9.1.1$ tar czvf isb_core_records_backup.tgz isb_core_records_backup

ubuntu@ip-172-31-86-122:~$ docker cp isamples_inabox-solr-1:/var/solr/data/backup/isb_core_records_backup.tgz .
                               Successfully copied 2.87GB to /home/ubuntu/.
```

## What's running on the metrics server

While we have the main iSamples Central box, we also have a separate machine for running metrics packages.  The containers are as follows:

```
ubuntu@ip-172-31-20-124:~$ sudo !!
sudo docker ps
CONTAINER ID   IMAGE                                      COMMAND                  CREATED        STATUS        PORTS                                       NAMES
dba42c773760   prometheus_prometheus                      "/bin/prometheus --c…"   3 months ago   Up 3 months   0.0.0.0:9090->9090/tcp, :::9090->9090/tcp   prometheus-prometheus-1
1c37b3e321f5   prometheus_prometheus_alerting             "/bin/alertmanager -…"   3 months ago   Up 3 months   0.0.0.0:9093->9093/tcp, :::9093->9093/tcp   prometheus-prometheus_alerting-1
f050aa8d9040   clickhouse/clickhouse-server:22.6-alpine   "/entrypoint.sh"         8 months ago   Up 3 months   8123/tcp, 9000/tcp, 9009/tcp                plausible_hosting-plausible_events_db-1
f68c400bc555   bytemark/smtp                              "docker-entrypoint.s…"   8 months ago   Up 3 months   25/tcp                                      plausible_hosting-mail-1
e8f0b6aa7d8d   postgres:14-alpine                         "docker-entrypoint.s…"   8 months ago   Up 3 months   5432/tcp                                    plausible_hosting-plausible_db-1
```

## Restoring on hyde

```
dannymandel@hyde:~$ docker exec -it isamples_inabox-db-1 bash
root@588862a75db9:/# psql -h localhost -U isb_writer -W postgres
Password: 
psql (14.1 (Debian 14.1-1.pgdg110+1))
Type "help" for help.

postgres=# drop database isb_1;
DROP DATABASE
postgres=# create database isb_1;
CREATE DATABASE
```
Then bring the clusters down to restart, which will recreate the schema:

```
dannymandel@hyde:~$ sudo service isamples_central restart
```

### Copy the backup into the db:

```
dannymandel@hyde:~$ docker cp isc_backup.sql.gz isamples_inabox-db-1:/tmp/
dannymandel@hyde:~$ docker exec -it isamples_inabox-db-1 bash
root@0adcb8130a61:/# gunzip /tmp/isc_backup.sql.gz
root@0adcb8130a61:/tmp# psql --username=isb_writer --dbname=isb_1 -f ./isc_backup.sql 
```


### Copy the solr backup into the cluster:

In host:

```
dannymandel@hyde:~$ docker cp ./isb_core_records_backup.tgz isamples_inabox-solr-1:/tmp/
                             Successfully copied 2.87GB to isamples_inabox-solr-1:/tmp/
```

In container:

```
mkdir /var/solr/data/backup
mv /tmp/isb_core_records_backup.tgz /var/solr/data/backup/
tar xzvf isb_core_records_backup.tgz
rm -rf isb_core_records_backup.tgz 
```

Delete existing records:

```
solr@dba2f0262bb0:/var/solr/data/backup$ curl http://localhost:8983/solr/isb_core_records/update -H "Content-type: text/xml" --data-binary '<delete><query>*:*</query></delete>'
<?xml version="1.0" encoding="UTF-8"?>
<response>

<lst name="responseHeader">
  <int name="rf">1</int>
  <int name="status">0</int>
  <int name="QTime">1356</int>
</lst>
</response>

solr@dba2f0262bb0:/var/solr/data/backup$ curl http://localhost:8983/solr/isb_core_records/update -H "Content-type: text/xml" --data-binary '<commit />'
<?xml version="1.0" encoding="UTF-8"?>
<response>

<lst name="responseHeader">
  <int name="status">0</int>
  <int name="QTime">1673</int>
</lst>
</response>
```

Verify they're all gone:

```
solr@dba2f0262bb0:/var/solr/data/backup$ curl "http://localhost:8983/solr/isb_core_records/select?q=*:*"
{
  "responseHeader":{
    "zkConnected":true,
    "status":0,
    "QTime":101,
    "params":{
      "q":"*:*"
    }
  },
  "response":{
    "numFound":0,
    "start":0,
    "numFoundExact":true,
    "docs":[ ]
  }
}
```

Run restore command:

```
solr@dba2f0262bb0:/var/solr/data/backup$ curl "http://localhost:8983/solr/admin/collections?action=RESTORE&name=isb_core_records_backup&collection=isb_core_records&location=file:///var/solr/data/backup"
```

Verify the restore worked:

```
solr@dba2f0262bb0:/var/solr/data/backup$curl "http://localhost:8983/solr/isb_core_records/select?q=*:*"
{
  "responseHeader":{
    "zkConnected":true,
    "status":0,
    "QTime":51,
    "params":{
      "q":"*:*"
    }
  },
  "response":{
    "numFound":6347967,
    "start":0,
    "numFoundExact":true,
    "docs":[{
    …
```

## plausible.io setup
Followed instructions in https://github.com/isamplesorg/isamples_metrics/blob/main/README.md

## prometheus setup
Followed instructions in https://github.com/isamplesorg/isamples_metrics/blob/main/README.md

## Container inventory

| Container | Machine | Git Repo | Documentation |
|:----------|:--------|:---------|:--------------|
| iSB       | hyde.cyverse.org | git@github.com:isamplesorg/isamples_docker.git      |https://github.com/isamplesorg/isamples_docker/blob/develop/README.md|
| iSamples Modelserver | hyde.cyverse.org | git@github.com:isamplesorg/isamples_modelserver.git | https://github.com/isamplesorg/isamples_modelserver/blob/develop/README.md |
| Prometheus | mars.cyverse.org | git@github.com:isamplesorg/isamples_metrics.git | https://github.com/isamplesorg/isamples_metrics/blob/main/README.md |
| plausible.io | mars.cyverse.org| git@github.com:isamplesorg/isamples_metrics.git| https://github.com/isamplesorg/isamples_metrics/blob/main/README.md |