#!/usr/bin/env bash

set -euxo pipefail

server_url="$1"
default_server_name='default'

echo -e "[$default_server_name]\nserver=$server_url/api/\nserver_name=$default_server_name\nuser=${USER_NAME:-admin}\npassword=${USER_PASSWORD:-district}\npage_size=500" > credentials.ini

python3 dhis2-metadata-checkers/check_expressions.py --credentials $default_server_name
