# syntax=docker/dockerfile:1
# Build the main Python app
FROM python:latest AS main

WORKDIR /app

# The installation of the python requirements should be basically the first thing here.  Docker files will re-run steps
# that appear after a step that has changed.  Setting up the python environment is the most time-consuming step; put
# it first so it only executes when it absolutely has to.
COPY ./isamples_inabox/requirements.txt requirements.txt
RUN pip3 install -r requirements.txt

RUN apt-get update -y && apt-get install -y libgeos-dev && apt-get install -y cron

COPY ./isamples_inabox/ .
COPY ./isamples_metadata.env .
COPY ./sampledFeature.bin .
COPY ./isb.cfg .
COPY ./isb_container_startup.sh .
COPY ./cron/ .
# We expect this to be passed in from the docker compose .env file
ARG CRONTAB_FILE=crontab.opencontext
RUN echo "CRONTAB FILE IS $CRONTAB_FILE"
COPY ./cron/$CRONTAB_FILE /etc/cron.d/update_crontab

ARG ENV_FILE=opencontext.isb_web_config.env
RUN echo "ENV FILE IS $ENV_FILE"
COPY ./isb_web_config/$ENV_FILE ./isb_web_config.env

RUN chmod 0644 /etc/cron.d/update_crontab
RUN touch /var/log/cron.log
RUN crontab /etc/cron.d/update_crontab
RUN mkdir /var/log/isamples
RUN chmod 755 /var/log/isamples

# Put the React build output inside isb_web ui directory for serving as part of the uvicorn installation
# This is built as part of the web_ui github action -- then the output is checked out in the gh-pages branch, copied to 
# the container, and we run python inside the container to search and replace the necessary values in the container itself.
ARG ISB_SITEMAP_PREFIX=https://mars.cyverse.org
RUN echo "ISB_SITEMAP_PREFIX IS $ISB_SITEMAP_PREFIX"
COPY ./isamples_webui/asset-manifest.json /app/isb_web/ui/
COPY ./isamples_webui/cesium /app/isb_web/ui/cesium
COPY ./isamples_webui/index.html /app/isb_web/ui/
COPY ./isamples_webui/manifest.json /app/isb_web/ui/
COPY ./isamples_webui/robots.txt /app/isb_web/ui/
COPY ./isamples_webui/static /app/isb_web/ui/static
COPY ./massage_webui_output.py .
RUN python /app/massage_webui_output.py -u https://hyde.cyverse.org/isamples_central -r $ISB_SITEMAP_PREFIX -p /app/isb_web/ui/static/js

# Install nodejs in the container
USER root
WORKDIR /app
COPY ./elevate/package.json ./
# Copy elevate source to the container
RUN mkdir /app/elevate/
COPY ./elevate ./elevate
RUN apt-get update
RUN apt-get -y install curl gnupg
RUN curl -sL https://deb.nodesource.com/setup_18.x  | bash -
RUN apt-get -y install nodejs
RUN npm install


# Start this up in a shell script, per https://goinbigdata.com/docker-run-vs-cmd-vs-entrypoint/
CMD [ "/app/isb_container_startup.sh" ]