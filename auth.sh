#!/bin/bash
date
ACCOUNT=$1
ROLE=$2
REGIONS=$3
EXEC_DIR=$4
EXEC_TARGET=$5

echo "Executing assume role"
# Request a 12h session; fall back to 1h if the caller is itself an assumed
# role (AWS caps role-chained sessions at 1 hour).
TEMP_CREDS="`aws sts assume-role --role-arn arn:aws:iam::$ACCOUNT:role/$ROLE --role-session-name deploymentSession --duration-seconds 43200 2>/dev/null`"
if [ -z "$TEMP_CREDS" ]; then
  TEMP_CREDS="`aws sts assume-role --role-arn arn:aws:iam::$ACCOUNT:role/$ROLE --role-session-name deploymentSession`"
fi
#pwd
echo "$#"
export TEMP=$TEMP_CREDS
export AWS_ACCESS_KEY_ID=$(echo "${TEMP}" | jq -r '.Credentials.AccessKeyId')
export AWS_SECRET_ACCESS_KEY=$(echo "${TEMP}" | jq -r '.Credentials.SecretAccessKey')
export AWS_SESSION_TOKEN=$(echo "${TEMP}" | jq -r '.Credentials.SessionToken')
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