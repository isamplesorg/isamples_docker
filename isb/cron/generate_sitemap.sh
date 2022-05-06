#!/bin/bash
export PYTHONPATH=/app
cd /app
mkdir /var/log/isamples
declare DATE=$(date "+%Y-%m-%d")
declare OUTPUT_DIR="/app/sitemaps/$DATE/sitemaps"
echo "Attempting to remove sitemap directory output at $OUTPUT_DIR, ok if this fails"
rm -rf $OUTPUT_DIR
echo "Creating sitemap directory output at $OUTPUT_DIR"
mkdir -p $OUTPUT_DIR
echo "Invoking sitemap creation script, using sitemap prefix of $ISB_SITEMAP_PREFIX"
/usr/local/bin/python /app/scripts/generate_things_sitemap.py -h "$ISB_SITEMAP_PREFIX" -p "$OUTPUT_DIR"  >& /var/log/isamples/$DATE.sitemap.txt
echo "Removing old sitemaps symlink"
rm -rf /app/isb_web/sitemaps
echo "Creating new sitemaps symlink"
ln -s $OUTPUT_DIR /app/isb_web/