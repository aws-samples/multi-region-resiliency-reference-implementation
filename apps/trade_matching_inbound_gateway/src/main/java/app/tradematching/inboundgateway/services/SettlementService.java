// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.inboundgateway.services;

import app.tradematching.inboundgateway.exceptions.KinesisStreamException;
import app.tradematching.inboundgateway.exceptions.SettlementMessageParsingException;
import app.tradematching.inboundgateway.utils.AwsConfig;
import app.tradematching.inboundgateway.exceptions.DynamoDBConnectionException;
import app.tradematching.inboundgateway.pojo.Settlement;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jms.core.JmsTemplate;
import org.springframework.stereotype.Service;
import software.amazon.awssdk.core.SdkBytes;
import software.amazon.awssdk.enhanced.dynamodb.DynamoDbTable;
import software.amazon.awssdk.enhanced.dynamodb.Expression;
import software.amazon.awssdk.enhanced.dynamodb.model.PutItemEnhancedRequest;
import software.amazon.awssdk.services.dynamodb.model.ConditionalCheckFailedException;
import software.amazon.awssdk.services.kinesis.KinesisAsyncClient;
import software.amazon.awssdk.services.kinesis.model.*;
import org.apache.commons.lang3.RandomStringUtils;

import javax.jms.TextMessage;
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
                    .timestamp(System.currentTimeMillis())
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

    public void persistSettlement(Settlement settlements) throws DynamoDBConnectionException {
        DynamoDbTable<Settlement> ddbTable = awsConfig.getSettlementTable();
//        ddbTable.putItem(settlements);
        try {
            Expression putExpression = Expression.builder().expression("attribute_not_exists(id)").build();
            PutItemEnhancedRequest<Settlement> request = PutItemEnhancedRequest.<Settlement>builder(Settlement.class)
                    .conditionExpression(putExpression)
                    .item(settlements)
                    .build();
            ddbTable.putItem(request);
        } catch (ConditionalCheckFailedException e){
            log.error("Record already exists in table");
        }
    }

    public void pushUpstream(Settlement settlement) throws KinesisStreamException {
        String streamName = awsConfig.awsProperties.getSettlementStreamName();
        KinesisAsyncClient client = awsConfig.getKinesisClient();
        log.info("Pushing Settlement to Ingestion");
        try {
            PutRecordRequest request = PutRecordRequest.builder()
                    .partitionKey(RandomStringUtils.randomAlphabetic(5, 20))
                    .streamName(streamName)
                    .data(SdkBytes.fromByteArray(JSON.writeValueAsString(settlement).getBytes()))
                    .build();
            CompletableFuture<PutRecordResponse> putRecordResult = client.putRecord(request);
            putRecordResult.join();
            log.info("Put Result" + putRecordResult);
        } catch (Exception e) {
            log.error("Exception pushing settlements to Outbound: ", e);
            throw new KinesisStreamException("Error writing to Kinesis stream", e);
        }
    }
}
