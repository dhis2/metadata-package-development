#!/usr/bin/env bash

set -euxo pipefail

name="$1"
type="$2"

IFS=';' read -ra package_components <<< "${name// - /;}"

package_prefix="${package_components[0]}"
package_code="${package_components[1]}"
description="${package_components[2]}"

if [[ "${Custom_description:-}" ]]; then
  description="${Custom_description}"
fi

if [[ "${Instance_url:-}" ]]; then
  instance="$Instance_url"
else
  if [[ "$type" == "TRK" || "$type" == "EVT" ]]; then
    case "$DHIS2_version" in
      "2.36")
        instance="https://metadata.dev.dhis2.org/tracker_dev"
        ;;
      "2.37")
        instance="https://who-dev.dhis2.org/tracker_dev236"
        ;;
      "2.38")
        instance="https://who-dev.dhis2.org/tracker_dev237"
        ;;
    esac
  else
    case "$DHIS2_version" in
      "2.36")
        instance="https://metadata.dev.dhis2.org/dev"
        ;;
      "2.37")
        instance="https://who-dev.dhis2.org/dev236"
        ;;
      "2.38")
        instance="https://who-dev.dhis2.org/dev237"
        ;;
    esac
  fi
fi

pip3 install -r dhis2-utils/tools/dhis2-package-exporter/requirements.txt

python3 -u dhis2-utils/tools/dhis2-package-exporter/package_exporter.py "$type" "$package_prefix" "$package_code" -v="$Package_version" -desc="$description" -i="$instance"
