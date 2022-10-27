ALTER TABLE trade_message ADD COLUMN IF NOT EXISTS timestamp bigint;
CREATE INDEX IF NOT EXISTS timestamp_idx ON trade_message (timestamp);