// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.settlement.egress.services;

import app.settlement.egress.configs.AwsConfig;
import app.settlement.egress.dao.SettlementDAO;
import app.settlement.egress.exceptions.DynamoDBConnectionException;
import app.settlement.egress.exceptions.KinesisStreamException;
import app.settlement.egress.exceptions.SettlementMessageParsingException;
import app.settlement.egress.pojo.Settlement;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.RandomStringUtils;
import org.springframework.stereotype.Service;
import software.amazon.awssdk.core.SdkBytes;
import software.amazon.awssdk.services.kinesis.KinesisAsyncClient;
import software.amazon.awssdk.services.kinesis.model.PutRecordsRequest;
import software.amazon.awssdk.services.kinesis.model.PutRecordsRequestEntry;
import software.amazon.awssdk.services.kinesis.model.PutRecordsResponse;

import java.text.SimpleDateFormat;
import java.util.*;
import java.util.concurrent.CompletableFuture;

@Slf4j
@Service
public class SettlementService {
    SettlementDAO dao;
    private AwsConfig awsConfig;

    private final static ObjectMapper JSON = new ObjectMapper();
    static {
        JSON.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
        JSON.registerModule(new JavaTimeModule());
    }

    public SettlementService(SettlementDAO dao, AwsConfig awsConfig){
        this.dao = dao;
        this.awsConfig = awsConfig;
    }


    public Settlement settlementFromBytes(byte[] bytes) throws SettlementMessageParsingException {
        try{
            // parse settlement
            Settlement settlement = JSON.readValue(bytes, Settlement.class);
            // then return new settlement from old with fields needed for storage + tracking
            return Settlement.builder()
                    .id(settlement.getId())
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
        dao.save(settlements);
    }

    public void pushSettlementsUpstream(List<Settlement> settlements) throws KinesisStreamException {
        String streamName = awsConfig.awsProperties.getOutboundStreamName();
        KinesisAsyncClient client = awsConfig.getKinesisClient();
        ObjectMapper objectMapper = new ObjectMapper();
        objectMapper.registerModule(new JavaTimeModule());
        log.info("Pushing Settlements to Outbound");
        try {
            List<PutRecordsRequestEntry> putRecordsRequestEntryList = new ArrayList<>();
            settlements.forEach(s -> {
                try {
                    putRecordsRequestEntryList.add(
                            PutRecordsRequestEntry.builder()
                                    .partitionKey(RandomStringUtils.randomAlphabetic(5, 20))
                                    .data(SdkBytes.fromByteArray(objectMapper.writeValueAsString(s).getBytes()))
                                    .build());
                } catch (JsonProcessingException e) {
                    // todo should an exception here throw an error or is logging fine?
                    log.error("Exception pushing settlements to Core: ", e);
                }
            });

            PutRecordsRequest putRecordsRequest = PutRecordsRequest.builder()
                    .streamName(streamName)
                    .records(putRecordsRequestEntryList)
                    .build();

            CompletableFuture<PutRecordsResponse> putRecordsResult = client.putRecords(putRecordsRequest);
            putRecordsResult.join();
            log.info("Put Result" + putRecordsResult);
        } catch (Exception e) {
            log.error("Exception pushing settlements to Outbound: ", e);
            throw new KinesisStreamException("Error writing to Kinesis stream", e);
        }
    }

}
