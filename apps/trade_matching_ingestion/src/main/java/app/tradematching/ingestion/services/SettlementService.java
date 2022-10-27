// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.ingestion.services;

import app.tradematching.ingestion.exceptions.SettlementMessageParsingException;
import app.tradematching.ingestion.utils.AwsConfig;
import app.tradematching.ingestion.exceptions.DynamoDBConnectionException;
import app.tradematching.ingestion.exceptions.KinesisStreamException;
import app.tradematching.ingestion.pojo.Settlement;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.RandomStringUtils;
import org.springframework.stereotype.Service;
import software.amazon.awssdk.core.SdkBytes;
import software.amazon.awssdk.enhanced.dynamodb.DynamoDbEnhancedClient;
import software.amazon.awssdk.enhanced.dynamodb.DynamoDbTable;
import software.amazon.awssdk.enhanced.dynamodb.Expression;
import software.amazon.awssdk.enhanced.dynamodb.model.BatchWriteResult;
import software.amazon.awssdk.enhanced.dynamodb.model.PutItemEnhancedRequest;
import software.amazon.awssdk.enhanced.dynamodb.model.WriteBatch;
import software.amazon.awssdk.services.dynamodb.model.ConditionalCheckFailedException;
import software.amazon.awssdk.services.kinesis.KinesisAsyncClient;
import software.amazon.awssdk.services.kinesis.model.PutRecordsRequest;
import software.amazon.awssdk.services.kinesis.model.PutRecordsRequestEntry;
import software.amazon.awssdk.services.kinesis.model.PutRecordsResponse;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.concurrent.CompletableFuture;

@Slf4j
@Service
public class SettlementService {
    private AwsConfig awsConfig;

    private final static ObjectMapper JSON = new ObjectMapper();
    static {
        JSON.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
        JSON.registerModule(new JavaTimeModule());
    }

    public SettlementService(AwsConfig awsConfig){
        this.awsConfig = awsConfig;
    }

    public Settlement settlementFromBytes(byte[] bytes) throws SettlementMessageParsingException {
        try{
            // parse settlement
            Settlement settlement = JSON.readValue(bytes, Settlement.class);
            // then return new settlement from old with fields needed for storage + tracking
            return Settlement.builder()
                    .id(settlement.getId())
//                    .timestamp(System.currentTimeMillis())
                    .timestamp(settlement.getTimestamp())
                    .currentDate(new SimpleDateFormat("yyyy-MM-dd").format(new Date()))
                    .currentTime(new SimpleDateFormat("HH:mm:ss").format(new Date()))
                    .senderID(settlement.getSenderID())
                    .imID(settlement.getImID())
                    .brokerID(settlement.getBrokerID())
                    .tradeID(settlement.getTradeID())
                    .allocationID(settlement.getAllocationID())
                    .quantity(settlement.getQuantity())
                    .security(settlement.getSecurity())
                    .transactionIndicator(settlement.getTransactionIndicator())
                    .price(settlement.getPrice())
                    .tradeDate(settlement.getTradeDate()).settlementDate(settlement.getSettlementDate())
                    .deliveryInstructions(settlement.getDeliveryInstructions()).status(settlement.getStatus())
                    .account(settlement.getAccount())
                    .build();
        }catch (Exception e) {
            log.error("Cannot parse as Settlement json string");
        }
        throw new SettlementMessageParsingException("Error parsing settlement message");
    }

    public void persistSettlements(List<Settlement> settlements) throws DynamoDBConnectionException {
        DynamoDbTable<Settlement> settlementDynamoDbTable = awsConfig.getSettlementTable();
        for (Settlement s : settlements){
            try {
                Expression putExpression = Expression.builder().expression("attribute_not_exists(id)").build();
                PutItemEnhancedRequest<Settlement> request = PutItemEnhancedRequest.<Settlement>builder(Settlement.class)
                        .conditionExpression(putExpression)
                        .item(s)
                        .build();
                settlementDynamoDbTable.putItem(request);
            } catch (ConditionalCheckFailedException e){
                log.error("Record already exists in table");
            } catch (Exception e)
            {
                log.error("Exception saving settlements to dynamodb", e);
                throw new DynamoDBConnectionException("Error saving settlement to dynamodb", e);
            }

        }
//        DynamoDbEnhancedClient enhancedClient = DynamoDbEnhancedClient.builder()
//                .dynamoDbClient(awsConfig.getDynamoDbClient())
//                .build();
//        try {
//            WriteBatch.Builder<Settlement> recordBuilder = WriteBatch.builder(Settlement.class).mappedTableResource(settlementDynamoDbTable);
//            for (int i = 0; i < settlements.size(); i++){
//                recordBuilder.addPutItem(settlements.get(i));
//                if (i % 24 == 0 || i == settlements.size() - 1){
//                    WriteBatch.Builder<Settlement> finalRecordBuilder = recordBuilder;
//                    BatchWriteResult result = enhancedClient.batchWriteItem(r -> r.addWriteBatch(finalRecordBuilder.build()));
//                    log.info(result.toString());
//                    recordBuilder = WriteBatch.builder(Settlement.class).mappedTableResource(settlementDynamoDbTable);
//                }
//            }
//        }catch (Exception e){
//            log.error("Exception saving settlements to dynamodb", e);
//            throw new DynamoDBConnectionException("Error saving settlement to dynamodb", e);
//        }
    }

    public void pushSettlementsUpstream(List<Settlement> settlements) throws KinesisStreamException {
        String streamName = awsConfig.awsProperties.getSettlementOutboundStream();
        KinesisAsyncClient client = awsConfig.getKinesisClient();
        ObjectMapper objectMapper = new ObjectMapper();
        objectMapper.registerModule(new JavaTimeModule());
        log.info("Pushing Settlements to " + streamName);
        try {
            List<PutRecordsRequestEntry> putRecordsRequestEntryList = new ArrayList<>();
            int index=1;
            for (Settlement s : settlements)
            {
                if (index==500) {
                    PutRecordsRequest putRecordsRequest = PutRecordsRequest.builder()
                            .streamName(streamName)
                            .records(putRecordsRequestEntryList)
                            .build();

                    CompletableFuture<PutRecordsResponse> putRecordsResult = client.putRecords(putRecordsRequest);
                    putRecordsResult.join();
                    index=1;
                    putRecordsRequestEntryList = new ArrayList<>();
                }
                else
                {
                    try {
                        putRecordsRequestEntryList.add(
                                PutRecordsRequestEntry.builder()
                                        .partitionKey(RandomStringUtils.randomAlphabetic(5, 20))
                                        .data(SdkBytes.fromByteArray(objectMapper.writeValueAsString(s).getBytes()))
                                        .build());
                        index++;
                    } catch (JsonProcessingException e) {
                        // todo should an exception here throw an error or is logging fine?
                        log.error("Exception pushing settlements to Core: ", e);
                    }
                }
            }
            if (index>1) {
                PutRecordsRequest putRecordsRequest = PutRecordsRequest.builder()
                        .streamName(streamName)
                        .records(putRecordsRequestEntryList)
                        .build();

                CompletableFuture<PutRecordsResponse> putRecordsResult = client.putRecords(putRecordsRequest);
                putRecordsResult.join();
                log.info("Put Result" + putRecordsResult);
            }
        } catch (Exception e) {
            log.error("Exception pushing settlements to Outbound: ", e);
            throw new KinesisStreamException("Error writing to Kinesis stream", e);
        }
    }

}
