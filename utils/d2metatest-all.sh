#!/bin/bash

#Assumes d2metatest is working, i.e. dhis2-tools installed

echo "" >> result.log
echo `date` >> result.log

if [ $# -eq 0 ]
  then
    PATTERN="../metadata/*/*DHIS2.*/metadata.json"
else
	PATTERN="../metadata/*/*DHIS2.$1/metadata.json"
fi

for METAFILE in $(ls -lhno $PATTERN | awk '{print $8}')
do
	VERSION=`echo $METAFILE| awk '{print substr ($0, length($0)-15, 2)}'`
	./d2metatest.sh $METAFILE $VERSION
done