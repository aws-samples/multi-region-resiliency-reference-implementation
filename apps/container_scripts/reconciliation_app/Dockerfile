// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

FROM amazonlinux:2 AS builder
RUN yum update -y && yum install -y initscripts;
ARG ARG_CREDS
ARG ARG_REGION
ENV RECONCILIATION=""
ENV REGION=""
ENV CREDS=$ARG_CREDS
ENV REGION=$ARG_REGION
RUN yum update -y && yum install -y awscli
RUN yum install wget -y && yum install unzip -y && yum install tar -y && yum install jq -y
RUN yum groupinstall "Development Tools" -y && yum install openssl-devel libffi-devel bzip2-devel -y
WORKDIR /opt
RUN wget https://www.python.org/ftp/python/3.9.10/Python-3.9.10.tgz -P /opt
RUN tar xvf /opt/Python-3.9.10.tgz
RUN sh  /opt/Python-3.9.10/configure --enable-optimizations
RUN make altinstall
FROM builder
WORKDIR /
COPY reconciliation_app reconciliation_app
COPY certs certs
COPY start.sh start.sh
RUN chmod +x start.sh
CMD ["sh", "/start.sh"]
