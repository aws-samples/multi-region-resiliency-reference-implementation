# Trade Matching  Outbound Gateway
## Preface
Trade Matching Outbound Gateway App is responsible to process messages from Egress, 
The messages are saved to a safe store before they are published to either
* Trade outgoing MQ
* Settlement Incoming MQ

## Configuration

```yml
aws:
  stateTableName: "ingestionTesting"
  inboundStreamName: "trade-matching-ingress-us-east-1-kinesis-stream"
  region: "us-east-1"
settlement:
  endpoint: "settlement-endpoint"
  username: "settlement-username"
  password: "settlement-password"
  queue: "settlement-queue"
trades:
  endpoint: "trades-endpoint"
  username: "trades-username"
  password: "trades-password"
  queue: "trades-queue"
 ```
## Usage
```shell
java -jar build/libs/TradeMatchingOutbound-0.0.1-SNAPSHOT.jar --aws.stateTableName=$STATE_TABLE_NAME \
--aws.inboundStreamName=$INBOUND_STREAM_NAME --aws.region=$REGION --settlements.endpoint=$SETTLEMENT_ENDPOINT \
--settlements.username=$SETTLEMENT_USERNAME --settlements.password=$SETTLEMENT_PASSWORD --settlements.queue=$SETTLEMENT_QUEUE \
--trades.username=$TRADES_USERNAME --trades.password=$TRADES_PASSWORD --trades.queue=$TRADES_QUEUE \
--trades.endpoint=$TRADES_ENDPOINT
```

