#!/bin/bash

#Assumes d2metatest is working, i.e. dhis2-tools installed

echo "" >> result.log
echo `date` >> result.log

VERS="*"
PROG="*"

while getopts v:p: option
do
	case "${option}" in
		v) VERS=${OPTARG};;
		p) PROG=${OPTARG};;
	esac
done

PATTERN="../metadata/$PROG/*DHIS2.$VERS/metadata.json"

for METAFILE in $(ls -lhno $PATTERN 2> /dev/null | awk '{print $8}')
do
	VERSION=`echo $METAFILE| awk '{print substr ($0, length($0)-15, 2)}'`
	./d2metatest.sh $METAFILE $VERSION
done