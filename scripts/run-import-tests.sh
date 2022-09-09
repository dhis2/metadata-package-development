#!/usr/bin/env bash

set -euxo pipefail

file="$1"
port="$2"

auth="${USER_NAME:-admin}:${USER_PASSWORD:-district}"
url="http://localhost:$port"

cat "$file" |
  sed "s/<OU_LEVEL_DISTRICT_UID>/${OU_DISTRICT_UID:-qpXLDdXT3po}/g" |
  sed "s/<OU_LEVEL_FACILITY_UID>/${OU_FACILITY_UID:-vFr4zVw6Avn}/g" |
  sed "s/<OU_ROOT_UID>/${OU_ROOT_UID:-GD7TowwI46c}/g" > ./package.json

./api-test.sh -v -f ./tests.json -url "$url" -auth "$auth" test ou_import

URL="$url" AUTH="$auth" ./run-tests.sh
