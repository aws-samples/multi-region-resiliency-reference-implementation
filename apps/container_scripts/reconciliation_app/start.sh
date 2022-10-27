#!/bin/bash
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

date
echo "Hello World! Start Reconciliation App"
echo "Arguments:"
echo "RECONCILIATION: $RECONCILIATION";
echo "REGION: $REGION";

date

export PATH=/opt/Python-3.9.10:${PATH}

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

export CERT_SETTLEMENT_IN_PATH_US_EAST1="/certs/settlement.in.us-east1.pem"
export CERT_SETTLEMENT_IN_PATH_US_WEST2="/certs/settlement.in.us-west2.pem"
export CERT_SETTLEMENT_OUT_PATH_US_EAST1="/certs/settlement.out.us-east1.pem"
export CERT_SETTLEMENT_OUT_PATH_US_WEST2="/certs/settlement.out.us-west2.pem"

export CERT_TRADE_IN_PATH_US_EAST1="/certs/trade-matching.in.us-east1.pem"
export CERT_TRADE_IN_PATH_US_WEST2="/certs/trade-matching.in.us-west2.pem"
export CERT_TRADE_OUT_PATH_US_EAST1="/certs/trade-matching.out.us-east1.pem"
export CERT_TRADE_OUT_PATH_US_WEST2="/certs/trade-matching.out.us-west2.pem"

export CERT_SETTLEMENT_IN_PK_PATH_US_EAST1="/certs/settlement.in.pk.us-east1.key"
export CERT_SETTLEMENT_IN_PK_PATH_US_WEST2="/certs/settlement.in.pk.us-west2.key"
export CERT_SETTLEMENT_OUT_PK_PATH_US_EAST1="/certs/settlement.out.pk.us-east1.key"
export CERT_SETTLEMENT_OUT_PK_PATH_US_WEST2="/certs/settlement.out.pk.us-west2.key"

export CERT_TRADE_IN_PK_PATH_US_EAST1="/certs/trade-matching.in.pk.us-east1.key"
export CERT_TRADE_IN_PK_PATH_US_WEST2="/certs/trade-matching.in.pk.us-west2.key"
export CERT_TRADE_OUT_PK_PATH_US_EAST1="/certs/trade-matching.out.pk.us-east1.key"
export CERT_TRADE_OUT_PK_PATH_US_WEST2="/certs/trade-matching.out.pk.us-west2.key"


cd /reconciliation_app
echo "Starting App"
python3.9 -V
python3.9 -m pip install -r src/requirements.txt
python3.9 src/main.py --reconciliation=$RECONCILIATION --region=$REGION
echo 'RECONCILIATION App end.'
date
date
