// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

echo "Building reconciliation app container"
export DOCKER_BUILDKIT=0
echo "ACCOUNT_ID - $ACCOUNT_ID"
echo "REGION - $REGION"

cp -r ../../reconciliation_app reconciliation_app
cp -r ../certs certs

aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

docker build -t trade-matching-reconciliation-ecr . --build-arg ARG_REGION=$REGION
docker tag trade-matching-reconciliation-ecr:latest $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/trade-matching-reconciliation-ecr:latest
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/trade-matching-reconciliation-ecr:latest

echo "Cleanup"
rm -rf reconciliation_app
rm -rf certs
echo "Finished."
