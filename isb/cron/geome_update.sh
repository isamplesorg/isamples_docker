#!/bin/bash

cd /home/isamples/isamples_inabox
source /home/isamples/.virtualenvs/isb/bin/activate
echo "Going to invoke GEOME update load"
python scripts/geome_things.py --config ./isb.cfg load -m -1 >& /var/log/isamples/`date "+%Y-%m-%d"`.geome_load.txt
echo "Going to invoke GEOME solr update"
python scripts/geome_things.py --config ./isb.cfg populate_isb_core_solr >& /var/log/isamples/`date "+%Y-%m-%d"`.geome_solr.txt
echo "Manually refreshing solr"
curl "http://localhost:8983/solr/isb_core_records/update?commit=true"