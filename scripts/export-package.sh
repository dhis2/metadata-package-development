#!/usr/bin/env bash

set -euxo pipefail

code="$1"
type="$2"
description="$3"
export_instance="$4"

# Use the "path" of the base version host.
new_version_export_instance="https://who-dev.dhis2.org/${export_instance##*/}"

if [[ "${DHIS2_version:-}" ]]; then
  case "$DHIS2_version" in
    "2.37")
      instance="$export_instance"
      ;;
    "2.38")
      instance="${new_version_export_instance}238"
      ;;
    "2.39")
      instance="${new_version_export_instance}239"
      ;;
  esac
else
  instance="$export_instance"
fi

pip3 install -r dhis2-utils/tools/dhis2-package-exporter/requirements.txt

python3 -u dhis2-utils/tools/dhis2-package-exporter/package_exporter.py "$type" "$code" "$code" -desc="$description" -i="$instance"
