#!/usr/bin/env bash

set -euxo pipefail

port="$1"
user="${USER_NAME:-admin}"
pass="${USER_PASSWORD:-district}"
ou_root="${OU_ROOT_ID:-GD7TowwI46c}"

db_container=$(docker container ls --filter name=db -q)

docker exec -i "$db_container" psql -U dhis -d dhis -c "UPDATE dashboard SET sharing = jsonb_set(sharing, '{public}', '\"rw------\"');"
docker exec -i "$db_container" psql -U dhis -d dhis -c "INSERT INTO usermembership (organisationunitid, userinfoid) VALUES ((SELECT organisationunitid FROM organisationunit WHERE uid = '${ou_root}'), (SELECT userinfoid FROM userinfo WHERE code = '${user}'));"

echo "{\"dhis\": {\"baseurl\": \"http://localhost:${port}\", \"username\": \"${user}\", \"password\": \"${pass}\"}}" > auth.json

pip3 install -r dhis2-utils/tools/dhis2-dashboardchecker/requirements.txt

python3 dhis2-utils/tools/dhis2-dashboardchecker/dashboard_checker.py -i=http://localhost:${port} --omit-no_data_warning
