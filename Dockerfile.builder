# syntax=docker/dockerfile:1
ARG PYTHON_VERSION=3.11
FROM python:${PYTHON_VERSION}-slim-bullseye

ARG PLONE_VERSION

ENV PIP_VERSION=22.3.1
ENV EXTRA_PACKAGES="relstorage==3.5.0 psycopg2==2.9.5 python-ldap==3.4.3"

RUN <<EOT
    apt-get update
    apt-get -y upgrade
    buildDeps="build-essential busybox curl gosu libbz2-dev libffi-dev libjpeg62-turbo-dev libmagic1 libldap2-dev libopenjp2-7-dev libpcre3-dev libpq-dev libsasl2-dev libssl-dev libtiff5-dev libxml2-dev libxslt1-dev wget zlib1g-dev"
    apt-get install -y --no-install-recommends $buildDeps
    busybox --install -s
    python -m venv /app
    curl -L -o /app/constraints.txt https://dist.plone.org/release/$PLONE_VERSION/constraints.txt
    /app/bin/pip install -U "pip==${PIP_VERSION}" wheel
    /app/bin/pip install Plone ${EXTRA_PACKAGES} -c /app/constraints.txt
    bash -c 'mkdir -p /app/var/{filestorage,blobstorage,cache,logs}'
    find /app \( -type f -a -name '*.pyc' -o -name '*.pyo' \) -exec rm -rf '{}' +
EOT

COPY /skeleton/etc /app/etc
COPY /skeleton/scripts /app/scripts
COPY /skeleton/docker-entrypoint.sh /app/
COPY /skeleton/inituser /app/
