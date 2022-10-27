// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

FROM amazoncorretto:11 AS builder
RUN yum update -y && yum install -y initscripts;
ARG ARG_STATE_TABLE_NAME
ARG ARG_INBOUND_STREAM_NAME
ARG ARG_OUTBOUND_STREAM_NAME
ARG ARG_NACK_STREAM_NAME
ARG ARG_REGION
ARG ARG_CREDS
ENV STATE_TABLE_NAME=$ARG_STATE_TABLE_NAME
ENV INBOUND_STREAM_NAME=$ARG_INBOUND_STREAM_NAME
ENV OUTBOUND_STREAM_NAME=$ARG_OUTBOUND_STREAM_NAME
ENV NACK_STREAM_NAME=$ARG_NACK_STREAM_NAME
ENV REGION=$ARG_QUEUE_NAME
ENV REGION=$ARG_REGION
ENV CREDS=$ARG_CREDS
RUN yum update -y && yum install -y awscli
RUN yum install wget -y && yum install unzip -y && yum install tar -y && yum install jq -y
RUN wget https://services.gradle.org/distributions/gradle-7.3.3-bin.zip -P /tmp
RUN unzip -d /opt/gradle /tmp/gradle-7.3.3-bin.zip
FROM builder
COPY trade_matching_ingestion trade_matching_ingestion
WORKDIR /
COPY start.sh start.sh
RUN chmod +x start.sh
CMD ["sh", "/start.sh"]
