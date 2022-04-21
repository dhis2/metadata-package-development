#!/usr/bin/env bash

set -euxo pipefail

name="$1"
type="$2"

IFS=';' read -ra package_components <<< "${name// - /;}"

package_prefix="${package_components[0]}"
package_code="${package_components[1]}"
if [[ -z "${DESCRIPTION:-}" ]]; then
  description="${package_components[2]}"
fi

if [[-z "${INSTANCE_URL:-}" ]]; then
  instance = "$INSTANCE_URL"
  echo "$INSTANCE_URL"
  echo "$instance"
else
  if [[ "$type" == "TRK" || "$type" == "EVT" ]]; then
    case "$DHIS2_version" in
      "2.35")
        instance="https://metadata.dev.dhis2.org/tracker_dev"
        ;;
      "2.36")
        instance="https://who-dev.dhis2.org/tracker_dev236"
        ;;
      "2.37")
        instance="https://who-dev.dhis2.org/tracker_dev237"
        ;;
    esac
  else
    case "$DHIS2_version" in
      "2.35")
        instance="https://metadata.dev.dhis2.org/dev"
        ;;
      "2.36")
        instance="https://who-dev.dhis2.org/dev236"
        ;;
      "2.37")
        instance="https://who-dev.dhis2.org/dev237"
        ;;
    esac
  fi
fi

pip3 install -r dhis2-utils/tools/dhis2-package-exporter/requirements.txt

python3 -u dhis2-utils/tools/dhis2-package-exporter/package_exporter.py "$type" "$package_prefix" "$package_code" -v="$Package_version" -desc="$description" -i="$instance"
