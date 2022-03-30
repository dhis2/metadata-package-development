#!/usr/bin/env bash

set -euxo pipefail

instance_name="pipeline-instance-${1//./}-$(date +%s)"

curl "https://raw.githubusercontent.com/dhis2-sre/im-manager/DEVOPS-102/scripts/login.sh" -O
chmod +x login.sh
eval $(./login.sh)

curl "https://raw.githubusercontent.com/dhis2-sre/im-manager/DEVOPS-102/scripts/dhis2-create.sh" -O
chmod +x dhis2-create.sh
./dhis2-create.sh "$instance_name" whoami

curl "https://raw.githubusercontent.com/dhis2-sre/im-manager/DEVOPS-102/scripts/dhis2-deploy.sh" -O
chmod +x dhis2-deploy.sh
./dhis2-deploy.sh "$instance_name" whoami 19
