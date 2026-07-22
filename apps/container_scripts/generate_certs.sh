#!/bin/bash
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0
#
# Generates the apps/container_scripts/certs directory consumed by the
# container images (Java truststore imports and the reconciliation app).
#
# For every app (trade-matching, settlement), direction (in, out) and region
# (us-east-1, us-west-2) it exports the ACM private certificate that fronts
# the MQ NLB (domain mq.approtation.<app>.<direction>) and writes:
#   <app>.<dir>.<regionshort>.pem        leaf certificate (PEM)
#   <app>.<dir>.<regionshort>.der        leaf certificate (DER)
#   <app>-chain.<dir>.<regionshort>.der  issuing CA certificate (DER)
#   <app>.<dir>.pk.<regionshort>.key     private key (PEM, decrypted)
#
# Requires: aws cli v2, jq, openssl. Uses ambient AWS credentials.
set -euo pipefail

cd "$(dirname "$0")"
mkdir -p certs
PASSPHRASE=$(openssl rand -base64 24)
PASSPHRASE_B64=$(printf '%s' "$PASSPHRASE" | base64)

for REGION in us-east-1 us-west-2; do
  REGION_SHORT=$(echo "$REGION" | sed 's/us-east-1/us-east1/; s/us-west-2/us-west2/')
  for APP in trade-matching settlement; do
    for DIR in in out; do
      DOMAIN="mq.approtation.${APP}.${DIR}"
      echo "Exporting ${DOMAIN} (${REGION})"
      CERT_ARN=$(aws acm list-certificates --region "$REGION" \
        --includes keyTypes=RSA_2048 \
        --query "CertificateSummaryList[?DomainName=='${DOMAIN}'] | [0].CertificateArn" --output text)
      if [ "$CERT_ARN" = "None" ] || [ -z "$CERT_ARN" ]; then
        echo "ERROR: no ACM certificate found for ${DOMAIN} in ${REGION}" >&2
        exit 1
      fi
      EXPORT=$(aws acm export-certificate --region "$REGION" \
        --certificate-arn "$CERT_ARN" --passphrase "$PASSPHRASE_B64")

      BASE="certs/${APP}.${DIR}.${REGION_SHORT}"
       printf '%s' "$EXPORT" | jq -r '.Certificate'      > "${BASE}.pem"
       printf '%s' "$EXPORT" | jq -r '.CertificateChain' > "certs/${APP}-chain.${DIR}.${REGION_SHORT}.pem"
       printf '%s' "$EXPORT" | jq -r '.PrivateKey'       > "${BASE}.key.enc"

      openssl x509 -in "${BASE}.pem" -outform der -out "${BASE}.der"
      # first certificate of the chain = issuing (subordinate) CA
      awk '/BEGIN CERTIFICATE/{n++} n==1' "certs/${APP}-chain.${DIR}.${REGION_SHORT}.pem" \
        | openssl x509 -outform der -out "certs/${APP}-chain.${DIR}.${REGION_SHORT}.der"
      openssl rsa -in "${BASE}.key.enc" -passin "pass:${PASSPHRASE}" \
        -out "certs/${APP}.${DIR}.pk.${REGION_SHORT}.key" 2>/dev/null
      rm -f "${BASE}.key.enc" "certs/${APP}-chain.${DIR}.${REGION_SHORT}.pem"
    done
  done
done
echo "Certificates written to $(pwd)/certs"
