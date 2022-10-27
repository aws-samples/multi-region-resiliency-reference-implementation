#!/bin/bash
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

date
echo "Hello World! Start Inbound Gateway"
echo "Arguments:"
echo "REGION: $REGION";
#echo "CREDS: $CREDS";

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

keytool -import -alias in-queue-tm-us-east1 -keystore $JAVA_HOME/lib/security/cacerts -file /certs/trade-matching.in.us-east1.der -storepass changeit -noprompt
keytool -import -alias in-queue-tm-us-west2 -keystore $JAVA_HOME/lib/security/cacerts -file /certs/trade-matching.in.us-west2.der -storepass changeit -noprompt
keytool -import -alias in-queue-tm-chain-us-east1 -keystore $JAVA_HOME/lib/security/cacerts -file /certs/trade-matching-chain.in.us-east1.der -storepass changeit -noprompt
keytool -import -alias in-queue-tm-chain-us-west2 -keystore $JAVA_HOME/lib/security/cacerts -file /certs/trade-matching-chain.in.us-west2.der -storepass changeit -noprompt

# Get secrets
echo "Getting endpoint"
QUEUE_EP=`aws secretsmanager get-secret-value --secret-id trade-matching-in-gateway-mq-connection --region $REGION| jq --raw-output '.SecretString' | jq -r .endpoint`
echo "$QUEUE_EP"
echo "Getting username"
QUEUE_USERNAME=`aws secretsmanager get-secret-value --secret-id trade-matching-in-gateway-mq-connection --region $REGION| jq --raw-output '.SecretString' | jq -r .username`
echo "$QUEUE_USERNAME"
echo "Getting password"
QUEUE_PASSWORD=`aws secretsmanager get-secret-value --secret-id trade-matching-in-gateway-mq-connection --region $REGION| jq --raw-output '.SecretString' | jq -r .password`
echo "$QUEUE_PASSWORD"
QUEUE_NAME="trades"
echo "$QUEUE_NAME"

STATE_TABLE_NAME=`aws secretsmanager get-secret-value --secret-id trade-matching-in-gateway-trade-dynamodb --region $REGION| jq --raw-output '.SecretString'`
echo "$STATE_TABLE_NAME"

STATE_SETTLEMENT_TABLE_NAME=`aws secretsmanager get-secret-value --secret-id trade-matching-in-gateway-settlement-dynamodb --region $REGION| jq --raw-output '.SecretString'`
echo "$STATE_SETTLEMENT_TABLE_NAME"

STREAM_NAME=`aws ssm get-parameter --name "/approtation/trade-matching/ingress-trade/kinesis" --output text --query Parameter.Value --region $REGION --with-decryption`
echo "$STREAM_NAME"

SETTLEMENT_STREAM_NAME=`aws ssm get-parameter --name "/approtation/trade-matching/ingress-settlement/kinesis" --output text --query Parameter.Value --region $REGION --with-decryption`
echo "$SETTLEMENT_STREAM_NAME"

ARC_CLUSTER=`aws secretsmanager get-secret-value --secret-id approtation-cluster --region $REGION| jq --raw-output '.SecretString'`
echo "$ARC_CLUSTER"
# aws ssm put-parameter --name "authtoken" --type "String" --value
#  ssm_value=$(aws ssm get-parameter --name "/TEST_PREFIX/${SECRET}" --with-decryption --query 'Parameter.Value' --output text)
# ssm_value=$(aws ssm get-parameter --name "${trade-matching-in-gateway-us-east-1-mq}" --with-decryption --query 'Parameter.Value' --output text)

#aws secretsmanager get-secret-value --secret-id tutorial/MyFirstSecret
cd /inbound_gateway
echo "Starting gradle build"
gradle build -x test
echo "Executing App"
java -jar build/libs/app.inbound.gateway-0.0.1-SNAPSHOT.jar --aws.stateTableName=$STATE_TABLE_NAME \
--aws.stateSettlementTableName=$STATE_SETTLEMENT_TABLE_NAME \
--aws.streamName=$STREAM_NAME --aws.settlementStreamName=$SETTLEMENT_STREAM_NAME --aws.region=$REGION --spring.activemq.broker-url=$QUEUE_EP \
--spring.activemq.user=$QUEUE_USERNAME --spring.activemq.password=$QUEUE_PASSWORD \
--spring.jms.queue.name=$QUEUE_NAME --aws.arcClusterArn=$ARC_CLUSTER
echo 'Inbound gateway end.'
date
date
