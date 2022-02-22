#!/usr/bin/env bash

set -euxo pipefail

name="$1"
type="$2"

IFS=';' read -ra package_components <<< "${name// - /;}"

health_area="${package_components[0]}"
intervention="${package_components[1]}"
if [[ -z "$DESCRIPTION" ]]; then
  description="${package_components[2]}"
fi
package_prefix="${package_components[3]}"

if [[ "$type" == "TKR" || "$type" == "EVT" ]]; then
  case "$DHIS2_VERSION" in
    "2.35")
      instance="https://metadata.dev.dhis2.org/tracker_dev"
      ;;
    "2.36")
      instance="https://metadata.dev.dhis2.org/tracker_dev236"
      ;;
    "2.37")
      instance="https://metadata.dev.dhis2.org/tracker_dev237"
      ;;
  esac
else
  case "$DHIS2_VERSION" in
    "2.35")
      instance="https://metadata.dev.dhis2.org/dev"
      ;;
    "2.36")
      instance="https://metadata.dev.dhis2.org/dev236"
      ;;
    "2.37")
      instance="https://metadata.dev.dhis2.org/dev237"
      ;;
  esac
fi

pip3 install -r dhis2-utils/tools/dhis2-package-exporter/requirements.txt

python3 -u dhis2-utils/tools/dhis2-package-exporter/package_exporter.py "$type" "$health_area" "$intervention" -v="$PACKAGE_VERSION" -desc="$description" -i="$instance" -pf="$package_prefix"

echo "$(ls -t1 ${health_area}*${intervention}*${DHIS2_VERSION}*.json | head -n 1)"
