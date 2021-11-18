#!/bin/bash

cd /home/isamples/isamples_inabox
source /home/isamples/.virtualenvs/isb/bin/activate

declare DATE=$(date "+%Y-%m-%d")
declare OUTPUT_DIR="/home/isamples/sitemaps/$DATE/sitemaps"
echo "Attempting to remove sitemap directory output at $OUTPUT_DIR, ok if this fails"
rm -rf $OUTPUT_DIR
echo "Creating sitemap directory output at $OUTPUT_DIR"
mkdir -p $OUTPUT_DIR
echo "Invoking sitemap creation script"
python scripts/generate_things_sitemap.py -h "https://mars.cyverse.org" -p "$OUTPUT_DIR"  >& /var/log/isamples/$DATE.sitemap.txt
echo "Removing old sitemaps symlink"
rm -rf /home/isamples/isamples_inabox/isb_web/sitemaps
echo "Creating new sitemaps symlink"
ln -s $OUTPUT_DIR /home/isamples/isamples_inabox/isb_web/