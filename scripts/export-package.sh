#!/usr/bin/env bash

set -euxo pipefail

code="$1"
type="$2"
description="$3"
health_area_name="$4"
health_area_code="$5"
export_instance="$6"

if [[ "$DHIS2_version" == "2.38" || -z "$DHIS2_version" ]]; then
  instance="$export_instance"
else
  instance="https://who-dev.dhis2.org/${export_instance##*/}${DHIS2_version//./}"
fi

pip3 install -r dhis2-utils/tools/dhis2-package-exporter/requirements.txt

python3 -u dhis2-utils/tools/dhis2-package-exporter/package_exporter.py "$type" "$code" "$code" -desc="$description" -han="$health_area_name" -hac="$health_area_code" -i="$instance"
