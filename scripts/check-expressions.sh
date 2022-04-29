#!/usr/bin/env bash

set -euxo pipefail

port="$1"
user="${USER_NAME:-admin}"
pass="${USER_PASSWORD:-district}"

echo -e "[localhost]\nserver=http://localhost:${port}/api/\nserver_name=localhost\nuser=${user}\npassword=${pass}\npage_size=500" > credentials.ini

python3 dhis2-metadata-checkers/check_expressions.py --credentials localhost
