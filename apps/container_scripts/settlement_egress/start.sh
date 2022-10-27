#!/bin/bash
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

date
echo "Hello World! Start Settlement egress"
echo "Arguments:"
echo "STATE_TABLE_NAME: $STATE_TABLE_NAME";
echo "STREAM_NAME: $INBOUND_STREAM_NAME";
echo "STREAM_NAME: $OUTBOUND_STREAM_NAME";
echo "NACK_STREAM_NAME: $NACK_STREAM_NAME";
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
STATE_TABLE_NAME=`aws secretsmanager get-secret-value --secret-id settlement-egress-settlement-dynamodb --region $REGION| jq --raw-output '.SecretString'`
echo "$STATE_TABLE_NAME"

INBOUND_STREAM_NAME=`aws ssm get-parameter --name "/approtation/settlement/egress-settlement/kinesis" --output text --query Parameter.Value --region $REGION --with-decryption`
echo "$INBOUND_STREAM_NAME"

OUTBOUND_STREAM_NAME=`aws ssm get-parameter --name "/approtation/settlement/out-gateway-settlement/kinesis" --output text --query Parameter.Value --region $REGION --with-decryption`
echo "$OUTBOUND_STREAM_NAME"

# aws ssm put-parameter --name "authtoken" --type "String" --value
#  ssm_value=$(aws ssm get-parameter --name "/TEST_PREFIX/${SECRET}" --with-decryption --query 'Parameter.Value' --output text)
# ssm_value=$(aws ssm get-parameter --name "${trade-matching-in-gateway-us-east-1-mq}" --with-decryption --query 'Parameter.Value' --output text)

#aws secretsmanager get-secret-value --secret-id tutorial/MyFirstSecret
cd /settlement_egress
echo "Starting gradle build"
gradle build -x test
echo "Executing App"
java -jar build/libs/SettlementEgress-0.0.1-SNAPSHOT.jar --aws.safeStoreTable=$STATE_TABLE_NAME \
--aws.inboundStreamName=$INBOUND_STREAM_NAME --aws.region=$REGION --aws.outboundStreamName=$OUTBOUND_STREAM_NAME
echo 'Egress end.'
date
date
