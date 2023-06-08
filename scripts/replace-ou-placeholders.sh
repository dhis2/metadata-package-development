#!/usr/bin/env bash

set -euxo pipefail

file="$1"

sed "s/<OU_LEVEL_DISTRICT_UID>/${OU_DISTRICT_UID:-qpXLDdXT3po}/g" "$file" |
  sed "s/<OU_LEVEL_FACILITY_UID>/${OU_FACILITY_UID:-vFr4zVw6Avn}/g" |
  sed "s/<OU_ROOT_UID>/${OU_ROOT_UID:-GD7TowwI46c}/g"
