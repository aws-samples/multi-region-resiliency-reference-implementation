// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

FROM amazoncorretto:17 AS builder
RUN yum update -y && yum install -y initscripts;
ARG ARG_CREDS
ARG ARG_REGION
ENV EGRESS_KDS_NAME=""
ENV DB_USERNAME=""
ENV DB_PASSWORD=""
ENV REGION=$ARG_REGION
ENV CREDS=$ARG_CREDS
RUN yum update -y && yum install -y awscli
RUN yum install wget -y && yum install unzip -y && yum install tar -y && yum install jq -y
RUN wget https://services.gradle.org/distributions/gradle-7.3.3-bin.zip -P /tmp
RUN unzip -d /opt/gradle /tmp/gradle-7.3.3-bin.zip
FROM builder
COPY trade_matching_core_matching trade_matching_core_matching
WORKDIR /
COPY start.sh start.sh
RUN chmod +x start.sh
CMD ["sh", "/start.sh"]
