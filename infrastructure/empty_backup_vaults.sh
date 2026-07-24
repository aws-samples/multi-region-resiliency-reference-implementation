#!/bin/bash
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0
#
# Deletes all recovery points from this solution's AWS Backup vaults in both
# regions. AWS Backup vaults cannot be deleted while they contain recovery
# points, so `make destroy-trading` / `make destroy-settlement` run this
# first. Usage: ./empty_backup_vaults.sh <app>   (trade-matching | settlement)
set -uo pipefail
APP=${1:?"usage: $0 <trade-matching|settlement>"}

for REGION in us-east-1 us-west-2; do
  for VAULT in $(aws backup list-backup-vaults --region "$REGION" \
      --query "BackupVaultList[?starts_with(BackupVaultName, '${APP}-core-')].BackupVaultName" --output text); do
    echo "Emptying vault $VAULT ($REGION)"
    for RP in $(aws backup list-recovery-points-by-backup-vault --region "$REGION" \
        --backup-vault-name "$VAULT" --query "RecoveryPoints[].RecoveryPointArn" --output text); do
      aws backup delete-recovery-point --region "$REGION" \
        --backup-vault-name "$VAULT" --recovery-point-arn "$RP" && echo "  deleted $RP"
    done
  done
done
echo "Done. Recovery point deletion is asynchronous; re-run destroy if the vault delete still races."
