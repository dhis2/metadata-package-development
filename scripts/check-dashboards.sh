#!/usr/bin/env bash

set -euxo pipefail

instance_url="$1"

echo "{\"dhis\": {\"username\": \"${USER_NAME:-admin}\", \"password\": \"${USER_PASSWORD:-district}\"}}" > auth.json

pip3 install -r dhis2-utils/tools/dhis2-dashboardchecker/requirements.txt

python3 dhis2-utils/tools/dhis2-dashboardchecker/dashboard_checker.py -i="$instance_url" --omit-no_data_warning
