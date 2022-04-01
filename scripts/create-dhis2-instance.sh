#!/usr/bin/env bash

set -euxo pipefail

base_instance_name="$1"
group_name="$2"
instance_version="$3"

tracker_db_id=19
aggregate_db_id=20

tracker_instance_name="trk-$base_instance_name-${instance_version//./}"
aggregate_instance_name="agg-$base_instance_name-${instance_version//./}"

curl "https://raw.githubusercontent.com/dhis2-sre/im-manager/DEVOPS-102/scripts/login.sh" -O
chmod +x login.sh
eval $(./login.sh)

curl "https://raw.githubusercontent.com/dhis2-sre/im-manager/DEVOPS-102/scripts/dhis2-create.sh" -O
chmod +x dhis2-create.sh
./dhis2-create.sh "$tracker_instance_name" "$group_name"
./dhis2-create.sh "$aggregate_instance_name" "$group_name"

curl "https://raw.githubusercontent.com/dhis2-sre/im-manager/DEVOPS-102/scripts/dhis2-deploy.sh" -O
chmod +x dhis2-deploy.sh
./dhis2-deploy.sh "$tracker_instance_name" "$group_name" "$tracker_db_id"
./dhis2-deploy.sh "$aggregate_instance_name" "$group_name" "$aggregate_db_id"
