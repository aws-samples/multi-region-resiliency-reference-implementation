# Settlement Matching Service

## Usage
Pass required variables into jar:
- spring.datasource.url=jdbc:postgresql://host/name
- spring.datasource.username=username
- spring.datasource.password=password
- aws.region=us-east-1
- aws.inboundStream=inboundStream
- aws.outboundStream=outboundStream

Then run:
```shell
java -jar build/libs/SettlementCoreMatching-0.0.1-SNAPSHOT.jar --spring.datasource.url=$DB_URL \
--spring.datasource.username=$DB_USERNAME --spring.datasource.password=$DB_PASSWORD --aws.region=$REGION \
--aws.inboundStream=$INBOUND_STREAM_NAME --aws.outboundStream=$OUTBOUND_STREAM_NAME
```