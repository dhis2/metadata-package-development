#!/usr/bin/env bash

set -euxo pipefail

file="$1"

prefix="$(cat $file | jq -r '.package .code')"
version="$(cat $file | jq -r '.package .DHIS2Version' | cut -d '.' -f 1,2)"

package_code="${prefix:0:4}"
sub_package_code="${prefix:4:2}"

repository_name=$(
  curl -fsSL "https://api.github.com/orgs/dhis2-metadata/repos?per_page=100" |
  jq -r --arg package_code "$package_code" '.[] | select(.name | contains($package_code)) | .name'
)

repository_url="https://$GITHUB_CREDS_PSW@github.com/dhis2-metadata/$repository_name"

git config --global user.email "$GITHUB_EMAIL"
git config --global user.name "$GITHUB_CREDS_USR"

git clone "$repository_url"
cd "$WORKSPACE/$repository_name"

git checkout "test-$version"
mkdir -p "$sub_package_code" && cp "$WORKSPACE/$file" "$sub_package_code/metadata.json"
git add .

git commit -m "Some message ..."
git push "$repository_url"
