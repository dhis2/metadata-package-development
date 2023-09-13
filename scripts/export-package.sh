#!/usr/bin/env bash

set -euxo pipefail

code="$1"
type="$2"
description="$3"
health_area_name="$4"
health_area_code="$5"
export_instance="$6"

base_dhis2_version='2.38'
higher_dhis2_versions_server='https://who-dev.dhis2.org'

if [[ "${DHIS2_VERSION:-}" != "$base_dhis2_version" && -n "${DHIS2_VERSION:-}" ]]; then
  export_instance="${higher_dhis2_versions_server}/${export_instance##*/}${DHIS2_VERSION//./}"
fi

pip3 install -r dhis2-utils/tools/dhis2-package-exporter/requirements.txt

python3 -u dhis2-utils/tools/dhis2-package-exporter/package_exporter.py "$type" "$code" "$code" -desc="$description" -han="$health_area_name" -hac="$health_area_code" -i="$export_instance"
