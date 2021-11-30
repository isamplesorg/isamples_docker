# syntax=docker/dockerfile:1
FROM python:latest

WORKDIR /app

# The installation of the python requirements should be basically the first thing here.  Docker files will re-run steps
# that appear after a step that has changed.  Setting up the python environment is the most time-consuming step; put
# it first so it only executes when it absolutely has to.
COPY ./isamples_inabox/requirements.txt requirements.txt
RUN pip3 install -r requirements.txt

RUN apt-get update -y && apt-get install -y libgeos-dev && apt-get install -y cron

COPY ./isamples_inabox/ .
COPY ./isb_web_config.env .
COPY ./isamples_metadata.env .
COPY ./sampledFeature.bin .
COPY ./isb.cfg .
COPY ./isb_container_startup.sh .
COPY ./cron/ .
COPY ./cron/crontab /etc/cron.d/update_crontab
RUN chmod 0644 /etc/cron.d/update_crontab
RUN touch /var/log/cron.log
RUN crontab /etc/cron.d/update_crontab
RUN mkdir /var/log/isamples
RUN chmod 755 /var/log/isamples

# Start this up in a shell script, per https://goinbigdata.com/docker-run-vs-cmd-vs-entrypoint/
# CMD [ "/app/isb_container_startup.sh" ]
CMD [ "uvicorn", "isb_web.main:app", "--host", "0.0.0.0", "--port", "8000" ]

# Uncomment this line to keep the container running if for any reason you are having trouble getting it to come up.
# CMD ["tail", "-f", "/dev/null"]