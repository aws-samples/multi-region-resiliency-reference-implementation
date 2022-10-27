// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.settlement.egress;

import app.settlement.egress.pojo.NackMessage;
import app.settlement.egress.pojo.Settlement;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import org.apache.commons.lang3.RandomStringUtils;
import org.junit.jupiter.api.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
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

public class SettlementEgressE2ETests {
    private static String streamName = "settlement-egress-us-east-1-kinesis-stream";

    private KinesisAsyncClient kinesisClient =
            KinesisClientUtil.createKinesisAsyncClient(KinesisAsyncClient.builder().region(Region.of("us-east-1")));

    private static final Logger log = LoggerFactory.getLogger(SettlementEgressApplication.class);

    private final static ObjectMapper JSON = new ObjectMapper();
    static {
        JSON.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
        JSON.registerModule(new JavaTimeModule());
    }


    @Test
    void nackTest() throws InterruptedException {
        List<NackMessage> nacks = new ArrayList<>();
        for (int i = 0; i < 10; i++){
            nacks.add(
                    NackMessage.builder().id("e4381798-2f61-4d53-ade0-b56079a9b3e3" + i)
                            .currentDate(new SimpleDateFormat("yyyy-MM-dd").format(new Date()))
                            .currentTime(new SimpleDateFormat("HH:mm:ss").format(new Date()))
                            .timestamp(System.currentTimeMillis()).message("this is a test").description("this is a test")
                            .status("NACK").destination("destination").build()
            );
        }
        publishNackRecord(nacks);
    }

    @Test
    void settlementTest() throws InterruptedException {
        // if we send only one settlement to an empty DB it should be unmatched status
        List<Settlement> settlements = new ArrayList<>();
        for (int i = 0; i < 10; i++){
            int randomNum = ThreadLocalRandom.current().nextInt(0, 100);
            int randomAllocationId = ThreadLocalRandom.current().nextInt(1, 20);
            int randomQuantity = ThreadLocalRandom.current().nextInt(1, 100);
            String senderId = "VOLUPTAS" + randomNum;
            String imId = "VOLUPTAS";
            String brokerId = "QABRO010";
            String tradeId = "3500017";
            String id = String.format("%s-%s-%s-%s-%d", senderId, imId, brokerId, tradeId, randomAllocationId);
            settlements.add(
                    Settlement.builder().currentDate(new SimpleDateFormat("yyyy-MM-dd").format(new Date()))
                            .currentTime(new SimpleDateFormat("HH:mm:ss").format(new Date()))
                            .timestamp(System.currentTimeMillis()).senderID(senderId)
                            .imID(imId).brokerID(brokerId).tradeID(tradeId).allocationID(randomAllocationId)
                            .quantity(randomQuantity).security("AMZN")
                            .transactionIndicator("B").price(5).tradeDate(Instant.now()).settlementDate(Instant.now())
                            .deliveryInstructions("Et deleniti rer").status("Settled").account("6727534070").id(id).build()
            );
        }
        publishRecord(settlements);
    }

    private void publishRecord(List<Settlement> messages) throws InterruptedException {
        List<PutRecordsRequestEntry> putRecordsRequestEntryList = new ArrayList<>();
        messages.forEach(m -> putRecordsRequestEntryList.add(
                PutRecordsRequestEntry.builder()
                        .partitionKey(RandomStringUtils.randomAlphabetic(2, 20))
                        .data(SdkBytes.fromByteArray(toJsonAsBytes(m)))
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

    private void publishNackRecord(List<NackMessage> messages) throws InterruptedException {
        List<PutRecordsRequestEntry> putRecordsRequestEntryList = new ArrayList<>();
        messages.forEach(m -> putRecordsRequestEntryList.add(
                PutRecordsRequestEntry.builder()
                        .partitionKey(RandomStringUtils.randomAlphabetic(2, 20))
                        .data(SdkBytes.fromByteArray(toJsonAsBytes(m)))
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

    public byte[] toJsonAsBytes(Object message) {
        try {
            return JSON.writeValueAsBytes(message);
        } catch (IOException e) {
            return null;
        }
    }
}
