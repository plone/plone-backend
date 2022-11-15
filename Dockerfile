# syntax=docker/dockerfile:1
ARG PYTHON_VERSION=3.10
FROM python:${PYTHON_VERSION}-slim-bullseye as base
FROM base as builder

ENV PIP_PARAMS=""
ENV PIP_VERSION=22.2.2
ENV PLONE_VERSION=6.0.0b3
ENV EXTRA_PACKAGES="relstorage==3.4.5 psycopg2==2.9.3 python-ldap==3.4.0"

RUN <<EOT
    apt-get update
    buildDeps="dpkg-dev gcc libbz2-dev libc6-dev libffi-dev libjpeg62-turbo-dev libldap2-dev libopenjp2-7-dev libpcre3-dev libpq-dev libsasl2-dev libssl-dev libtiff5-dev libxml2-dev libxslt1-dev wget zlib1g-dev python3-dev build-essential"
    apt-get install -y --no-install-recommends $buildDeps
    rm -rf /var/lib/apt/lists/* /usr/share/doc
    python -m venv /app
    /app/bin/pip install -U "pip==${PIP_VERSION}"
    /app/bin/pip install Plone plone.volto ${EXTRA_PACKAGES} -c https://dist.plone.org/release/$PLONE_VERSION/constraints.txt  ${PIP_PARAMS}
    find /app \( -type f -a -name '*.pyc' -o -name '*.pyo' \) -exec rm -rf '{}' +
EOT

COPY --chown=500:500 /skeleton/etc /app/etc
COPY --chown=500:500 /skeleton/scripts /app/scripts
COPY --chown=500:500 /skeleton/docker-entrypoint.sh /app/
COPY --chown=500:500 /skeleton/inituser /app/


FROM base
ARG PYTHON_VERSION

LABEL maintainer="Plone Community <dev@plone.org>" \
      org.label-schema.name="plone-backend" \
      org.label-schema.description="Plone backend image image using Python $PYTHON_VERSION" \
      org.label-schema.vendor="Plone Foundation"

WORKDIR /app
COPY --from=builder --chown=500:500 /app /app

RUN <<EOT
    useradd --system -m -d /app -U -u 500 plone
    runDeps="git libjpeg62 libopenjp2-7 libpq5 libtiff5 libxml2 libxslt1.1 lynx netcat poppler-utils rsync wv busybox gosu libmagic1 make"
    apt-get update
    apt-get install -y --no-install-recommends $runDeps
    apt-get clean -y
    busybox --install -s
    rm -rf /var/lib/apt/lists/* /usr/share/doc
    mkdir -p /data/filestorage /data/blobstorage /data/log /data/cache
    chown -R plone:plone /data
    ln -s /data /app/var
EOT

VOLUME /data

HEALTHCHECK --interval=10s --timeout=5s --start-period=30s CMD [ -n "$LISTEN_PORT" ] || LISTEN_PORT=8080 ; wget -q http://127.0.0.1:$LISTEN_PORT/ok -O - | grep OK || exit 1

ENTRYPOINT [ "/app/docker-entrypoint.sh" ]
CMD ["start"]
