# Trade Matching Core Matching
## Preface
Trade Matching core Matching engine for trade matching and mismatch.
This core matching engine performs matching and mismatching in periodic bases and send the matched and mismatched trades to Egress Kinesis Stream.
<br>

MatchedTradeMessageProducerService - This service takes List of Matched Trades with allocations and send them to Egress Kinesis Stream
TradeMatchingService - This service is for interacting with the TradeAllocationDAO which perform the matching and mismatching logic.
ScheduledMatchingService - This service is for triggering the matching on a scheduled bases. This also orchestrate the Trade Matching process and sending data to Kinesis through MatchedTradeMessageProducerService
TradeAllocationDAO - Database access layer which perform trade matching, mismatching and updating the database  

## Configuration
```yaml
config:
  spring.datasource.url=${DB_URL}
  spring.datasource.username=${DB_USERNAME}
  spring.datasource.password=${DB_PASSWORD}
  aws.rout53arcClusterArn=arn:aws:route53-recovery-control::285719923712:cluster/dcd287b3-3da2-4801-a359-864eb27269bd
  aws.region=us-east-1
  aws.controlPanel=trade-matching-control-panel
  aws.routingControlPrefix=trade-matching-app-
 ```
## Usage

```shell
java -jar build/libs/tradematching-0.0.1-SNAPSHOT.jar --aws.region=$REGION
```
