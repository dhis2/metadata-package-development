#!/usr/bin/env bash

set -euxo pipefail

file="$1"

package_prefix="$(cat $file | jq -r '.package .code')"
version_branch="$(cat $file | jq -r '.package .DHIS2Version' | cut -d '.' -f 1,2)"

package_code="${package_prefix:0:4}"
sub_package_code="${package_prefix:4:2}"

repository_name=$(
  curl -fsSL "https://api.github.com/orgs/dhis2-metadata/repos?per_page=100" |
  jq -r --arg package_code "$package_code" '.[] | select(.name | contains($package_code)) | .name'
)

repository_url="https://$GITHUB_CREDS_PSW@github.com/dhis2-metadata/$repository_name"

commit_message="feat: Update $package_prefix package"
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
