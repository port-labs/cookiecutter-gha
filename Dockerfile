# Use the Alpine Linux base image
FROM alpine:latest

RUN apk update && \
    apk add --no-cache jq \
    curl \ 
    python3 \
    py3-pip \
    && pip3 install --no-cache-dir cookiecutter \
    && apk del py3-pip \
    && rm -rf /var/cache/apk/*

COPY entrypoint.sh /

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
