#!/bin/bash
set -eo pipefail

dir="$(dirname "$(readlink -f "$BASH_SOURCE")")"

image="$1"

PLONE_TEST_SLEEP=10
PLONE_TEST_TRIES=10

# Start ZEO server
zname="zeo-container-$RANDOM-$RANDOM"
zpull="$(docker pull plone/plone-zeo)"
zid="$(docker run -d -v $zname:/data --name "$zname" plone/plone-zeo)"

# Start Plone as ZEO Client
pname="plone-container-$RANDOM-$RANDOM"
pid="$(docker run -d -v $zname:/data -e ZEO_SHARED_BLOB_DIR=on --name "${pname}" --link=$zname:zeo -e ZEO_ADDRESS=zeo:8100 "$image")"

# Tear down
trap "docker rm -vf $pid $zid > /dev/null" EXIT

get() {
	docker run --rm -i \
		--link "${pname}":plone \
		--entrypoint /app/bin/python \
		"$image" \
		-c "from urllib.request import urlopen; con = urlopen('$1'); print(con.read())"
}

get_auth() {
	docker run --rm -i \
		--link "${pname}":plone \
		--entrypoint /app/bin/python \
		"$image" \
		-c "from urllib.request import urlopen, Request; request = Request('$1'); request.add_header('Authorization', 'Basic $2'); print(urlopen(request).read())"
}

. "$dir/../../retry.sh" --tries "$PLONE_TEST_TRIES" --sleep "$PLONE_TEST_SLEEP" get "http://plone:8080"

# Plone is up and running
[[ "$(get 'http://plone:8080')" == *"Plone is up and running"* ]]

# Create a Plone site
[[ "$(get_auth 'http://plone:8080/@@plone-addsite' "$(echo -n 'admin:admin' | base64)")" == *"Create a Plone site"* ]]
