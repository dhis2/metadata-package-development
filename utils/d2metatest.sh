#!/bin/bash

#Assumes dhis2-tools are installed

DATA=$1
VERSION=$2
DATE=`date +'%Y-%m-%d'`
WARFILE=/tmp/dhis2$VERSION-$DATE.war
DBNAME=metatest$VERSION
PORT="90"$VERSION

echo "Checking metadata file "$DATA" with DHIS2 version 2."$VERSION

#Save and reuse .war files from the same day (or until /tmp/ is cleared)
#Saves time since we will re-use them with potentially many metadata files
if [ ! -f $WARFILE ]; then
    echo "File "$WARFILE" not found!"
    wget -O $WARFILE https://s3-eu-west-1.amazonaws.com/releases.dhis2.org/2.$VERSION/dhis.war
fi

dhis2-instance-create -p $PORT $DBNAME > /dev/null

dhis2-deploy-war -f $WARFILE $DBNAME > /dev/null


( dhis2-logtail $DBNAME & ) | grep -q "INFO: Server startup in"
kill $(ps aux | grep 'logtail metatest' | awk '{print $2}') 2> /dev/null > /dev/null
echo "Server started"

sleep 5

echo "Server running, admin user was created "`curl -s -u admin:district "http://localhost:"$PORT"/"$DBNAME"/api/me.json" | python -c "import sys, json; print(json.load(sys.stdin)['created'])"`

URL="http://localhost:"$PORT"/"$DBNAME"/api/metadata"
if [ $VERSION -gt 27 ]; 
then
	URL=$URL"?atomicMode=NONE"
fi

echo "Uploading file to "$URL

RESULT=`curl -s -X POST -u admin:district -d @$DATA -H "Content-Type: application/json" "$URL"`
STATUS=`echo $RESULT | python -c "import sys, json; print(json.load(sys.stdin)['status'])"`
echo "Status: "$STATUS" - "$DATA
echo "Status: "$STATUS" - "$DATA >> result.log

if [ "$STATUS" != "OK" ]; then
	echo $RESULT > `dirname "$DATA"`"/ERROR.json"
fi

#Shut down and delete instance
dhis2-shutdown $DBNAME > /dev/null
sleep 5
echo y | dhis2-delete-instance $DBNAME > /dev/null
sleep 5
