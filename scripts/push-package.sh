#!/usr/bin/env bash

set -euxo pipefail

file="$1"

full_package_code="$(cat $file | jq -r '.package .code')"
version_branch="$(cat $file | jq -r '.package .DHIS2Version' | cut -d '.' -f 1,2)"


base_package_code=$(cut -d '_' -f 1,2 <<< "$full_package_code")
sub_package_code=$(cut -d '_' -f 3- <<< "$full_package_code")

repository_name=$(
  curl -fsSL "https://api.github.com/orgs/dhis2-metadata/repos?per_page=100" |
  jq -r --arg base_package_code "$base_package_code" '.[] | select(.name | contains($base_package_code)) | .name'
)

repository_url="https://$GITHUB_CREDS_PSW@github.com/dhis2-metadata/$repository_name"

commit_message="feat: Update $full_package_code package"
if [[ "${Custom_commit_message:-}" ]]; then
  commit_message="${Custom_commit_message}"
fi

git config --global user.email "$GITHUB_EMAIL"
git config --global user.name "$GITHUB_CREDS_USR"

git clone "$repository_url"
cd "$WORKSPACE/$repository_name"

git checkout "$version_branch"
mkdir -p "$sub_package_code" && cp "$WORKSPACE/$file" "$sub_package_code/metadata.json"
git add .

git commit -m "$commit_message"
git push "$repository_url"
