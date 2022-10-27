// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
echo "Building inbound_gateway container"
export DOCKER_BUILDKIT=0
echo "ACCOUNT_ID - $ACCOUNT_ID"
echo "REGION - $REGION"

cp -r ../../trade_matching_inbound_gateway inbound_gateway
cp -r ../certs certs

aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

docker build -t trade-matching-in-gateway-ecr . --build-arg ARG_REGION=$REGION
docker tag trade-matching-in-gateway-ecr:latest $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/trade-matching-in-gateway-ecr:latest
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/trade-matching-in-gateway-ecr:latest

echo "Cleanup"
rm -rf inbound_gateway
rm -rf certs
echo "Finished."
