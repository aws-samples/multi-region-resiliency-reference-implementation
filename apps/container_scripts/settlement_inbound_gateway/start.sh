#!/bin/bash
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

date
echo "Hello World! Start Inbound Gateway"
echo "Arguments:"
echo "STATE_TABLE_NAME: $STATE_TABLE_NAME";
echo "STREAM_NAME: $STREAM_NAME";
echo "REGION: $REGION";
echo "QUEUE_EP: $QUEUE_EP";
echo "QUEUE_NAME : $QUEUE_NAME";
echo "QUEUE_USERNAME $QUEUE_USERNAME";
echo "QUEUE_PASSWORD: $QUEUE_PASSWORD";
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


keytool -import -alias in-queue-st-us-east1 -keystore $JAVA_HOME/lib/security/cacerts -file /certs/settlement.in.us-east1.der -storepass changeit -noprompt
keytool -import -alias in-queue-st-us-west2 -keystore $JAVA_HOME/lib/security/cacerts -file /certs/settlement.in.us-west2.der -storepass changeit -noprompt
keytool -import -alias in-queue-st-chain-us-east1 -keystore $JAVA_HOME/lib/security/cacerts -file /certs/settlement-chain.in.us-east1.der -storepass changeit -noprompt
keytool -import -alias in-queue-st-chain-us-west2 -keystore $JAVA_HOME/lib/security/cacerts -file /certs/settlement-chain.in.us-west2.der -storepass changeit -noprompt


# Get parameter store
SETTLEMENT_SECRET=`aws secretsmanager get-secret-value --secret-id settlement-in-gateway-mq-connection --region $REGION| jq --raw-output '.SecretString'`
echo "Getting endpoint"
QUEUE_EP=`jq -r '.endpoint' <<< $SETTLEMENT_SECRET`
echo "$QUEUE_EP"
echo "Getting username"
QUEUE_USERNAME=`jq -r '.username' <<< $SETTLEMENT_SECRET`
echo "$QUEUE_USERNAME"
echo "Getting password"
QUEUE_PASSWORD=`jq -r '.password' <<< $SETTLEMENT_SECRET`
echo "$QUEUE_PASSWORD"
QUEUE_NAME="settlements"
echo "$QUEUE_NAME"

STATE_TABLE_NAME=`aws secretsmanager get-secret-value --secret-id settlement-in-gateway-settlement-dynamodb --region $REGION| jq --raw-output '.SecretString'`
echo "$STATE_TABLE_NAME"

STREAM_NAME=`aws ssm get-parameter --name "/approtation/settlement/ingress-settlement/kinesis" --output text --query Parameter.Value --region $REGION --with-decryption`
echo "$STREAM_NAME"

ARC_CLUSTER=`aws secretsmanager get-secret-value --secret-id approtation-cluster --region $REGION| jq --raw-output '.SecretString'`
echo "$ARC_CLUSTER"
# aws ssm put-parameter --name "authtoken" --type "String" --value
#  ssm_value=$(aws ssm get-parameter --name "/TEST_PREFIX/${SECRET}" --with-decryption --query 'Parameter.Value' --output text)
# ssm_value=$(aws ssm get-parameter --name "${settlement-in-gateway-us-east-1-mq}" --with-decryption --query 'Parameter.Value' --output text)

#aws secretsmanager get-secret-value --secret-id tutorial/MyFirstSecret
cd /inbound_gateway
gradle build -x test
echo "Executing App"
java -jar build/libs/SettlementInbound-0.0.1-SNAPSHOT.jar --aws.stateTableName=$STATE_TABLE_NAME \
--aws.streamName=$STREAM_NAME --aws.region=$REGION --spring.activemq.broker-url=$QUEUE_EP \
--spring.activemq.user=$QUEUE_USERNAME --spring.activemq.password=$QUEUE_PASSWORD \
--spring.jms.queue.name=$QUEUE_NAME --aws.arcClusterArn=$ARC_CLUSTER
echo 'Inbound gateway end.'
date
date
