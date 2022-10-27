// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
echo "Building trade generator container"
export DOCKER_BUILDKIT=0
echo "ACCOUNT_ID - $ACCOUNT_ID"
echo "REGION - $REGION"
echo "TEMP CREDS - $TEMP_CREDS"
TRADE_COUNT=100
cp -r ../../trade_matching_generator trades_generator
cp -r ../certs certs
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

#docker build -t trade-generator .
#docker run -e CREDS="$TEMP_CREDS" -e GENERATE_FILES="true" -e GENERATE_QUEUE="false" -e REGION=$REGION -e OUTPUT_DIR="output" -d trade-generator

docker build -t trade-generator-ecr . --build-arg ARG_REGION=$REGION --build-arg ARG_GENERATE_FILES="false" --build-arg ARG_GENERATE_QUEUE="true" --build-arg ARG_OUTPUT_DIR="output"
docker tag trade-generator-ecr:latest $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/trade-generator-ecr:latest
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/trade-generator-ecr:latest

echo "Cleanup"
rm -rf trades_generator
rm -rf certs
echo "Finished."
