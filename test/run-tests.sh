#!/bin/bash

url=$URL
if [ -z "$url" ]; then
    echo "Please provide URL to dhis2 instance."
    exit 1
fi

if ./api-test.sh -f tests.json -url $url test merge_import; then 
  echo "Import with merge mode passed."
else 
  echo "Import with merge mode failed. Trying replace mode.."
  if ./api-test.sh -f tests.json -url $url test replace_import; then 
    echo "Import with replace mode passed. "

  else 
    echo "Import with replace mode failed. "
  fi
fi