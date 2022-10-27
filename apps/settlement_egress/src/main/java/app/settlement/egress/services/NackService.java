// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.settlement.egress.services;

import app.settlement.egress.configs.AwsConfig;
import app.settlement.egress.dao.NackMessageDAO;
import app.settlement.egress.exceptions.DynamoDBConnectionException;
import app.settlement.egress.exceptions.KinesisStreamException;
import app.settlement.egress.pojo.NackMessage;
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

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.concurrent.CompletableFuture;

@Slf4j
@Service
public class NackService {
    NackMessageDAO dao;
    private AwsConfig awsConfig;

    private final static ObjectMapper JSON = new ObjectMapper();
    static {
        JSON.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
        JSON.registerModule(new JavaTimeModule());
    }

    public NackService(NackMessageDAO dao, AwsConfig awsConfig){
        this.dao = dao;
        this.awsConfig = awsConfig;
    }

    public NackMessage nackFromBytes(byte[] bytes) throws IOException {
        NackMessage nackMessage = JSON.readValue(bytes, NackMessage.class);
        return NackMessage.builder().id(nackMessage.getId()).message(nackMessage.getMessage())
                .status(nackMessage.getStatus()).destination(nackMessage.getDestination()).description(nackMessage.getDescription())
                .timestamp(System.currentTimeMillis())
                .currentDate(new SimpleDateFormat("yyyy-MM-dd").format(new Date()))
                .currentTime(new SimpleDateFormat("HH:mm:ss").format(new Date()))
                .build();
    }

    public void persistNacks(List<NackMessage> nacks) throws DynamoDBConnectionException {
        dao.save(nacks);
    }

    public void pushNacksToEgress(List<NackMessage> nacks) throws KinesisStreamException {
        String streamName = awsConfig.awsProperties.getOutboundStreamName();
        KinesisAsyncClient client = awsConfig.getKinesisClient();
        ObjectMapper objectMapper = new ObjectMapper();
        objectMapper.registerModule(new JavaTimeModule());
        log.info("Pushing NACKs to Outbound");
        try {
            List<PutRecordsRequestEntry> putRecordsRequestEntryList = new ArrayList<>();
            nacks.forEach(nm -> {
                try {
                    putRecordsRequestEntryList.add(
                            PutRecordsRequestEntry.builder()
                                    .partitionKey(RandomStringUtils.randomAlphabetic(5, 20))
                                    .data(SdkBytes.fromByteArray(objectMapper.writeValueAsString(nm).getBytes()))
                                    .build());
                } catch (JsonProcessingException e) {
                    // todo should an exception here throw an error or is logging fine?
                    log.error("Exception pushing NACKs to Egress: ", e);
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
            log.error("Exception pushing NACKs to Outbound: ", e);
            throw new KinesisStreamException("Error writing to Kinesis stream", e);
        }
    }
}
