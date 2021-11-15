#!/bin/bash
set -eo pipefail
dir="$(dirname "$(readlink -f "$BASH_SOURCE")")"

docker run -i --rm \
	-e DEVELOP="/app/src/helloworld" \
	-e PIP_PARAMS="--use-deprecated legacy-resolver -q --disable-pip-version-check" \
	-v "$dir/helloworld:/app/src/helloworld" \
	"$1" bin/python -c "from helloworld import say_hi; say_hi()"
