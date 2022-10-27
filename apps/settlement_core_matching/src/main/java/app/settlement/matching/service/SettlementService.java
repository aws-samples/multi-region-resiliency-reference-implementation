// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

package app.settlement.matching.service;

import app.settlement.matching.config.AwsConfig;
import app.settlement.matching.dao.SettlementDAO;
import app.settlement.matching.exceptions.KinesisStreamException;
import app.settlement.matching.pojo.Settlement;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.RandomStringUtils;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import software.amazon.awssdk.core.SdkBytes;
import software.amazon.awssdk.services.kinesis.KinesisAsyncClient;
import software.amazon.awssdk.services.kinesis.model.PutRecordsRequest;
import software.amazon.awssdk.services.kinesis.model.PutRecordsRequestEntry;
import software.amazon.awssdk.services.kinesis.model.PutRecordsResponse;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Random;
import java.util.concurrent.CompletableFuture;

@Service
@Slf4j
public class SettlementService {

    private AwsConfig awsConfig;
    private SettlementDAO dao;

    SettlementService(AwsConfig awsConfig, SettlementDAO settlementDAO){
        this.awsConfig = awsConfig;
        this.dao = settlementDAO;
    }

    // method to orchestrate logic and handle errors
    public void handleSettlement(Settlement settlement){
        // try to persist new settlement
        try {
            dao.persistSettlement(settlement);
        } catch (DataIntegrityViolationException e){
            log.info("This settlement already exists - skipping");
            return;
        }

        Settlement pairedSettlement = null;

        // try to find pair
        try {
            // random unmatched settlement
            Random random = new Random();
            int randNumber = random.nextInt(100);
            if (randNumber <= awsConfig.awsProperties.getUnmatchedPercentage()) {
                pairedSettlement = null;
                log.info("Creating a random unmatched settlement");
            }
            else {
                pairedSettlement = dao.findSettlementPair(settlement);
            }
        } catch (Exception e){
            // confirm if catch is needed here
            log.error("Error finding pair for settlement: ", e);
        }

        List<Settlement> settlementList;

        // if pair is found, check if the pairs match
        if (pairedSettlement != null){
            settlementList = handleSettlementPair(settlement, pairedSettlement);
        } else {
            // Default status of settlement is Unmatched therefore if pair is not found return early
            return;
        }
        // update based on matching result
        try {
            dao.updateSettlements(settlementList);
        } catch (Exception e){
            // confirm if catch is needed here
            log.error("Error updating settlements: ", e);
        }

        // settlements settled/mismatched therefore we push to Egress
        try {
            pushSettlementsToEgress(settlementList);
        } catch (KinesisStreamException e) {
            log.error("Exception pushing settlements to Egress: ", e);
        }
    }

    private boolean areMatchingSettlements(Settlement a, Settlement b){
        return a.getSecurity().equals(b.getSecurity()) &&
                a.getTransactionIndicator().equals(b.getTransactionIndicator()) &&
                a.getPrice() == b.getPrice() && a.getQuantity() == b.getQuantity() &&
                a.getTradeDate().equals(b.getTradeDate()) && a.getSettlementDate().equals(b.getSettlementDate()) &&
                a.getAccount().equals(b.getAccount());
    }

    private List<Settlement> handleSettlementPair(Settlement a, Settlement b){
        if(areMatchingSettlements(a, b)){
            a.setStatus("Settled");
            b.setStatus("Settled");
        } else {
            a.setStatus("Mismatched");
            b.setStatus("Mismatched");
        }
        return new ArrayList<>(Arrays.asList(a, b));
    }

    private void pushSettlementsToEgress(List<Settlement> settlements) throws KinesisStreamException {
        String streamName = awsConfig.awsProperties.getOutboundStream();
        KinesisAsyncClient client = awsConfig.getKinesisClient();
        List<PutRecordsRequestEntry> putRecordsRequestEntries = new ArrayList<>();
        settlements.forEach(
            s -> {
                try {
                    putRecordsRequestEntries.add(
                            buildSettlementRequestEntry(s)
                    );
                } catch (JsonProcessingException e) {
                    log.error("Exception parsing settlement to push to Egress: ", e);
                }
            }
        );
        PutRecordsRequest putRecordsRequest = PutRecordsRequest.builder()
                .streamName(streamName)
                .records(putRecordsRequestEntries)
                .build();

        CompletableFuture<PutRecordsResponse> putRecordsResult = client.putRecords(putRecordsRequest);
        putRecordsResult.join();
        log.info("Put Result" + putRecordsResult);
    }

    private PutRecordsRequestEntry buildSettlementRequestEntry(Settlement s) throws JsonProcessingException {
        ObjectMapper objectMapper = new ObjectMapper();
        objectMapper.registerModule(new JavaTimeModule());
        return PutRecordsRequestEntry.builder()
            .partitionKey(RandomStringUtils.randomAlphabetic(5, 20))
            .data(SdkBytes.fromByteArray(objectMapper.writeValueAsString(s).getBytes()))
            .build();
    }
}
