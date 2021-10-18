#!/bin/bash
set -e

# Create directories to be used by Plone
mkdir -p /data/filestorage /data/blobstorage /data/cache /data/log /app/var_instance


if [ -z ${USE_ZEO+x} ]; then
  echo "Using default configuration"
  CONF=zope.conf
else 
  echo "Using ZEO configuration"
  CONF=zeo.conf
fi

/app/bin/runwsgi -v etc/zope.ini config_file=${CONF}
