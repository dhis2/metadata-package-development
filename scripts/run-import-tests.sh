#!/usr/bin/env bash

set -euxo pipefail

port="$1"

auth="${USER_NAME:-admin}:${USER_PASSWORD:-district}"
url="http://localhost:$port"

./api-test.sh -v -f ./tests.json -url "$url" -auth "$auth" test ou_import

URL="$url" AUTH="$auth" ./run-tests.sh
