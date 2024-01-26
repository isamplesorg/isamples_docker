# syntax=docker/dockerfile:1
# Build the main Python app
ROM python:3.11.6 AS main

# unclear if this is needed -- probably not…
# RUN pip3 install --upgrade pip
WORKDIR /app

# The installation of the python requirements should be basically the first thing here.  Docker files will re-run steps
# that appear after a step that has changed.  Setting up the python environment is the most time-consuming step; put
# it first so it only executes when it absolutely has to.
COPY ./isamples_inabox/requirements.txt requirements.txt
RUN pip3 install -r requirements.txt

RUN apt-get update -y && apt-get install -y libgeos-dev && apt-get install -y cron

COPY ./isamples_inabox/ .
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
ARG ANALYTICS_DOMAIN=isamples.org
ARG DATACITE_PREFIX="123456"
ARG DATACITE_PUBLISHER="publisher"
RUN echo "ISB_SITEMAP_PREFIX IS $ISB_SITEMAP_PREFIX ANALYTICS_DOMAIN is $ANALYTICS_DOMAIN DATACITE_PREFIX IS $DATACITE_PREFIX DATACITE_PUBLISHER IS $DATACITE_PUBLISHER"
COPY ./isamples_webui/asset-manifest.json /app/isb_web/ui/
COPY ./isamples_webui/cesium /app/isb_web/ui/cesium
COPY ./isamples_webui/index.html /app/isb_web/ui/
COPY ./isamples_webui/manifest.json /app/isb_web/ui/
COPY ./isamples_webui/robots.txt /app/isb_web/ui/
COPY ./isamples_webui/static /app/isb_web/ui/static
RUN echo "const _server_base = \"$ISB_SITEMAP_PREFIX/\";\n\nconst DATACITE_PUBLISHER = [\"Sesar\", \"Geome\", \"OpenContext\", \"Smithsonian\"];\n\nconst config = {\n \"original_source\": \"https://n2t.net\",\n  \"solr_url\": _server_base + \"thing/select\",\n  \"solr_stream\": _server_base + \"thing/stream\",\n  \"thingpage\": _server_base + \"thingpage\",\n  \"dois_draft\": _server_base + \"manage/mint_draft_identifiers\",\n  \"login\": _server_base + \"manage/login\",\n  \"logout\": _server_base + \"manage/logout\",\n  \"userinfo\": _server_base + \"manage/userinfo\",\n  \"h3_count\": _server_base + \"h3_counts\", \n  \"enable_login\": false, \n  \"analytics_src\": \"$ANALYTICS_SRC\",\n  \"analytics_domain\": \"$ANALYTICS_DOMAIN\",\n  \"datacite_prefix\": \"$DATACITE_PREFIX\",\n  \"datacite_publisher\": DATACITE_PUBLISHER\n};\n\nwindow.config = config;" | tee /app/isb_web/ui/config.js

# Install nodejs in the container
USER root
WORKDIR /app
COPY ./elevate/package.json ./
# Copy elevate source to the container
RUN mkdir /app/elevate/
COPY ./elevate ./elevate
RUN apt-get update
RUN apt-get -y install ca-certificates curl gnupg
RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
RUN apt-get update
RUN apt-get -y install nodejs
RUN npm install




# Start this up in a shell script, per https://goinbigdata.com/docker-run-vs-cmd-vs-entrypoint/
CMD [ "/app/isb_container_startup.sh" ]
