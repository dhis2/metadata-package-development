#!/usr/bin/env bash

set -euxo pipefail

base_instance_name="$1"
group_name="$2"
instance_version="$3"

tracker_instance_name="trk-$base_instance_name-${instance_version//./}"
aggregate_instance_name="agg-$base_instance_name-${instance_version//./}"

curl "https://raw.githubusercontent.com/dhis2-sre/im-manager/DEVOPS-102/scripts/login.sh" -O
chmod +x login.sh
eval $(./login.sh)

curl "https://raw.githubusercontent.com/dhis2-sre/im-manager/DEVOPS-102/scripts/destroy.sh" -O
chmod +x destroy.sh
./destroy.sh "$tracker_instance_name" "$group_name"
#./destroy.sh "$aggregate_instance_name" "$group_name"
