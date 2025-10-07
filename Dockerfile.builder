# syntax=docker/dockerfile:1.9
ARG PYTHON_VERSION=3.12

FROM python:${PYTHON_VERSION}-slim-trixie

SHELL ["sh", "-exc"]
ENV DEBIAN_FRONTEND=noninteractive
RUN <<EOT
    buildDeps="build-essential busybox ca-certificates curl git gosu libbz2-dev libffi-dev libjpeg62-turbo-dev libmagic1 libsasl2-dev libldap2-dev libopenjp2-7-dev libpq-dev libssl-dev libtiff6 libtiff5-dev libxml2-dev libxslt1-dev wget zlib1g-dev"
    apt-get update -qy
    apt-get install -qyy \
        -o APT::Install-Recommends=false \
        -o APT::Install-Suggests=false \
        $buildDeps
    busybox --install -s
EOT

COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

ENV UV_LINK_MODE=copy \
    UV_COMPILE_BYTECODE=1 \
    UV_PYTHON_DOWNLOADS=never \
    UV_PYTHON=python$PYTHON_VERSION \
    UV_PROJECT_ENVIRONMENT=/app

# Script used for pre-compilation of po files
COPY /helpers/compile_mo.py /compile_mo.py

# Copy default structure for a Plone Project
COPY /skeleton /app_skeleton

LABEL maintainer="Plone Community <dev@plone.org>" \
      org.label-schema.name="server-builder" \
      org.label-schema.description="Plone builder image with Python $PYTHON_VERSION and UV" \
      org.label-schema.vendor="Plone Foundation"
