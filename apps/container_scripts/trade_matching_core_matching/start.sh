#!/bin/bash
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

date
echo "Hello World! Start Trade matching CORE matching"
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
INBOUND_STREAM_NAME=`aws ssm get-parameter --name "/approtation/trade-matching/core-trade/kinesis" --output text --query Parameter.Value --region $REGION --with-decryption`
echo "$INBOUND_STREAM_NAME"

INBOUND_SETTLEMENT_STREAM_NAME=`aws ssm get-parameter --name "/approtation/trade-matching/core-settlement/kinesis" --output text --query Parameter.Value --region $REGION --with-decryption`
echo "$INBOUND_SETTLEMENT_STREAM_NAME"

OUTBOUND_SETTLED_TRADE_STREAM_NAME=`aws ssm get-parameter --name "/approtation/trade-matching/egress-trade/kinesis" --output text --query Parameter.Value --region $REGION --with-decryption`
echo "$OUTBOUND_SETTLED_TRADE_STREAM_NAME"

EGRESS_KDS_NAME=`aws ssm get-parameter --name "/approtation/trade-matching/egress-trade/kinesis" --output text --query Parameter.Value --region $REGION --with-decryption`
echo "$EGRESS_KDS_NAME"

EGRESS_SETTLEMENT_KDS_NAME=`aws ssm get-parameter --name "/approtation/trade-matching/egress-settlement/kinesis" --output text --query Parameter.Value --region $REGION --with-decryption`
echo "$EGRESS_SETTLEMENT_KDS_NAME"

DB_USERNAME=`aws secretsmanager get-secret-value --secret-id trade-matching-core-database --region $REGION| jq --raw-output '.SecretString' | jq -r .username`
echo "$DB_USERNAME"

DB_PASSWORD=`aws secretsmanager get-secret-value --secret-id trade-matching-core-database --region $REGION| jq --raw-output '.SecretString' | jq -r .password`
echo "$DB_PASSWORD"

DB_HOST=`aws secretsmanager get-secret-value --secret-id trade-matching-core-database --region $REGION| jq --raw-output '.SecretString' | jq -r .host`
echo "$DB_HOST"

DB_NAME=`aws secretsmanager get-secret-value --secret-id trade-matching-core-database --region $REGION| jq --raw-output '.SecretString' | jq -r .dbname`
echo "$DB_NAME"

export EGRESS_KDS_NAME=$EGRESS_KDS_NAME
export DB_USERNAME=$DB_USERNAME
export DB_PASSWORD=$DB_PASSWORD
export DB_URL="jdbc:postgresql://$DB_HOST/$DB_NAME"

echo "DB URL: $DB_URL"

ARC_CLUSTER=`aws secretsmanager get-secret-value --secret-id approtation-cluster --region $REGION | jq --raw-output '.SecretString'`

# aws ssm put-parameter --name "authtoken" --type "String" --value
#  ssm_value=$(aws ssm get-parameter --name "/TEST_PREFIX/${SECRET}" --with-decryption --query 'Parameter.Value' --output text)
# ssm_value=$(aws ssm get-parameter --name "${trade-matching-in-gateway-us-east-1-mq}" --with-decryption --query 'Parameter.Value' --output text)

#aws secretsmanager get-secret-value --secret-id tutorial/MyFirstSecret
cd /trade_matching_core_matching
echo "Starting gradle build"
gradle clean
gradle build -x test
echo "Executing App"
java -jar build/libs/tradematching-0.0.1-SNAPSHOT.jar --aws.region=$REGION --aws.rout53arcClusterArn=$ARC_CLUSTER \
--aws.tradeInboundStreamName=$INBOUND_STREAM_NAME --aws.settlementInboundStreamName=$INBOUND_SETTLEMENT_STREAM_NAME \
--aws.tradeOutboundStreamName=$OUTBOUND_SETTLED_TRADE_STREAM_NAME
echo 'CORE Ingestion end.'
date
date
