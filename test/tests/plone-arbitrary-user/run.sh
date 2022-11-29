#!/bin/bash
set -eo pipefail

dir="$(dirname "$(readlink -f "$BASH_SOURCE")")"

image="$1"

PLONE_TEST_SLEEP=3
PLONE_TEST_TRIES=5

vname="/tmp/plone-data-$RANDOM-$RANDOM"
cname="plone-container-$RANDOM-$RANDOM"
vid="$(mkdir -p $vname)"
cid="$(docker run -d --user=$(id -u) -v $vname:/data --name $cname $image)"
trap "docker rm -vf $cid > /dev/null; rm -rf $vname > /dev/null" EXIT

get() {
	docker run --rm -i \
		--link "$cname":plone \
		--entrypoint /app/bin/python \
		"$image" \
		-c "from urllib.request import urlopen; con = urlopen('$1'); print(con.read())"
}

get_auth() {
	docker run --rm -i \
		--link "$cname":plone \
		--entrypoint /app/bin/python \
		"$image" \
		-c "from urllib.request import urlopen, Request; request = Request('$1'); request.add_header('Authorization', 'Basic $2'); print(urlopen(request).read())"
}


. "$dir/../../retry.sh" --tries "$PLONE_TEST_TRIES" --sleep "$PLONE_TEST_SLEEP" get "http://plone:8080"

# Plone is up and running
[[ "$(get 'http://plone:8080')" == *"Plone is up and running"* ]]

# Create a Plone site
[[ "$(get_auth 'http://plone:8080/@@plone-addsite' "$(echo -n 'admin:admin' | base64)")" == *"Create a Plone site"* ]]