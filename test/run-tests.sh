#!/bin/bash

url=$URL
auth=$AUTH
MERGE_MODE_STATUS="NOT_EXECUTED"
REPLACE_MODE_STATUS="NOT_EXECUTED"


print_status() {
  divider=======================
  divider=$divider$divider
  header="\n %-10s %15s\n"
  format=" %-10s %15s\n"
  width=43

  printf "$header" "TEST" "RESULT"
  printf "%$width.${width}s\n" "$divider"
  printf "$format" "MERGE"  "$MERGE_MODE_STATUS" 
  printf "$format" "REPLACE" "$REPLACE_MODE_STATUS"
  printf "%$width.${width}s\n" "$divider"
}

if [ -z "$url" ]; then
    echo "Please provide an URL of dhis2 instance."
    exit 1
fi

if ./api-test.sh -v -f tests.json -url $url -auth $auth test merge_import; then
  MERGE_MODE_STATUS="PASSED"
else 
  MERGE_MODE_STATUS="FAILED"
  if ./api-test.sh -v -f tests.json -url $url -auth $auth test replace_import; then
    REPLACE_MODE_STATUS="PASSED"

  else 
    REPLACE_MODE_STATUS="FAILED"
    print_status;
    exit 1
  fi
fi

print_status;
