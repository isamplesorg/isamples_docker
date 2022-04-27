# syntax=docker/dockerfile:1

# Build the React app using multistage builds (https://docs.docker.com/develop/develop-images/multistage-build/)
FROM node:latest AS node_build
WORKDIR /app
# This puts all the node binaries on the executable path inside the image
ENV PATH /app/node_modules/.bin:$PATH
# Copy the node dependencies into the image before we install the npm dependencies
COPY ./isamples_webui/package.json ./
COPY ./isamples_webui/package-lock.json ./
# Install all the npm dependencies
RUN npm ci --silent
# Copy the main source into the image
COPY ./isamples_webui/ ./
ARG ISB_SITEMAP_PREFIX=https://mars.cyverse.org
ARG ANALYTICS_DOMAIN=isamples.org
# write out the JSON config for the specific solr URL to hit in the webUI
RUN echo "const _solr_base = \"$ISB_SITEMAP_PREFIX/thing/\";\n\nconst config = {\n  \"solr_url\": _solr_base + \"select\",\n  \"solr_stream\": _solr_base + \"stream\",\n  \"analytics_src\": \"https://metrics.isample.xyz/js/plausible.js\",\n  \"analytics_domain\": \"isamples.org\"\n};\n\nexport default config;" | tee ./src/config.js
# Run the build -- by default this will place the build output in ./build, which is why we copy out of /app/build later on
RUN npm run build



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
# This statement is a bit confusing -- the --from=node_build is the build stage we are copying *from*,
# and the /app/build is the path in *that* image (the multistage builds produce separate images).  The
# dest path (/app/isb_web/ui) is the path in *this* image.
COPY --from=node_build /app/build/ /app/isb_web/ui/

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