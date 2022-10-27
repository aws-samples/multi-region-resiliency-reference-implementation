# Ingestion
## Preface
Ingestion app is responsible for processing new messages, parsing them, validating them and submit them for matching.
The app processing flow:
1. Consume messages from the Inbound Gateway Kinesis Stream
2. Parse message into Trade object - if an error occurs during parsing, send a NACK to egress service
3. Write object to DynamoDB safe store
4. Push messages upstream to Core Trade Matching Kinesis Stream

## Configuration

Make sure application.yml is updated before running:
```yaml
aws:
  stateTableName: "ingestionTableTest"
  settlementStateTableName: ""
  inboundStream: "trade-matching-ingress-us-east-1-kinesis-stream"
  settlementInboundStream: ""
  outboundStream: "trade-matching-core-us-east-1-kinesis-stream"
  settlementOutboundStream: ""
  nackStream: ""
  region: "us-east-1"
logging:
  level:
    root: info
    rapide: info
```

## Usage
```shell
./gradlew build
java -jar build/libs/kinesismessagedump-0.0.1-SNAPSHOT.jar --aws.stateTableName=$STATE_TABLE_NAME \
--aws.inboundStream=$INBOUND_STREAM_NAME --aws.outboundStream=$OUTBOUND_STREAM_NAME --aws.nackStream=$NACK_STREAM_NAME \
--aws.region=$REGION --aws.settlementStateTableName=$STATE_SETTLEMENT_TABLE_NAME --aws.settlementInboundStream=$INBOUND_SETTLEMENT_STREAM_NAME \
--aws.settlementOutboundStream=$OUTBOUND_SETTLEMENT_STREAM_NAME 
```