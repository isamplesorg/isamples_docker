#!/bin/bash

# export secrets as env vars
export ORCID_CLIENT_ID=`cat /run/secrets/orcid_client_id`
export ORCID_CLIENT_SECRET=`cat /run/secrets/orcid_client_secret`
export DATACITE_USERNAME=`cat /run/secrets/datacite_username`
export DATACITE_PASSWORD=`cat /run/secrets/datacite_password`
# Note that cron jobs don't inherit the environment when run -- docker *does* run with environment variables 
# so we need this step to export the docker environment for cron
declare -p | grep -Ev 'BASHOPTS|BASH_VERSINFO|EUID|PPID|SHELLOPTS|UID' > /container.env
/usr/sbin/service cron start
export PYTHONPATH=/app
/usr/local/bin/python scripts/create_sitemaps_symlink.py -s /app/sitemaps  -d /app/isb_web/sitemaps
uvicorn isb_web.main:app --host 0.0.0.0 --port 8000 --root-path /$ISB_UVICORN_ROOT_PATH