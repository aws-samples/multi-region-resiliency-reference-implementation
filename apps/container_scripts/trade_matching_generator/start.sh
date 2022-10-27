#!/bin/bash
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

date
echo "Hello World! Start Generating Data"
echo "Arguments:"
echo "NUM_OF_TRADES: $NUM_OF_TRADES";
echo "GENERATE_FILES: $GENERATE_FILES";
echo "GENERATE_QUEUE: $GENERATE_QUEUE";
echo "OUTPUT_DIR: $OUTPUT_DIR";
echo "QUEUE_ENDPOINT: $QUEUE_ENDPOINT";
echo "QUEUE_NAME : $QUEUE_NAME";
echo "QUEUE_USERNAME $QUEUE_USERNAME";
echo "QUEUE_PASSWORD: $QUEUE_PASSWORD";
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

#ls $JAVA_HOME/lib/security
keytool -import -alias in-queue-tm-us-east1 -keystore $JAVA_HOME/lib/security/cacerts -file /certs/trade-matching.in.us-east1.der -storepass changeit -noprompt
keytool -import -alias in-queue-tm-us-west2 -keystore $JAVA_HOME/lib/security/cacerts -file /certs/trade-matching.in.us-west2.der -storepass changeit -noprompt
keytool -import -alias in-queue-tm-chain-us-east1 -keystore $JAVA_HOME/lib/security/cacerts -file /certs/trade-matching-chain.in.us-east1.der -storepass changeit -noprompt
keytool -import -alias in-queue-tm-chain-us-west2 -keystore $JAVA_HOME/lib/security/cacerts -file /certs/trade-matching-chain.in.us-west2.der -storepass changeit -noprompt

keytool -import -alias out-queue-st-us-east1 -keystore $JAVA_HOME/lib/security/cacerts -file /certs/settlement.out.us-east1.der -storepass changeit -noprompt
keytool -import -alias out-queue-st-us-west2 -keystore $JAVA_HOME/lib/security/cacerts -file /certs/settlement.out.us-west2.der -storepass changeit -noprompt
keytool -import -alias out-queue-st-chain-us-east1 -keystore $JAVA_HOME/lib/security/cacerts -file /certs/settlement-chain.out.us-east1.der -storepass changeit -noprompt
keytool -import -alias out-queue-st-chain-us-west2 -keystore $JAVA_HOME/lib/security/cacerts -file /certs/settlement-chain.out.us-west2.der -storepass changeit -noprompt


# Get parameter store
echo "Getting endpoint"
QUEUE_ENDPOINT=`aws secretsmanager get-secret-value --secret-id trade-matching-in-gateway-mq-connection --region $REGION| jq --raw-output '.SecretString' | jq -r .endpoint`
echo "$QUEUE_ENDPOINT"
echo "Getting username"
QUEUE_USERNAME=`aws secretsmanager get-secret-value --secret-id trade-matching-in-gateway-mq-connection --region $REGION| jq --raw-output '.SecretString' | jq -r .username`
echo "$QUEUE_USERNAME"
echo "Getting password"
QUEUE_PASSWORD=`aws secretsmanager get-secret-value --secret-id trade-matching-in-gateway-mq-connection --region $REGION| jq --raw-output '.SecretString' | jq -r .password`
echo "$QUEUE_PASSWORD"
QUEUE_NAME="trades"
BATCH_COUNT=`aws ssm get-parameter --name "/approtation/trade-generator/number-of-trades" --output text --query Parameter.Value --region $REGION --with-decryption`
echo "$BATCH_COUNT"

ARC_CLUSTER=`aws secretsmanager get-secret-value --secret-id approtation-cluster --region $REGION | jq --raw-output '.SecretString'`

# aws ssm put-parameter --name "authtoken" --type "String" --value
#  ssm_value=$(aws ssm get-parameter --name "/TEST_PREFIX/${SECRET}" --with-decryption --query 'Parameter.Value' --output text)
# ssm_value=$(aws ssm get-parameter --name "${trade-matching-in-gateway-us-east-1-mq}" --with-decryption --query 'Parameter.Value' --output text)

#aws secretsmanager get-secret-value --secret-id tutorial/MyFirstSecret
cd /trades_generator
echo "Starting gradle build"
gradle build
echo "Executing App"
java -jar build/libs/trades-0.0.1-SNAPSHOT.jar --aws.region=$REGION --aws.queueEndPoint=$QUEUE_ENDPOINT \
--aws.queueUsername=$QUEUE_USERNAME --aws.queuePassword=$QUEUE_PASSWORD --aws.destinationQueue=$QUEUE_NAME \
--trades-generator.batchCount=$BATCH_COUNT --aws.rout53arcClusterArn=$ARC_CLUSTER
#java -jar build/libs/trades-0.0.1-SNAPSHOT.jar -c $NUM_OF_TRADES --queue $GENERATE_QUEUE --files $GENERATE_FILES -o $OUTPUT_DIR -mq-ep $QUEUE_ENDPOINT -mq-user $QUEUE_USERNAME -mq-password $QUEUE_PASSWORD -mq-name $QUEUE_NAME -Djavax.net.debug=ssl
#java -jar build/libs/trades-0.0.1-SNAPSHOT.jar -c $NUM_OF_TRADES -q $GENERATE_QUEUE -f $GENERATE_FILES -mq-ep $QUEUE_ENDPOINT -mq-user $QUEUE_USERNAME -mq-password $QUEUE_PASSWORD -mq-name $QUEUE_NAME
echo 'Generating data job end.'
date
date
