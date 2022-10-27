# Trade Matching  Egress
## Preface

Trade Matching Egress App process trades that matched from Core Matching. it will also create settlements from the trade allocation.
Each trade and allocation will be saved to a safe store(separate tables)
Egress will also support processing unparsed trades from ingestion process.
Egress will output trades and settlement to trade matching Outbound.


## Configuration
```yaml
aws:
  safeStoreTable: "trade-matching-egress-dynamodb-store"
  settlementSafeStoreTable: "trade-matching-egress-settlement-dynamodb-store"
  inboundStreamName: "trade-matching-egress-us-east-1-kinesis-stream"
  outboundStreamName: "trade-matching-out-gateway-us-east-1-kinesis-stream"
  outboundSettlementStreamName: "trade-matching-out-gateway-settlement-us-east-1-kinesis-stream"
  region: "us-east-1"
```

## Usage
```shell
java -jar build/libs/TradeMatchingEgress-0.0.1-SNAPSHOT.jar --aws.safeStoreTable=$STATE_TABLE_NAME \
--aws.inboundStreamName=$INBOUND_STREAM_NAME --aws.region=$REGION --aws.outboundStreamName=$OUTBOUND_STREAM_NAME --aws.settlementSafeStoreTable=$STATE_SETTLEMENT_TABLE_NAME --aws.outboundSettlementStreamName=$OUTBOUND_SETTLEMENT_STREAM_NAME
```