#!/usr/bin/env bash

set -euxo pipefail

instance_name="$1"
group_name="$2"

curl "https://raw.githubusercontent.com/dhis2-sre/im-manager/DEVOPS-102/scripts/login.sh" -O
chmod +x login.sh
eval $(./login.sh)

curl "https://raw.githubusercontent.com/dhis2-sre/im-manager/DEVOPS-102/scripts/destroy.sh" -O
chmod +x destroy.sh
./destroy.sh "$instance_name" "$group_name"
