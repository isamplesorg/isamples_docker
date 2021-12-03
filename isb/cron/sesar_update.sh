#!/bin/bash

cd /app
export PYTHONPATH=/app
echo "Going to invoke SESAR update load"
/usr/local/bin/python scripts/sesar_things.py --config ./isb.cfg load -m -1 >& /var/log/isamples/`date "+%Y-%m-%d"`.sesar_load.txt
echo "Going to invoke SESAR solr update"
/usr/local/bin/python scripts/sesar_things.py --config ./isb.cfg populate_isb_core_solr >& /var/log/isamples/`date "+%Y-%m-%d"`.sesar_solr.txt
echo "Manually refreshing solr"
curl "http://solr:8983/solr/isb_core_records/update?commit=true"