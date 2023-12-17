# Use the Alpine Linux base image
FROM python:3.11-alpine

RUN apk update && \
    apk add --no-cache jq \
    curl \ 
    git \
    openssh-client \
    bash \
    && pip3 install cookiecutter && pip3 install six

COPY *.sh /
RUN chmod +x /*.sh

ENTRYPOINT ["/entrypoint.sh"]
