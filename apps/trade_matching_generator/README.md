# Trades Data Generator
## Preface
The application generates trades and push them to a JMS Queue.
Trades are generated in pairs with a distribution of 33% Matched, 33% Mismatch, 33% Unmatched
<br>
Trade count indicates the number of pairs.
<br><br>
Trade will continuously generate trades based on the Arc53 routing control configured in application.yaml

## Configuration
The application runs as a service, and uses Route53 Arc to control start/stop generation of messages
-- change the configuration below to point to another control plane:
1. region: us-east-1
2. controlPanel: trade-matching-control-panel
3. routingControl: trade-matching-generator

batchCount configuration controls the amount of pairs of trades to generate for each iteration. it is recommended to use a number below 100 inorder to see trades generation happening faster in real-time.

Review aws section in application.yaml and edit the configuration for your requirements/environment
/src/main/resources/application.yaml

Review trades-generator section application.yaml and edit the configuration for your requirements/environment
/src/main/resources/application.yaml

## Usage
The Application runs as a service, configure the 
to generate trades to a queue set the flag -q = true
```bash
gradle build
java -jar build/libs/trades-0.0.1-SNAPSHOT.jar --aws.region=us-east-1 --aws.queueEndPoint=QUEUE_ENDPOINT --aws.queueUsername=QUEUE_USERNAME --aws.queuePassword=QUEUE_PASSWORD --aws.destinationQueue=QUEUE_NAME --trades-generator.batchCount=BATCH_COUNT
```
