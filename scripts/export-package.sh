#!/usr/bin/env bash

set -euxo pipefail

name="$1"
type="$2"
instance_name="$3"

instance_base_url="https://whoami.im.test.c.dhis2.org"

IFS=';' read -ra package_components <<< "${name// - /;}"

health_area="${package_components[0]}"
intervention="${package_components[1]}"
if [[ -z "${DESCRIPTION:-}" ]]; then
  description="${package_components[2]}"
fi
package_prefix="${package_components[3]}"

if [[ "$type" == "TKR" || "$type" == "EVT" ]]; then
  instance="$instance_base_url/trk-$instance_name-${DHIS2_version//./}"
else
  instance="$instance_base_url/agg-$instance_name-${DHIS2_version//./}"
fi

pip3 install -r dhis2-utils/tools/dhis2-package-exporter/requirements.txt

python3 -u dhis2-utils/tools/dhis2-package-exporter/package_exporter.py "$type" "$health_area" "$intervention" -v="$Package_version" -desc="$description" -i="$instance" -pf="$package_prefix"
