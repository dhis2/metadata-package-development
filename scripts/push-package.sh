#!/usr/bin/env bash

set -euxo pipefail

PACKAGE_PREFIX="$1"
DHIS2_VERSION="$2"

GITHUB_REPO=$(
  curl -fsSL "https://api.github.com/orgs/dhis2-metadata/repos?per_page=100" |
  jq -r --arg PREFIX "$PACKAGE_PREFIX" '.[] | select(.name | contains($PREFIX)) | .name'
)

git config --global user.email ""
git config --global user.name "$GITHUB_CREDS_USR"

git clone "https://$GITHUB_CREDS_PSW@github.com/dhis2-metadata/$GITHUB_REPO"
cd "$WORKSPACE/$GITHUB_REPO"

git checkout -b "test-$DHIS2_VERSION"
cp "$WORKSPACE/$INPUT_FILE_NAME" .
git add .

git commit -m "Some message ..."
git push "https://$GITHUB_CREDS_PSW@github.com/dhis2-metadata/$GITHUB_REPO" --dry-run
