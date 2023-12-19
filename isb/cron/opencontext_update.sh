#!/bin/bash

cd /app
export PYTHONPATH=/app
echo "Going to invoke OpenContext update load"
/usr/local/bin/python scripts/opencontext_things.py --config ./isb.cfg load -m -1 >& /var/log/isamples/`date "+%Y-%m-%d"`.opencontext_load.txt
echo "Going to populate points for any new h3 values"
/usr/local/bin/python scripts/migrations/populate_points_for_h3.py --config ./isb.cfg >& /var/log/isamples/`date "+%Y-%m-%d"`.opencontext_points.txt
echo "Going to fetch heights for any points without height values"
node elevate/elevate.js -d "postgresql+psycopg2://isb_writer:isamplesinabox@db/isb_1" -k "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiI4MzRhMWQ2MS04YjQ2LTQxY2YtYjAwMi1mYWQ5YTcyYjE4MzQiLCJpZCI6OTA5NDAsImlhdCI6MTY1MDY0OTQ3MH0.9SO-QGYpjXAOYjj52guTmFJsxRGREekFADUw19hSKB0" >& /var/log/isamples/`date "+%Y-%m-%d"`.opencontext_elevate.txt
echo "Going to invoke OpenContext solr update"
/usr/local/bin/python scripts/opencontext_things.py --config ./isb.cfg populate_isb_core_solr >& /var/log/isamples/`date "+%Y-%m-%d"`.opencontext_solr.txt
echo "Manually refreshing solr"
curl "http://solr:8983/solr/isb_core_records/update?commit=true"