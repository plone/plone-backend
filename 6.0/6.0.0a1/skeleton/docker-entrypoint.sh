#!/bin/bash
set -e

PIP_PARAMS="--use-deprecated legacy-resolver"

# Create directories to be used by Plone
mkdir -p /data/filestorage /data/blobstorage /data/cache /data/log /app/var_instance
find /data -not -user plone -exec chown plone:plone {} \+
find /app/var_instance  -not -user plone -exec chown plone:plone {} \+

# MAIN ENV Vars
[ -z ${SECURITY_POLICY_IMPLEMENTATION+x} ] && export SECURITY_POLICY_IMPLEMENTATION=C
[ -z ${VERBOSE_SECURITY+x} ] && export VERBOSE_SECURITY=off
[ -z ${DEFAULT_ZPUBLISHER_ENCODING+x} ] && export DEFAULT_ZPUBLISHER_ENCODING=utf-8
[ -z ${DEBUG_MODE+x} ] && export DEBUG_MODE=off

# ZODB ENV Vars
[ -z ${ZODB_CACHE_SIZE+x} ] && export ZODB_CACHE_SIZE=50000

if [[ -v RELSTORAGE_DSN ]]; then
  echo "Using Relstorage configuration"
  CONF=relstorage.conf
  # Relstorage ENV Vars
  [ -z ${RELSTORAGE_NAME+x} ] && export RELSTORAGE_NAME=storage
  [ -z ${RELSTORAGE_READ_ONLY+x} ] && export RELSTORAGE_READ_ONLY=off
  [ -z ${RELSTORAGE_KEEP_HISTORY+x} ] && export RELSTORAGE_KEEP_HISTORY=true
  [ -z ${RELSTORAGE_COMMIT_LOCK_TIMEOUT+x} ] && export RELSTORAGE_COMMIT_LOCK_TIMEOUT=30
  [ -z ${RELSTORAGE_CREATE_SCHEMA+x} ] && export RELSTORAGE_CREATE_SCHEMA=true
  [ -z ${RELSTORAGE_SHARED_BLOB_DIR+x} ] && export RELSTORAGE_SHARED_BLOB_DIR=false
  [ -z ${RELSTORAGE_BLOB_CACHE_SIZE+x} ] && export RELSTORAGE_BLOB_CACHE_SIZE=100mb
  [ -z ${RELSTORAGE_BLOB_CACHE_SIZE_CHECK+x} ] && export RELSTORAGE_BLOB_CACHE_SIZE_CHECK=10
  [ -z ${RELSTORAGE_BLOB_CACHE_SIZE_CHECK_EXTERNAL+x} ] && export RELSTORAGE_BLOB_CACHE_SIZE_CHECK_EXTERNAL=false
  [ -z ${RELSTORAGE_BLOB_CHUNK_SIZE+x} ] && export RELSTORAGE_BLOB_CHUNK_SIZE=1048576
  [ -z ${RELSTORAGE_CACHE_LOCAL_MB+x} ] && export RELSTORAGE_CACHE_LOCAL_MB=10
  [ -z ${RELSTORAGE_CACHE_LOCAL_OBJECT_MAX+x} ] && export RELSTORAGE_CACHE_LOCAL_OBJECT_MAX=16384
  [ -z ${RELSTORAGE_CACHE_LOCAL_COMPRESSION+x} ] && export RELSTORAGE_CACHE_LOCAL_COMPRESSION=none
  [ -z ${RELSTORAGE_CACHE_DELTA_SIZE_LIMIT+x} ] && export RELSTORAGE_CACHE_DELTA_SIZE_LIMIT=100000
elif  [[ -v ZEO_ADDRESS ]]; then
  echo "Using ZEO configuration"
  CONF=zeo.conf
  # Check ZEO variables
  [ -z ${ZEO_SHARED_BLOB_DIR+x} ] && export ZEO_SHARED_BLOB_DIR=off
  [ -z ${ZEO_READ_ONLY+x} ] && export ZEO_READ_ONLY=false
  [ -z ${ZEO_CLIENT_READ_ONLY_FALLBACK+x} ] && export ZEO_CLIENT_READ_ONLY_FALLBACK=false
  [ -z ${ZEO_STORAGE+x} ] && export ZEO_STORAGE=1
  [ -z ${ZEO_CLIENT_CACHE_SIZE+x} ] && export ZEO_CLIENT_CACHE_SIZE=128MB
  [ -z ${ZEO_DROP_CACHE_RATHER_VERIFY+x} ] && export ZEO_DROP_CACHE_RATHER_VERIFY=false
else
  echo "Using default configuration"
  CONF=zope.conf
fi

# Handle ADDONS installation
if [[ -v ADDONS ]]; then
  echo "======================================================================================="
  echo "Installing ADDONS ${ADDONS}"
  echo "THIS IS NOT MEANT TO BE USED IN PRODUCTION"
  echo "Read about it: https://github.com/plone/plone-backend/#extending-from-this-image"
  echo "======================================================================================="
  gosu plone /app/bin/pip install "${ADDONS}" ${PIP_PARAMS}
fi

# Handle development addons
if [[ -v DEVELOP ]]; then
  echo "======================================================================================="
  echo "Installing DEVELOPment addons ${DEVELOP}"
  echo "THIS IS NOT MEANT TO BE USED IN PRODUCTION"
  echo "Read about it: https://github.com/plone/plone-backend/#extending-from-this-image"
  echo "======================================================================================="
  gosu plone /app/bin/pip install --editable "${DEVELOP}" ${PIP_PARAMS}
fi

if [[ "$1" == "start" ]]; then
  exec gosu plone /app/bin/runwsgi -v etc/zope.ini config_file=${CONF}
elif  [[ "$1" == "create-classic" ]]; then
  TYPE=classic
  exec gosu plone /app/bin/zconsole run etc/${CONF} /app/scripts/create_site.py
elif  [[ "$1" == "create-volto" ]]; then
  TYPE=volto
  exec gosu plone /app/bin/zconsole run etc/${CONF} /app/scripts/create_site.py
elif  [[ "$1" == "create-site" ]]; then
  TYPE=volto
  exec gosu plone /app/bin/zconsole run etc/${CONF} /app/scripts/create_site.py
else
  # Custom
  exec "$@"
fi
