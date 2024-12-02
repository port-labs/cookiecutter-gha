# Use the Alpine Linux base image
FROM python:3.11-alpine

RUN apk update && \
    apk add --no-cache jq \
    curl \ 
    git \
    openssh-client \
    bash \
    py3-pip && \
    pip install --no-cache-dir cookiecutter six

COPY *.sh /
RUN chmod +x /*.sh

ENTRYPOINT ["/entrypoint.sh"]
