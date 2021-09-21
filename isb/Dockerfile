# syntax=docker/dockerfile:1
FROM python:latest

WORKDIR /app

COPY ./isamples_inabox/requirements.txt requirements.txt
RUN pip3 install -r requirements.txt


COPY ./isamples_inabox/ .
COPY ./isb_web_config.env .
COPY ./isamples_metadata.env .
COPY ./sampledFeature.bin .
COPY ./isb.cfg .
CMD [ "uvicorn", "isb_web.main:app", "--host", "0.0.0.0", "--port", "8000" ]

# Uncomment this line to keep the container running if for any reason you are having trouble getting it to come up.
#CMD ["tail", "-f", "/dev/null"]