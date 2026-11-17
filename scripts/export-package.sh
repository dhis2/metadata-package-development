#!/usr/bin/env bash

set -euxo pipefail

code="$1"
type="$2"
description="$3"
health_area_name="$4"
health_area_code="$5"
export_instance="$6"

if [[ -z "$export_instance" ]]; then
  echo 'No export instance URL provided.' >&2
  exit 1
fi

python3 -m venv .venv
.venv/bin/pip install -r dhis2-utils/tools/dhis2-package-exporter/requirements.txt

.venv/bin/python -u dhis2-utils/tools/dhis2-package-exporter/package_exporter.py "$type" "$code" "$code" -desc="$description" -han="$health_area_name" -hac="$health_area_code" -i="$export_instance"
