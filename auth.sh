#!/bin/bash
date
ACCOUNT=$1
ROLE=$2
REGIONS=$3
EXEC_DIR=$4
EXEC_TARGET=$5

echo "Executing assume role"
TEMP_CREDS="`aws sts assume-role --role-arn arn:aws:iam::$ACCOUNT:role/$ROLE --role-session-name deploymentSession`"
#pwd
echo "$#"
export TEMP=$TEMP_CREDS
export AWS_ACCESS_KEY_ID=$(echo "${TEMP}" | jq -r '.Credentials.AccessKeyId')
export AWS_SECRET_ACCESS_KEY=$(echo "${TEMP}" | jq -r '.Credentials.SecretAccessKey')
export AWS_SESSION_TOKEN=$(echo "${TEMP}" | jq -r '.Credentials.SessionToken')
echo "$AWS_ACCESS_KEY_ID"
echo "$AWS_SECRET_ACCESS_KEY"
echo "$AWS_SESSION_TOKEN"
export ACCOUNT_ID=$ACCOUNT
export AWS_REGIONS=$(echo ${REGIONS});
aws sts get-caller-identity

 if [ "$#" -eq  "5" ]
   then
     echo "Executing sub-process"
     cd $EXEC_DIR
     make $EXEC_TARGET
 else
     echo "No other arguments supplied"
 fi