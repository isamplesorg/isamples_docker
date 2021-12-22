#!/bin/bash

# Note that cron jobs don't inherit the environment when run -- docker *does* run with environment variables 
# so we need this step to export the docker environment for cron
declare -p | grep -Ev 'BASHOPTS|BASH_VERSINFO|EUID|PPID|SHELLOPTS|UID' > /container.env
/usr/sbin/service cron start 
uvicorn isb_web.main:app --host 0.0.0.0 --port 8000 --root-path /$ISB_UVICORN_ROOT_PATH