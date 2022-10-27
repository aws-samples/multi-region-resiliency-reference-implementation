// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.outbound;

import app.tradematching.outbound.pojo.ResponseMessage;
import com.fasterxml.jackson.core.JsonProcessingException;
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

import java.util.ArrayList;
import java.util.List;

public class Egress2OutboundE2E {
    private static String streamName = "trade-matching-out-gateway-trade-us-east-1-kinesis-stream";

    private KinesisAsyncClient kinesisClient =
            KinesisClientUtil.createKinesisAsyncClient(KinesisAsyncClient.builder().region(Region.of("us-east-1")));

    private static final Logger log = LoggerFactory.getLogger(TradeMatchingOutboundApplication.class);

    @Test
    void testRawMessageToKinesis() throws InterruptedException {
        for (int j = 0; j < 1; j++) {
            ArrayList<ResponseMessage> list = new ArrayList<>();
            for (int i = 0; i < 20; i++) {
                list.add(getSampleRawMessage(i));
            }
            publishRecord(list);
        }
    }

    private ResponseMessage getSampleRawMessage(int i) {
        ResponseMessage responseMessage = new ResponseMessage();
        responseMessage.setId("e4381798-2f61-4d53-ade0-b56079a9b3e3");
        responseMessage.setDescription("Test description");
        responseMessage.setStatus("ACK");
//        responseMessage.setDestination(i%2 == 0 ? "destination" : "SETTLEMENT");
        responseMessage.setDestination("destination");
        responseMessage.setMessage("{\"brokerID\":\"5062661010\",\"quantity\":3313,\"tradeDate\":\"2022-01-25T01:31:14Z\",\"settlementDate\":\"2022-01-31T21:05:54.597506Z\",\"transactionIndicator\":\"B\",\"imID\":\"2545908364\",\"deliveryInstructions\":\"Aut eius ut.Ten\",\"senderID\":\"6644623370\",\"security\":\"EUM\",\"allocations\":[\"{\\\"quantity\\\":100,\\\"allocationID\\\":1,\\\"account\\\":\\\"1538552570\\\",\\\"status\\\":\\\"Settled\\\"}\"],\"price\":4091.823533894876,\"tradeID\":\"19426\",\"status\":\"Cancelled\"}");
        return responseMessage;
    }

    private void publishRecord(ArrayList<ResponseMessage> messages) throws InterruptedException {
        ObjectMapper objectMapper = new ObjectMapper();
        objectMapper.registerModule(new JavaTimeModule());

        List<PutRecordsRequestEntry> putRecordsRequestEntryList = new ArrayList<>();
        messages.forEach(m -> {
            try {
                putRecordsRequestEntryList.add(
                        PutRecordsRequestEntry.builder()
                                .partitionKey(RandomStringUtils.randomAlphabetic(2, 20))
                                .data(SdkBytes.fromByteArray(objectMapper.writeValueAsString(m).getBytes()))
                                .build());
            } catch (JsonProcessingException e) {
                log.error("fail to convert object to json ", e);
            }
        });

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
