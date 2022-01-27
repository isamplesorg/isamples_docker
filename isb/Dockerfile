# syntax=docker/dockerfile:1

# Build the React app
FROM node:latest AS node_build
WORKDIR /app
ENV PATH /app/node_modules/.bin:$PATH
COPY ./isamples_webui/faceted_search/package.json ./
COPY ./isamples_webui/faceted_search/package-lock.json ./
RUN npm ci --silent
COPY ./solr-faceted-search-react /solr-faceted-search-react
RUN npm link /solr-faceted-search-react
COPY ./isamples_webui/faceted_search/ ./
RUN npm run build
ENTRYPOINT ["tail", "-f", "/dev/null"]



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
COPY --from=node_build /build/ /app/isb_web/ui/


# Start this up in a shell script, per https://goinbigdata.com/docker-run-vs-cmd-vs-entrypoint/
CMD [ "/app/isb_container_startup.sh" ]