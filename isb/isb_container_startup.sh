#!/bin/bash

uvicorn isb_web.main:app --host 0.0.0.0 --port 8000
cron /etc/cron.d/update_crontab