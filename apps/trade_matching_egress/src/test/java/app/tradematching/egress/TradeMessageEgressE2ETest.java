// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.egress;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.ExecutionException;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;

import org.apache.commons.lang3.RandomStringUtils;
import org.junit.jupiter.api.Test;

import app.tradematching.egress.pojo.TradeAllocation;
import app.tradematching.egress.pojo.TradeMessage;
import lombok.extern.slf4j.Slf4j;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import software.amazon.awssdk.core.SdkBytes;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.kinesis.KinesisAsyncClient;
import software.amazon.awssdk.services.kinesis.model.PutRecordsRequest;
import software.amazon.awssdk.services.kinesis.model.PutRecordsRequestEntry;
import software.amazon.kinesis.common.KinesisClientUtil;

public class TradeMessageEgressE2ETest {

    private static String streamName = "trade-matching-egress-us-east-1-kinesis-stream";

    private KinesisAsyncClient kinesisClient =
            KinesisClientUtil.createKinesisAsyncClient(KinesisAsyncClient.builder().region(Region.of("us-east-1")));

    private static final Logger log = LoggerFactory.getLogger(TradeMatchingEgressApplication.class);

    @Test
    void testGenerateTradeMessageToKinesis(){
        ArrayList<TradeMessage> list = new ArrayList<>();
        for (int i = 0; i < 10; i++) {
            list.add(getSampleTradeMessage());
        }
        publishRecord(list);

    }
    private TradeMessage getSampleTradeMessage(){
        TradeMessage tm = new TradeMessage();
        tm.setTradeUUID(UUID.randomUUID().toString());
//        tm.setTradeMesssageID("123123");
        tm.setSenderID("SENDER123");
        tm.setImID("IM123");
        tm.setBrokerID("BK123");
        tm.setTradeID("Tradeid");
        tm.setSecurity("AMZN");
        tm.setTransactionIndicator("B");
        tm.setPrice(123.21);
        tm.setQuantity(100);
        tm.setTradeDate(Instant.now());
        tm.setSettlementDate(Instant.now());
        tm.setDeliveryInstructions("hello");
        tm.setStatus("MATCHED");

        TradeAllocation taa = new TradeAllocation();
        taa.setTradeAllocationID(312312);
        // taa.setTradeMessage(tm);
        taa.setTradeAllocationID(100);
        taa.setTradeAllocationID(10);
        taa.setAllocaitonStatus("HELLO");
        List<TradeAllocation> list = new ArrayList<TradeAllocation>();
        list.add(taa);
        tm.setAllocations(list);
        return tm;
    }

    private void publishRecord(ArrayList<TradeMessage> messages) {
        List<PutRecordsRequestEntry> putRecordsRequestEntries = new ArrayList<>();

        ObjectMapper objectMapper = new ObjectMapper();
		objectMapper.registerModule(new JavaTimeModule());

        messages.forEach(m -> {
            try {
                putRecordsRequestEntries.add(PutRecordsRequestEntry.builder()
                                                    .partitionKey(RandomStringUtils.randomAlphabetic(5, 20))
                                                    .data(SdkBytes.fromByteArray(objectMapper.writeValueAsString(m).getBytes()))
                                                    .build());
            } catch (JsonProcessingException e) {
                log.error("fail to convert object to json ", e);
            }
        });


        PutRecordsRequest putRecordsRequest = PutRecordsRequest.builder().records(putRecordsRequestEntries).streamName(streamName).build();
        try {
            
            kinesisClient.putRecords(putRecordsRequest).get();
        } catch (InterruptedException e) {
            log.info("Interrupted, assuming shutdown.");
        } catch (ExecutionException e) {
            log.error("Exception while sending data to Kinesis. Will try again next cycle.", e);
        }
    }
}
