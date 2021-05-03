#!/bin/bash

url=$URL
creds=$credentials
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
    echo "Please provide URL to dhis2 instance."
    exit 1
fi

if ./api-test.sh -f tests.json -url $url -auth $creds test merge_import; then 
  MERGE_MODE_STATUS="PASSED"
else 
  MERGE_MODE_STATUS="FAILED"
  if ./api-test.sh -f tests.json -url $url -auth $creds test replace_import; then 
    REPLACE_MODE_STATUS="PASSED"

  else 
    REPLACE_MODE_STATUS="FAILED"
    print_status;
    exit 1
  fi
fi

print_status;
