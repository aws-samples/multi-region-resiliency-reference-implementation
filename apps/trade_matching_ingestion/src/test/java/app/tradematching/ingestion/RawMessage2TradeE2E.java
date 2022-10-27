// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.ingestion;

import app.tradematching.ingestion.pojo.RawMessage;
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

import java.util.ArrayList;
import java.util.List;

//@SpringBootTest
public class RawMessage2TradeE2E {
    private static String streamName = "testinStream";

    private KinesisAsyncClient kinesisClient =
            KinesisClientUtil.createKinesisAsyncClient(KinesisAsyncClient.builder().region(Region.of("us-east-1")));

    private static final Logger log = LoggerFactory.getLogger(MessageIngestionApplication.class);

    @Test
    void testRawMessageToKinesis() throws InterruptedException {
        for (int j = 0; j < 1; j++) {
            ArrayList<RawMessage> list = new ArrayList<>();
            for (int i = 0; i < 20; i++) {
//                list.add(getSampleRawMessage(i));
                list.add(getSampleBadMessage(i));
            }
            publishRecord(list);
        }
    }

    private RawMessage getSampleRawMessage(int i) {
        RawMessage rawMessage = new RawMessage();
        rawMessage.setId("e4381798-2f61-4d53-ade0-b56079a9b3e3" + i);
        rawMessage.setTimestamp(1643663158148L);
        rawMessage.setRawMessage("{\"brokerID\":\"5062661010\",\"quantity\":3313,\"tradeDate\":\"2022-01-25T01:31:14Z\",\"settlementDate\":\"2022-01-31T21:05:54.597506Z\",\"transactionIndicator\":\"B\",\"imID\":\"2545908364\",\"deliveryInstructions\":\"Aut eius ut.Ten\",\"senderID\":\"6644623370\",\"security\":\"EUM\",\"allocations\":[\"{\\\"quantity\\\":100,\\\"allocationID\\\":1,\\\"account\\\":\\\"1538552570\\\",\\\"status\\\":\\\"Settled\\\"}\"],\"price\":4091.823533894876,\"tradeID\":\"19426\",\"status\":\"Cancelled\"}");
        return rawMessage;
    }

    private RawMessage getSampleBadMessage(int i) {
        RawMessage rawMessage = new RawMessage();
        rawMessage.setId("e4381798-2f61-4d53-ade0-b56079a9b3e3" + i);
        rawMessage.setTimestamp(1643663158148L);
//        rawMessage.setRawMessage("{\"brokerID\":\"5062661010\",\"quantity\":3313,\"settlementDate\":\"2022-01-31T21:05:54.597506Z\",\"transactionIndicator\":\"B\",\"imID\":\"2545908364\",\"deliveryInstructions\":\"Aut eius ut.Ten\",\"senderID\":\"6644623370\",\"security\":\"EUM\",\"allocations\":[\"{\\\"quantity\\\":100,\\\"allocationID\\\":1,\\\"account\\\":\\\"1538552570\\\",\\\"status\\\":\\\"Settled\\\"}\"],\"price\":4091.823533894876,\"tradeID\":\"19426\",\"status\":\"Cancelled\"}");
        rawMessage.setRawMessage("Java is fun! :)");
        return rawMessage;
    }

    private void publishRecord(ArrayList<RawMessage> messages) throws InterruptedException {
        List<PutRecordsRequestEntry> putRecordsRequestEntryList = new ArrayList<>();
        messages.forEach(m -> putRecordsRequestEntryList.add(
                PutRecordsRequestEntry.builder()
                        .partitionKey(RandomStringUtils.randomAlphabetic(2, 20))
                        .data(SdkBytes.fromByteArray(m.toJsonAsBytes()))
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
}
