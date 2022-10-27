// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.settlement.matching;

import app.settlement.matching.dao.SettlementDAO;
import app.settlement.matching.interfaces.SettlementRepository;
import app.settlement.matching.pojo.Settlement;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import org.apache.commons.lang3.RandomStringUtils;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import software.amazon.awssdk.core.SdkBytes;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.kinesis.KinesisAsyncClient;
import software.amazon.awssdk.services.kinesis.model.PutRecordsRequest;
import software.amazon.awssdk.services.kinesis.model.PutRecordsRequestEntry;
import software.amazon.awssdk.services.kinesis.model.PutRecordsResponse;
import software.amazon.kinesis.common.KinesisClientUtil;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.concurrent.ThreadLocalRandom;

public class SettlementMatchingE2ETests {

//    @Autowired
//    private SettlementRepository repo;
    private static String streamName = "settlement-core-settlement-us-east-1-kinesis-stream";

    private static Instant INSTANT_DATE = Instant.now();

    private KinesisAsyncClient kinesisClient =
            KinesisClientUtil.createKinesisAsyncClient(KinesisAsyncClient.builder().region(Region.of("us-east-1")));

    private static final Logger log = LoggerFactory.getLogger(SettlementMatchingApplication.class);

    private final static ObjectMapper JSON = new ObjectMapper();
    static {
        JSON.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
        JSON.registerModule(new JavaTimeModule());
    }

//    @AfterEach
//    void tearDown(){
//        repo.deleteAll();
//    }

    @Test
    void  testMatchingSettlements() throws InterruptedException {
        int randomAllocationId = ThreadLocalRandom.current().nextInt(1, 20);
        int randomQuantity = ThreadLocalRandom.current().nextInt(1, 100);
        ArrayList<Settlement> settlements = new ArrayList<>();
        for(int i = 1; i < 3; i++){
            int randomNum = ThreadLocalRandom.current().nextInt(0, 100);
            Settlement settlement = new Settlement();
            settlement.setCurrentDate(new SimpleDateFormat("yyyy-MM-dd").format(new Date()));
            settlement.setCurrentTime(new SimpleDateFormat("HH:mm:ss").format(new Date()));
            settlement.setTimestamp(System.currentTimeMillis());
            settlement.setSenderID("VOLUPTAS" + randomNum);
            settlement.setImID("VOLUPTAS"); //
            settlement.setBrokerID("QABRO010"); //
            settlement.setTradeID("3500017"); //
            settlement.setAllocationID(randomAllocationId); //
            settlement.setQuantity(randomQuantity); ////
            settlement.setSecurity("AMZN"); ////
            settlement.setTransactionIndicator("B"); ////
            settlement.setPrice(5); ////
            settlement.setTradeDate(INSTANT_DATE); ////
            settlement.setSettlementDate(INSTANT_DATE); ////
            settlement.setDeliveryInstructions("Et deleniti rer");
            settlement.setStatus("Unmatched");
            settlement.setAccount("6727534070"); ////
            //sender id, im id, broker id, trade id and allocation number
            settlement.setId(
                    String.format("%s-%s-%s-%s-%d", settlement.getSenderID(), settlement.getImID(), settlement.getBrokerID(), settlement.getTradeID(), settlement.getAllocationID())
            );
            settlements.add(settlement);
        }
        publishRecord(settlements);
    }

    @Test
    void  testMismatchingSettlements() throws InterruptedException {
        ArrayList<Settlement> settlements = new ArrayList<>();
        int randomAllocationId = ThreadLocalRandom.current().nextInt(1, 20);
        for(int i = 1; i < 3; i++){
            int randomNum = ThreadLocalRandom.current().nextInt(0, 100);
            int randomQuantity = ThreadLocalRandom.current().nextInt(1, 100);
            Settlement settlement = new Settlement();
            settlement.setCurrentDate(new SimpleDateFormat("yyyy-MM-dd").format(new Date()));
            settlement.setCurrentTime(new SimpleDateFormat("HH:mm:ss").format(new Date()));
            settlement.setTimestamp(System.currentTimeMillis());
            settlement.setSenderID("VOLUPTAS" + randomNum);
            settlement.setImID("VOLUPTAS"); //
            settlement.setBrokerID("QABRO010"); //
            settlement.setTradeID("3500017"); //
            settlement.setAllocationID(randomAllocationId); //
            settlement.setQuantity(randomQuantity); //// differing quantities should lead to mismatch
            settlement.setSecurity("AMZN"); ////
            settlement.setTransactionIndicator("B"); ////
            settlement.setPrice(5); ////
            settlement.setTradeDate(Instant.now()); ////
            settlement.setSettlementDate(Instant.now()); ////
            settlement.setDeliveryInstructions("Et deleniti rer");
            settlement.setStatus("Unmatched");
            settlement.setAccount("6727534070"); ////
            //sender id, im id, broker id, trade id and allocation number
            settlement.setId(
                    String.format("%s-%s-%s-%s-%d", settlement.getSenderID(), settlement.getImID(), settlement.getBrokerID(), settlement.getTradeID(), settlement.getAllocationID())
            );
            settlements.add(settlement);
        }
        publishRecord(settlements);
    }

    @Test
    void  testUnmatchedSettlements() throws InterruptedException {
        int randomNum = ThreadLocalRandom.current().nextInt(0, 100);
        int randomAllocationId = ThreadLocalRandom.current().nextInt(1, 20);
        int randomQuantity = ThreadLocalRandom.current().nextInt(1, 100);
        // if we send only one settlement to an empty DB it should be unmatched status
        ArrayList<Settlement> settlements = new ArrayList<>();
        Settlement settlement = new Settlement();
        settlement.setCurrentDate(new SimpleDateFormat("yyyy-MM-dd").format(new Date()));
        settlement.setCurrentTime(new SimpleDateFormat("HH:mm:ss").format(new Date()));
        settlement.setTimestamp(System.currentTimeMillis());
        settlement.setSenderID("VOLUPTAS" + randomNum);
        settlement.setImID("VOLUPTAS"); //
        settlement.setBrokerID("QABRO010"); //
        settlement.setTradeID("3500017"); //
        settlement.setAllocationID(randomAllocationId); //
        settlement.setQuantity(randomQuantity); ////
        settlement.setSecurity("AMZN"); ////
        settlement.setTransactionIndicator("B"); ////
        settlement.setPrice(5); ////
        settlement.setTradeDate(Instant.now()); ////
        settlement.setSettlementDate(Instant.now()); ////
        settlement.setDeliveryInstructions("Et deleniti rer");
        settlement.setStatus("Unmatched");
        settlement.setAccount("6727534070"); ////
        //sender id, im id, broker id, trade id and allocation number
        settlement.setId(
                String.format("%s-%s-%s-%s-%d", settlement.getSenderID(), settlement.getImID(), settlement.getBrokerID(), settlement.getTradeID(), settlement.getAllocationID())
        );

        settlements.add(settlement);
        publishRecord(settlements);
    }

    private void publishRecord(ArrayList<Settlement> settlements) throws InterruptedException {
        List<PutRecordsRequestEntry> putRecordsRequestEntryList = new ArrayList<>();
        settlements.forEach(s -> putRecordsRequestEntryList.add(
                PutRecordsRequestEntry.builder()
                        .partitionKey(RandomStringUtils.randomAlphabetic(2, 20))
                        .data(SdkBytes.fromByteArray(toJsonAsBytes(s)))
                        .build()));

        PutRecordsRequest request = PutRecordsRequest.builder()
                .streamName(streamName)
                .records(putRecordsRequestEntryList)
                .build();
        try {
            PutRecordsResponse putRecordsResponse = kinesisClient.putRecords(request).get();
            log.info("put records finished");
            log.info(putRecordsResponse.toString());
        } catch (Exception e) {
            log.error("issue putting mock data", e);
        }
    }

    public byte[] toJsonAsBytes(Settlement settlement) {
        try {
            return JSON.writeValueAsBytes(settlement);
        } catch (IOException e) {
            log.error("Error parsing settlement to bytes: ", e);
            return null;
        }
    }

}
