// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

FROM amazoncorretto:11 AS builder
RUN yum update -y && yum install -y initscripts;
ARG ARG_STATE_TABLE_NAME
ARG ARG_STREAM_NAME
ARG ARG_REGION
ARG ARG_QUEUE_NAME
ARG ARG_QUEUE_EP
ARG ARG_QUEUE_USERNAME
ARG ARG_QUEUE_PASSWORD
ARG ARG_CREDS
ENV STATE_TABLE_NAME=$ARG_STATE_TABLE_NAME
ENV STREAM_NAME=$ARG_STREAM_NAME
ENV REGION=$ARG_REGION
ENV QUEUE_EP=$ARG_QUEUE_EP
ENV QUEUE_NAME=$ARG_QUEUE_NAME
ENV QUEUE_USERNAME=$ARG_QUEUE_USERNAME
ENV QUEUE_PASSWORD=$ARG_QUEUE_PASSWORD
ENV CREDS=$ARG_CREDS
RUN yum update -y && yum install -y awscli
RUN yum install wget -y && yum install unzip -y && yum install tar -y && yum install jq -y
RUN wget https://services.gradle.org/distributions/gradle-7.3.3-bin.zip -P /tmp
RUN unzip -d /opt/gradle /tmp/gradle-7.3.3-bin.zip
FROM builder
COPY inbound_gateway inbound_gateway
COPY certs certs
#RUN gradle build -x test
WORKDIR /
COPY start.sh start.sh
RUN chmod +x start.sh
CMD ["sh", "/start.sh"]
