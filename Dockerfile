# syntax=docker/dockerfile:1
FROM python:3.8-slim-buster as base
FROM base as builder

ENV PIP_PARAMS=""
ENV PIP_VERSION=22.0.4
ENV PLONE_VERSION=5.2.10.2
ENV PLONE_VOLTO="plone.volto==3.1.0a4"
ENV EXTRA_PACKAGES="relstorage==3.4.5 psycopg2==2.9.3 python-ldap==3.4.0"

RUN mkdir /wheelhouse

RUN <<EOT
    apt update
    buildDeps="dpkg-dev gcc libbz2-dev libc6-dev libffi-dev libjpeg62-turbo-dev libldap2-dev libopenjp2-7-dev libpcre3-dev libpq-dev libsasl2-dev libssl-dev libtiff5-dev libxml2-dev libxslt1-dev wget zlib1g-dev python3-dev build-essential"
    apt install -y --no-install-recommends $buildDeps
    pip install -U "pip==${PIP_VERSION}"
    rm -rf /var/lib/apt/lists/* /usr/share/doc
EOT

RUN pip wheel Paste Plone ${PLONE_VOLTO} ${EXTRA_PACKAGES} -c https://dist.plone.org/release/$PLONE_VERSION/constraints.txt  ${PIP_PARAMS} --wheel-dir=/wheelhouse

FROM base

ENV PIP_PARAMS=""
ENV PIP_VERSION=22.0.4

LABEL maintainer="Plone Community <dev@plone.org>" \
      org.label-schema.name="plone-backend" \
      org.label-schema.description="Plone backend image image using Python 3.8" \
      org.label-schema.vendor="Plone Foundation"

COPY --from=builder /wheelhouse /wheelhouse

RUN <<EOT
    useradd --system -m -d /app -U -u 500 plone
    runDeps="git libjpeg62 libopenjp2-7 libpq5 libtiff5 libxml2 libxslt1.1 lynx poppler-utils rsync wv busybox libmagic1 gosu"
    apt-get update
    apt-get install -y --no-install-recommends $runDeps
    busybox --install -s
    rm -rf /var/lib/apt/lists/* /usr/share/doc
    mkdir -p /data/filestorage /data/blobstorage /data/log /data/cache
EOT

WORKDIR /app

RUN <<EOT
    python -m venv .
    ./bin/pip install -U "pip==${PIP_VERSION}"
    ./bin/pip install --force-reinstall --no-index --no-deps ${PIP_PARAMS} /wheelhouse/*
    find . -type f -a -name '*.pyc' -o -name '*.pyo' -exec rm -rf '{}' +
    rm -rf .cache
EOT

COPY --chown=500:500 skeleton/ /app

RUN <<EOT
    ln -s /data var
    find /data  -not -user plone -exec chown plone:plone {} +
    find /app -not -user plone -exec chown plone:plone {} +
EOT

EXPOSE 8080
VOLUME /data

HEALTHCHECK --interval=10s --timeout=5s --start-period=30s CMD wget -q http://127.0.0.1:8080/ok -O - | grep OK || exit 1

ENTRYPOINT [ "/app/docker-entrypoint.sh" ]
CMD ["start"]
