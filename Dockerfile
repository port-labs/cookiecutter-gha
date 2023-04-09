# Use the Alpine Linux base image
FROM alpine:3.2

RUN apk add --no-cache jq \
    curl \ 
    python \
    python-dev \
    py-pip \
    g++ && \
    pip install cookiecutter && \
    apk del g++ py-pip  python-dev && \
    rm -rf /var/cache/apk/*

COPY entrypoint.sh /

RUN chmod 777 /entrypoint.sh

ENTRYPOINT /entrypoint.sh