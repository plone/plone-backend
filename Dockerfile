# syntax=docker/dockerfile:1
ARG PYTHON_VERSION=3.11
ARG PLONE_VERSION
FROM plone/server-builder:${PLONE_VERSION} as builder
FROM plone/server-prod-config:${PLONE_VERSION}

LABEL maintainer="Plone Community <dev@plone.org>" \
      org.label-schema.name="plone-backend" \
      org.label-schema.description="Plone backend image image using Python $PYTHON_VERSION" \
      org.label-schema.vendor="Plone Foundation"

WORKDIR /app
COPY --from=builder --chown=500:500 /app /app

RUN <<EOT
    ln -s /data /app/var
EOT

VOLUME /data
