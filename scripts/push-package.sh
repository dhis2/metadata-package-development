#!/usr/bin/env bash

set -euxo pipefail

PACKAGE_PREFIX="$1"
DHIS2_VERSION="$2"

PACKAGE_CODE="${PACKAGE_PREFIX:0:4}"
SUB_PACKAGE_CODE="${PACKAGE_PREFIX:4:2}"

GITHUB_REPO=$(
  curl -fsSL "https://api.github.com/orgs/dhis2-metadata/repos?per_page=100" |
  jq -r --arg PACKAGE_CODE "$PACKAGE_CODE" '.[] | select(.name | contains($PACKAGE_CODE)) | .name'
)

git config --global user.email "$GITHUB_EMAIL"
git config --global user.name "$GITHUB_CREDS_USR"

git clone "https://$GITHUB_CREDS_PSW@github.com/dhis2-metadata/$GITHUB_REPO"
cd "$WORKSPACE/$GITHUB_REPO"

git checkout "$DHIS2_VERSION"
git checkout -b "test-$DHIS2_VERSION"
mkdir -p "$SUB_PACKAGE_CODE" && cp "$WORKSPACE/$PACKAGE_FILE" "$SUB_PACKAGE_CODE/metadata.json"
git add .

git commit -m "Some message ..."
git push "https://$GITHUB_CREDS_PSW@github.com/dhis2-metadata/$GITHUB_REPO"
