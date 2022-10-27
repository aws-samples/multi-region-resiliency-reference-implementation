// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
echo "Building settlement outbound gateway container"
export DOCKER_BUILDKIT=0
echo "ACCOUNT_ID - $ACCOUNT_ID"
echo "REGION - $REGION"

cp -r ../../settlement_outbound_gateway settlement_outbound_gateway
cp -r ../certs certs
#docker buildx create --name mybuilder
#buildx use mybuilder
#docker buildx inspect --bootstrap
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

#docker build -t settlement-outbound . --build-arg ARG_REGION=$REGION
#docker run -e CREDS="$TEMP_CREDS" -d settlement-outbound

docker build -t settlement-out-gateway-ecr . --build-arg ARG_REGION=$REGION
docker tag settlement-out-gateway-ecr:latest $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/settlement-out-gateway-ecr:latest
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/settlement-out-gateway-ecr:latest

echo "Cleanup"
rm -rf settlement_outbound_gateway
rm -rf certs
echo "Finished."
