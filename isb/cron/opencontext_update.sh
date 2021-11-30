#!/bin/bash

cd /app
export PYTHONPATH=/app
echo "Going to invoke OpenContext update load"
/usr/local/bin/python scripts/opencontext_things.py --config ./isb.cfg load -m -1 >& /var/log/isamples/`date "+%Y-%m-%d"`.opencontext_load.txt
echo "Going to invoke OpenContext solr update"
/usr/local/bin/python scripts/opencontext_things.py --config ./isb.cfg populate_isb_core_solr >& /var/log/isamples/`date "+%Y-%m-%d"`.opencontext_solr.txt
echo "Manually refreshing solr"
curl "http://solr:8983/solr/isb_core_records/update?commit=true"