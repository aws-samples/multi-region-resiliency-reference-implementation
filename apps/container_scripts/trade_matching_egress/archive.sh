// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
echo "Building trade matching egress container"
export DOCKER_BUILDKIT=0
echo "ACCOUNT_ID - $ACCOUNT_ID"
echo "REGION - $REGION"

cp -r ../../trade_matching_egress trade_matching_egress
#docker buildx create --name mybuilder
#buildx use mybuilder
#docker buildx inspect --bootstrap
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

#docker build -t egress .
#docker run -e CREDS="$TEMP_CREDS" -d egress

docker build -t trade-matching-egress-ecr . --build-arg ARG_REGION=$REGION
docker tag trade-matching-egress-ecr:latest $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/trade-matching-egress-ecr:latest
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/trade-matching-egress-ecr:latest

echo "Cleanup"
rm -rf trade_matching_egress
echo "Finished."
