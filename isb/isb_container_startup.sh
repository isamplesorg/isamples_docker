#!/bin/bash

/usr/sbin/service cron start 
uvicorn isb_web.main:app --host 0.0.0.0 --port 8000 --root-path /$ISB_UVICORN_ROOT_PATH