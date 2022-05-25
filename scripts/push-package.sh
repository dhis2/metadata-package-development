#!/usr/bin/env bash

set -euxo pipefail

file="$1"

packages_dir="packages"
full_package_dir="COMPLETE"
dashboard_package_dir="DASHBOARD"

dashboard_package_type="DSH"

full_package_code="$(cat $file | jq -r '.package .code')"
package_type="$(cat $file | jq -r '.package .type')"
version_branch="$(cat $file | jq -r '.package .DHIS2Version' | cut -d '.' -f 1,2)"

base_package_code=$(cut -d '_' -f 1,2 <<< "$full_package_code")
sub_package_code=$(cut -d '_' -f 3- <<< "$full_package_code")

repository_name=$(
  curl -fsSL "https://api.github.com/orgs/dhis2-metadata/repos?per_page=100" |
  jq -r --arg base_package_code "$base_package_code" '.[] | select(.name | contains($base_package_code)) | .name'
)

repository_url="https://$GITHUB_CREDS_PSW@github.com/dhis2-metadata/$repository_name"

destination_dir="$packages_dir/$full_package_dir"

commit_message="feat: Update $full_package_code package"

if [[ "$sub_package_code" ]]; then
  destination_dir="$sub_package_code"
fi

if [[ "$package_type" == "$dashboard_package_type" ]]; then
  destination_dir="${destination_dir}/${dashboard_package_dir}"
  commit_message="$commit_message ($dashboard_package_type)"
fi

if [[ "${Commit_message:-}" ]]; then
  commit_message="${Commit_message}"
fi

git config --global user.email "$GITHUB_EMAIL"
git config --global user.name "$GITHUB_CREDS_USR"

git clone "$repository_url"
cd "$WORKSPACE/$repository_name"

git checkout "nested-$version_branch"

mkdir -p "$destination_dir" && cp "$WORKSPACE/$file" "$destination_dir/metadata.json"
git add .

git commit -m "$commit_message"

git_retry_push() {
  local retries=10
  local delay=1

  for ((attempt=0; attempt<retries; attempt++))
  do
    git pull origin "nested-$version_branch" && git push "$repository_url" && break
    echo "Push failed, retying in $delay seconds..."
    sleep $delay
  done

  if (( retries == attempt )); then
    echo 'Push failed!'
    exit 1
  fi
}

git_retry_push
