#!/bin/bash

cd /app
export PYTHONPATH=/app

echo "Going to invoke OpenContext sitemap ingest"
/usr/local/bin/python scripts/consume_sitemaps.py -u https://henry.cyverse.org/opencontext/sitemaps/sitemap-index.xml -a OPENCONTEXT >& /var/log/isamples/`date "+%Y-%m-%d"`.opencontext_sitemap.txt
echo "Going to invoke GEOME sitemap ingest"
/usr/local/bin/python scripts/consume_sitemaps.py -u https://henry.cyverse.org/geome/sitemaps/sitemap-index.xml -a GEOME >& /var/log/isamples/`date "+%Y-%m-%d"`.geome_sitemap.txt
echo "Going to invoke SESAR sitemap ingest"
/usr/local/bin/python scripts/consume_sitemaps.py -u https://henry.cyverse.org/sesar/sitemaps/sitemap-index.xml -a SESAR >& /var/log/isamples/`date "+%Y-%m-%d"`.sesar_sitemap.txt
echo "Going to invoke Smithsonian sitemap ingest"
/usr/local/bin/python scripts/consume_sitemaps.py -u https://henry.cyverse.org/smithsonian/sitemaps/sitemap-index.xml -a SMITHSONIAN >& /var/log/isamples/`date "+%Y-%m-%d"`.smithsonian_sitemap.txt

echo "Going to assign h3 values for things missing them"
/usr/local/bin/python scripts/migrations/populate_h3_for_existing_things.py --config ./isb.cfg  >& /var/log/isamples/`date "+%Y-%m-%d"`.h3.txt
echo "Going to populate points for any new h3 values"
/usr/local/bin/python scripts/migrations/populate_points_for_h3.py --config ./isb.cfg >& /var/log/isamples/`date "+%Y-%m-%d"`.points.txt
echo "Going to fetch heights for any points without height values"
node elevate/elevate.js -d "postgresql+psycopg2://isb_writer:isamplesinabox@db/isb_1" -k "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiI4MzRhMWQ2MS04YjQ2LTQxY2YtYjAwMi1mYWQ5YTcyYjE4MzQiLCJpZCI6OTA5NDAsImlhdCI6MTY1MDY0OTQ3MH0.9SO-QGYpjXAOYjj52guTmFJsxRGREekFADUw19hSKB0" >& /var/log/isamples/`date "+%Y-%m-%d"`.elevate.txt

echo "Going to invoke OpenContext solr index rebuild"
/usr/local/bin/python scripts/opencontext_things.py --config ./isb.cfg populate_isb_core_solr >& /var/log/isamples/`date "+%Y-%m-%d"`.opencontext_solr.txt
echo "Going to invoke GEOME solr index rebuild"
/usr/local/bin/python scripts/geome_things.py --config ./isb.cfg populate_isb_core_solr >& /var/log/isamples/`date "+%Y-%m-%d"`.geome_solr.txt
echo "Going to invoke SESAR solr index rebuild"
/usr/local/bin/python scripts/sesar_things.py --config ./isb.cfg populate_isb_core_solr >& /var/log/isamples/`date "+%Y-%m-%d"`.sesar_solr.txt
echo "Going to invoke Smithsonian solr index rebuild"
/usr/local/bin/python scripts/smithsonian_things.py --config ./isb.cfg populate_isb_core_solr >& /var/log/isamples/`date "+%Y-%m-%d"`.smithsonian_solr.txt

echo "Manually refreshing solr"
curl "http://solr:8983/solr/isb_core_records/update?commit=true"