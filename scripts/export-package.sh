#!/usr/bin/env bash

set -euxo pipefail

code="$1"
type="$2"
description="$3"
base_version_host="$4"

# Use the "path" of the base version host.
new_version_host="https://who-dev.dhis2.org/${base_version_host##*/}"

case "$DHIS2_version" in
  "2.36")
    instance="$base_version_host"
    ;;
  "2.37")
    instance="${new_version_host}237"
    ;;
  "2.38")
    instance="${new_version_host}238"
    ;;
esac

pip3 install -r dhis2-utils/tools/dhis2-package-exporter/requirements.txt

python3 -u dhis2-utils/tools/dhis2-package-exporter/package_exporter.py "$type" "$code" "$code" -desc="$description" -i="$instance"
