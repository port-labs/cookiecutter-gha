# Use the Alpine Linux base image
FROM alpine:latest

RUN apk update && \
    apk add --no-cache jq \
    curl \ 
    python3 \
    py3-pip \
    git \
    && pip3 install cookiecutter && pip3 install six

COPY entrypoint.sh /

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
