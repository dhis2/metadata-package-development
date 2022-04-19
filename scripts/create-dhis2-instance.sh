#!/usr/bin/env bash

set -euxo pipefail

base_instance_name="$1"
group_name="$2"
instance_version="$3"
delay="$4"

tracker_db_id=1
#aggregate_db_id=

tracker_instance_name="trk-$base_instance_name-${instance_version//./}"
#aggregate_instance_name="agg-$base_instance_name-${instance_version//./}"

curl "https://raw.githubusercontent.com/dhis2-sre/im-manager/DEVOPS-102/scripts/login.sh" -O
chmod +x login.sh
eval $(./login.sh)

curl "https://raw.githubusercontent.com/dhis2-sre/im-manager/DEVOPS-102/scripts/dhis2-create.sh" -O
chmod +x dhis2-create.sh
./dhis2-create.sh "$tracker_instance_name" "$group_name"
#./dhis2-create.sh "$aggregate_instance_name" "$group_name"

###
default_tag="$instance_version.6-tomcat-8.5.34-jre8-alpine"
tag=${DHIS2_IMAGE_TAG:-$default_tag}

group_id=$($HTTP get "$INSTANCE_HOST/groups-name-to-id/$group_name" "Authorization: Bearer $ACCESS_TOKEN")
instance_id=$($HTTP get "$INSTANCE_HOST/instances-name-to-id/$group_id/$tracker_instance_name" "Authorization: Bearer $ACCESS_TOKEN")

echo "{
  \"name\": \"$tracker_instance_name\",
  \"groupId\": $group_id,
  \"stackId\": 1,
  \"requiredParameters\": [
    {
      \"stackParameterId\": 1,
      \"value\": \"$tracker_db_id\"
    }
  ],
  \"optionalParameters\": [
      {
        \"stackParameterId\": 10,
        \"value\": \"$tag\"
      },
      {
        \"stackParameterId\": 5,
        \"value\": \"$delay\"
      },
      {
        \"stackParameterId\": 11,
        \"value\": \"$delay\"
      }
    ]
}" | $HTTP post "$INSTANCE_HOST/instances/$instance_id/deploy" "Authorization: Bearer $ACCESS_TOKEN"
###

#curl "https://raw.githubusercontent.com/dhis2-sre/im-manager/DEVOPS-102/scripts/dhis2-deploy.sh" -O
#chmod +x dhis2-deploy.sh
#./dhis2-deploy.sh "$tracker_instance_name" "$group_name" "$tracker_db_id"
#./dhis2-deploy.sh "$aggregate_instance_name" "$group_name" "$aggregate_db_id"
