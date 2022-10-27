-- // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
-- // SPDX-License-Identifier: MIT-0
ALTER TABLE trade_message ADD COLUMN IF NOT EXISTS timestamp bigint;
CREATE INDEX IF NOT EXISTS timestamp_idx ON trade_message (timestamp);