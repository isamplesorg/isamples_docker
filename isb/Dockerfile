# syntax=docker/dockerfile:1
FROM python:latest

WORKDIR /app

RUN apt-get update -y && apt-get install -y libgeos-dev && apt-get install -y cron
COPY ./isamples_inabox/requirements.txt requirements.txt
RUN pip3 install -r requirements.txt


COPY ./isamples_inabox/ .
COPY ./isb_web_config.env .
COPY ./isamples_metadata.env .
COPY ./sampledFeature.bin .
COPY ./isb.cfg .
COPY ./cron/ .
COPY ./cron/crontab /etc/cron.d/update_crontab
RUN chmod 0644 /etc/cron.d/update_crontab
CMD [ "isb_container_startup.sh" ]

# Uncomment this line to keep the container running if for any reason you are having trouble getting it to come up.
#CMD ["tail", "-f", "/dev/null"]