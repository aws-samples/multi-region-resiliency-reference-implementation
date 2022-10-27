#!/bin/bash
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

date
echo "Hello World! Start Trade matching outbound gateway"
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

# Set certificates
keytool -import -alias out-queue-tm-us-east1 -keystore $JAVA_HOME/lib/security/cacerts -file /certs/trade-matching.out.us-east1.der -storepass changeit -noprompt
keytool -import -alias out-queue-tm-us-west2 -keystore $JAVA_HOME/lib/security/cacerts -file /certs/trade-matching.out.us-west2.der -storepass changeit -noprompt
keytool -import -alias out-queue-tm-chain-us-east1 -keystore $JAVA_HOME/lib/security/cacerts -file /certs/trade-matching-chain.out.us-east1.der -storepass changeit -noprompt
keytool -import -alias out-queue-tm-chain-us-west2 -keystore $JAVA_HOME/lib/security/cacerts -file /certs/trade-matching-chain.out.us-west2.der -storepass changeit -noprompt

keytool -import -alias in-queue-st-us-east1 -keystore $JAVA_HOME/lib/security/cacerts -file /certs/settlement.in.us-east1.der -storepass changeit -noprompt
keytool -import -alias in-queue-st-us-west2 -keystore $JAVA_HOME/lib/security/cacerts -file /certs/settlement.in.us-west2.der -storepass changeit -noprompt
keytool -import -alias in-queue-st-chain-us-east1 -keystore $JAVA_HOME/lib/security/cacerts -file /certs/settlement-chain.in.us-east1.der -storepass changeit -noprompt
keytool -import -alias in-queue-st-chain-us-west2 -keystore $JAVA_HOME/lib/security/cacerts -file /certs/settlement-chain.in.us-west2.der -storepass changeit -noprompt


# Get parameter store

STATE_TABLE_NAME=`aws secretsmanager get-secret-value --secret-id trade-matching-out-gateway-trade-dynamodb --region $REGION| jq --raw-output '.SecretString'`
echo "$STATE_TABLE_NAME"

STATE_SETTLEMENT_TABLE_NAME=`aws secretsmanager get-secret-value --secret-id trade-matching-out-gateway-settlement-dynamodb --region $REGION| jq --raw-output '.SecretString'`
echo "$STATE_SETTLEMENT_TABLE_NAME"

INBOUND_STREAM_NAME=`aws ssm get-parameter --name "/approtation/trade-matching/out-gateway-trade/kinesis" --output text --query Parameter.Value --region $REGION --with-decryption`
echo "$INBOUND_STREAM_NAME"

INBOUND_SETTLEMENT_STREAM_NAME=`aws ssm get-parameter --name "/approtation/trade-matching/out-gateway-settlement/kinesis" --output text --query Parameter.Value --region $REGION --with-decryption`
echo "$INBOUND_SETTLEMENT_STREAM_NAME"


SETTLEMENT_SECRET=`aws secretsmanager get-secret-value --secret-id settlement-in-gateway-mq-connection --region $REGION| jq --raw-output '.SecretString'`
SETTLEMENT_ENDPOINT=`jq -r '.endpoint' <<< $SETTLEMENT_SECRET`
SETTLEMENT_USERNAME=`jq -r '.username' <<< $SETTLEMENT_SECRET`
SETTLEMENT_PASSWORD=`jq -r '.password' <<< $SETTLEMENT_SECRET`
SETTLEMENT_QUEUE="settlements"
echo "$SETTLEMENT_ENDPOINT"

TRADE_SECRET=`aws secretsmanager get-secret-value --secret-id trade-matching-out-gateway-mq-connection --region $REGION| jq --raw-output '.SecretString'`
TRADES_ENDPOINT=`jq -r '.endpoint' <<< $TRADE_SECRET`
TRADES_USERNAME=`jq -r '.username' <<< $TRADE_SECRET`
TRADES_PASSWORD=`jq -r '.password' <<< $TRADE_SECRET`
TRADES_QUEUE="trades"
echo "$TRADES_ENDPOINT"
# aws ssm put-parameter --name "authtoken" --type "String" --value
#  ssm_value=$(aws ssm get-parameter --name "/TEST_PREFIX/${SECRET}" --with-decryption --query 'Parameter.Value' --output text)
# ssm_value=$(aws ssm get-parameter --name "${trade-matching-in-gateway-us-east-1-mq}" --with-decryption --query 'Parameter.Value' --output text)

#aws secretsmanager get-secret-value --secret-id tutorial/MyFirstSecret
cd /trade_matching_outbound_gateway
echo "Starting gradle build"
gradle build -x test
echo "Executing App"
java -jar build/libs/TradeMatchingOutbound-0.0.1-SNAPSHOT.jar --aws.stateTableName=$STATE_TABLE_NAME \
--aws.stateSettlementTableName=$STATE_SETTLEMENT_TABLE_NAME --aws.inboundStreamName=$INBOUND_STREAM_NAME \
--aws.inboundSettlementStreamName=$INBOUND_SETTLEMENT_STREAM_NAME --aws.region=$REGION --settlements.endpoint=$SETTLEMENT_ENDPOINT \
--settlements.username=$SETTLEMENT_USERNAME --settlements.password=$SETTLEMENT_PASSWORD --settlements.queue=$SETTLEMENT_QUEUE \
--trades.username=$TRADES_USERNAME --trades.password=$TRADES_PASSWORD --trades.queue=$TRADES_QUEUE \
--trades.endpoint=$TRADES_ENDPOINT
echo 'Outbound gateway end.'
date
date
