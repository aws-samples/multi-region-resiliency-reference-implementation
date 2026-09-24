# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

FROM public.ecr.aws/docker/library/python:3.9-slim AS builder
ARG ARG_CREDS
ARG ARG_REGION
ENV RECONCILIATION=""
ENV CREDS=$ARG_CREDS
ENV REGION=$ARG_REGION
RUN apt-get update && apt-get install -y --no-install-recommends \
        curl unzip jq ca-certificates \
    && rm -rf /var/lib/apt/lists/*
RUN curl -sSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip \
    && unzip -q /tmp/awscliv2.zip -d /tmp \
    && /tmp/aws/install \
    && rm -rf /tmp/aws /tmp/awscliv2.zip
FROM builder
WORKDIR /
COPY reconciliation_app reconciliation_app
COPY certs certs
COPY start.sh start.sh
RUN pip install --no-cache-dir -r /reconciliation_app/src/requirements.txt
RUN chmod +x start.sh
CMD ["sh", "/start.sh"]
