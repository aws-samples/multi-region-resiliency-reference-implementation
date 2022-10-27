// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
echo "Building trade matching CORE matching container"
export DOCKER_BUILDKIT=0
echo "ACCOUNT_ID - $ACCOUNT_ID"
echo "REGION - $REGION"

cp -r ../../trade_matching_core_matching trade_matching_core_matching
#docker buildx create --name mybuilder
#buildx use mybuilder
#docker buildx inspect --bootstrap
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com
#docker build -t core-matching .
#docker run -e CREDS="$TEMP_CREDS" -e REGION="$REGION" -d core-matching

docker build -t trade-matching-core-matching-ecr . --build-arg ARG_REGION=$REGION
docker tag trade-matching-core-matching-ecr:latest $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/trade-matching-core-matching-ecr:latest
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/trade-matching-core-matching-ecr:latest

#docker tag trade-matching-trade-generator:1.0 public.ecr.aws/h2v4m9r5/trade-matching-trade-generator:latest
#docker push public.ecr.aws/h2v4m9r5/trade-matching-trade-generator:1.0

#aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com
# docker tag trades-generator:latest $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/data-generator:latest
#docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/data-generator:latest
echo "Cleanup"
rm -rf trade_matching_core_matching
echo "Finished."
