#!/bin/bash

if ./api-test.sh -f tests.json -url http://localhost:8080/api test merge_import; then 
  echo "Import with merge mode passed."
else 
  echo "Import with merge mode failed. Trying replace mode.."
  if ./api-test.sh -f tests.json -url http://localhost:8080/api test replace_import; then 
    echo "Import with replace mode passed. "

  else 
    echo "Import with replace mode failed. "
  fi
fi