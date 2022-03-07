#!/bin/bash
set -eo pipefail

docker run -i --rm \
	-e CORS_ALLOW_ORIGIN="www.example.com" \
	"$1" cat /app/etc/package-includes/999-cors-overrides.zcml
