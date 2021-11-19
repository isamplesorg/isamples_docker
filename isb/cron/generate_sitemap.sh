#!/bin/bash
declare ROOT=/app
export PYTHONPATH=$ROOT
cd $ROOT
mkdir $ROOT/sitemaps
mkdir /var/log/isamples
declare DATE=$(date "+%Y-%m-%d")
declare OUTPUT_DIR="$ROOT/$DATE/sitemaps"
echo "Attempting to remove sitemap directory output at $OUTPUT_DIR, ok if this fails"
rm -rf $OUTPUT_DIR
echo "Creating sitemap directory output at $OUTPUT_DIR"
mkdir -p $OUTPUT_DIR
echo "Invoking sitemap creation script"
python scripts/generate_things_sitemap.py -h "http://henry.cyverse.org:8000" -p "$OUTPUT_DIR"  >& /var/log/isamples/$DATE.sitemap.txt
echo "Removing old sitemaps symlink"
rm -rf $ROOT/isb_web/sitemaps
echo "Creating new sitemaps symlink"
ln -s $OUTPUT_DIR $ROOT/isb_web/