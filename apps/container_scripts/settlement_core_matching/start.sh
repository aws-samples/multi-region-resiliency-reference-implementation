#!/bin/bash
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

date
echo "Hello World! Start settlement core matching"
echo "Arguments:"
echo "EGRESS_KDS_NAME: $EGRESS_KDS_NAME";
echo "DB_USERNAME: $DB_USERNAME";
echo "DB_PASSWORD: $DB_PASSWORD";
echo "DB_URL: $DB_URL";
echo "REGION: $REGION";

#echo "CREDS: $CREDS";
date
# export JAVA_HOME=/opt/jdk-11
export GRADLE_HOME=/opt/gradle/gradle-7.3.3
export PATH=${JAVA_HOME}/bin:${GRADLE_HOME}/bin:${PATH}

if [[ $CREDS ]];
then
    echo "credentials exist";
    echo $CREDS > /temp.txt;
    source /temp.txt;
    rm /temp.txt;
#    aws sts get-caller-identity;
#    IFS=$'\n';
#    for item in $(printf %b "{$CREDS}");
#    do
#      echo $item;
#      eval "($item)";
#    done;
fi
aws sts get-caller-identity

# Get parameter store

INBOUND_STREAM_NAME=`aws ssm get-parameter --name "/approtation/settlement/core-settlement/kinesis" --output text --query Parameter.Value --region $REGION --with-decryption`
echo "$INBOUND_STREAM_NAME"

OUTBOUND_STREAM_NAME=`aws ssm get-parameter --name "/approtation/settlement/egress-settlement/kinesis" --output text --query Parameter.Value --region $REGION --with-decryption`
echo "$OUTBOUND_STREAM_NAME"

DB_SECRET=`aws secretsmanager get-secret-value --secret-id settlement-core-database --region $REGION| jq --raw-output '.SecretString'`

DB_USERNAME=`jq -r '.username' <<< $DB_SECRET`
echo "$DB_USERNAME"

DB_PASSWORD=`jq -r '.password' <<< $DB_SECRET`
echo "$DB_PASSWORD"

DB_HOST=`jq -r '.host' <<< $DB_SECRET`
echo "$DB_HOST"

DB_NAME=`jq -r '.dbname' <<< $DB_SECRET`
echo "$DB_NAME"

DB_URL="jdbc:postgresql://$DB_HOST/$DB_NAME"
echo "$DB_URL"

ARC_CLUSTER=`aws secretsmanager get-secret-value --secret-id approtation-cluster --region $REGION | jq --raw-output '.SecretString'`

cd /settlement_core_matching
echo "Starting gradle build"
gradle clean
gradle build -x test
echo "Executing App"
java -jar build/libs/SettlementCoreMatching-0.0.1-SNAPSHOT.jar --spring.datasource.url=$DB_URL \
--spring.datasource.username=$DB_USERNAME --spring.datasource.password=$DB_PASSWORD --aws.region=$REGION \
--aws.inboundStream=$INBOUND_STREAM_NAME --aws.outboundStream=$OUTBOUND_STREAM_NAME --aws.rout53arcClusterArn=$ARC_CLUSTER
echo 'settlement core matching end.'
date
date
