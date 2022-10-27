// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

FROM amazoncorretto:11 AS builder
RUN yum update -y && yum install -y initscripts;
ARG ARG_REGION
ARG ARG_NUM_OF_TRADES
ARG ARG_GENERATE_FILES
ARG ARG_GENERATE_QUEUE
ARG ARG_OUTPUT_DIR
ARG ARG_QUEUE_ENDPOINT
ARG ARG_QUEUE_NAME
ARG ARG_QUEUE_USERNAME
ARG ARG_QUEUE_PASSWORD
ENV NUM_OF_TRADES=$ARG_NUM_OF_TRADES
ENV GENERATE_FILES=$ARG_GENERATE_FILES
ENV GENERATE_QUEUE=$ARG_GENERATE_QUEUE
ENV OUTPUT_DIR=$ARG_OUTPUT_DIR
ENV QUEUE_ENDPOINT=$ARG_QUEUE_ENDPOINT
ENV QUEUE_NAME=$ARG_QUEUE_NAME
ENV QUEUE_USERNAME=$ARG_QUEUE_USERNAME
ENV QUEUE_PASSWORD=$ARG_QUEUE_PASSWORD
ENV CREDS=$ARG_CREDS
ENV REGION=$ARG_REGION
RUN yum update -y && yum install -y awscli
RUN yum install wget -y && yum install unzip -y && yum install tar -y && yum install jq -y
RUN wget https://services.gradle.org/distributions/gradle-7.3.3-bin.zip -P /tmp
RUN unzip -d /opt/gradle /tmp/gradle-7.3.3-bin.zip
FROM builder
COPY trades_generator trades_generator
COPY certs certs
WORKDIR /
COPY start.sh start.sh
RUN chmod +x start.sh
CMD ["sh", "/start.sh"]
