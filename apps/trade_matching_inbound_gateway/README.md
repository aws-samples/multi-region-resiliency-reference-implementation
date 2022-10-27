# Inbound Gateway

## Preface
The application runs as a service and consist of three components:
1. Region State Manager -> monitor route53 arc control to activate/de-activate the application
2. Main application which instantiate a listener to ActiveMQ
3. Message processor which take the message save them to DynamoDB Resistance storage and replay the message to kinesis stream for parsing and validation.

## Configuration
Update src/main/resources/application.yml with the appropriate configurations:
```yaml
aws:
  stateTableName: "approtationTesting"
  stateSettlementTableName: "test22"
  streamName: "testinStream"
  settlementStreamName: "test2"
  region: "us-east-1"
  arcClusterArn: ""
  controlPanel: trade-matching-control-panel
  routingControlPrefix: trade-matching-queue-
logging:
  level:
    root: info
    rapide: info
spring:
  main:
    web-application-type: "none"
    banner-mode: "off"
  jms:
    queue:
      name: <Active MQ Queue name>
    listener:
      acknowledge-mode: client
  activemq:
    broker-url: <Queue SSL endpoint>
    pool:
      enabled: true
      max-connections: 5
    user: <Queue username>
    password: <Queue password>
```

## Usage
```shell
./gradlew build
java -jar build/libs/app.inbound.gateway-0.0.1-SNAPSHOT.jar --aws.stateTableName=$STATE_TABLE_NAME \
--aws.stateSettlementTableName=$STATE_SETTLEMENT_TABLE_NAME \
--aws.streamName=$STREAM_NAME --aws.settlementStreamName=$SETTLEMENT_STREAM_NAME --aws.region=$REGION --spring.activemq.broker-url=$QUEUE_EP \
--spring.activemq.user=$QUEUE_USERNAME --spring.activemq.password=$QUEUE_PASSWORD \
--spring.jms.queue.name=$QUEUE_NAME --aws.arcClusterArn=$ARC_CLUSTER 
```