#!/bin/bash
set -eo pipefail

docker run -i --rm \
	-e ADDONS="eea.facetednavigation" \
	-e PIP_PARAMS="--use-deprecated legacy-resolver -q --disable-pip-version-check" \
	"$1" bin/python -c "from eea import facetednavigation; print(facetednavigation.__name__)"
