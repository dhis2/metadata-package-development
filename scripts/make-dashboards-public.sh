#!/usr/bin/env bash

set -euxo pipefail

db_container=$(docker container ls --filter name=db -q)

docker exec -i "$db_container" psql -U dhis -d dhis2 -c "UPDATE dashboard SET sharing = jsonb_set(sharing, '{public}', '\"rw------\"');"
docker exec -i "$db_container" psql -U dhis -d dhis2 -c "INSERT INTO usermembership (organisationunitid, userinfoid) VALUES ((SELECT organisationunitid FROM organisationunit WHERE uid = '${OU_ROOT_ID:-GD7TowwI46c}'), (SELECT userinfoid FROM userinfo WHERE code = '${USER_NAME:-admin}'));"
