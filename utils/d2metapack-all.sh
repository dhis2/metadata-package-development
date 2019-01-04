#!/bin/bash
cd ../metadata

PROG="*"

while getopts p: option
do
	case "${option}" in
		p) PROG=${OPTARG};;
	esac
done


PATTERN="./$PROG/*_conf.json"

FILES=$(ls -lhno $PATTERN | awk '{print $8}' | xargs)

d2metapack $FILES
