#!/bin/bash

cd /app
export PYTHONPATH=/app
echo "Going to invoke GEOME update load"
/usr/local/bin/python scripts/geome_things.py --config ./isb.cfg load -m -1 >& /var/log/isamples/`date "+%Y-%m-%d"`.geome_load.txt
echo "Going to invoke GEOME solr update"
/usr/local/bin/python scripts/geome_things.py --config ./isb.cfg populate_isb_core_solr >& /var/log/isamples/`date "+%Y-%m-%d"`.geome_solr.txt
echo "Manually refreshing solr"
curl "http://solr:8983/solr/isb_core_records/update?commit=true"