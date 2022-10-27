// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.settlement.inbound.service;

import app.settlement.inbound.exceptions.KinesisStreamException;
import app.settlement.inbound.pojo.RawMessage;
import app.settlement.inbound.config.AwsProperties;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import software.amazon.awssdk.core.SdkBytes;
import software.amazon.awssdk.services.kinesis.KinesisAsyncClient;
import software.amazon.awssdk.services.kinesis.model.PutRecordRequest;
import org.apache.commons.lang3.RandomStringUtils;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.concurrent.ExecutionException;

@Slf4j
@Service
public class RawMessageService {

    KinesisAsyncClient client;
    String streamName;

    private final static ObjectMapper JSON = new ObjectMapper();
    static {
        JSON.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
    }

    public RawMessageService(KinesisAsyncClient kinesisAsyncClient, AwsProperties awsProperties){
        this.client = kinesisAsyncClient;
        this.streamName = awsProperties.getStreamName();
    }

    public static RawMessage givenMessage(String rawMessage, String id) {
        return RawMessage.builder()
                .id(id).rawMessage(rawMessage)
                .currentDate(new SimpleDateFormat("yyyy-MM-dd").format(new Date()))
                .currentTime(new SimpleDateFormat("HH:mm:ss").format(new Date()))
                .timestamp(System.currentTimeMillis()).build();
    }

    public void pushToIngestion(RawMessage message) throws KinesisStreamException {
        byte[] bytes = toJsonAsBytes(message);
        if (bytes == null || bytes.length < 1) {
            log.error("Could not get JSON bytes for raw message");
            return;
        }

//        log.info("Pushing message upstream");
        try {
            PutRecordRequest request = PutRecordRequest.builder()
                    .partitionKey(RandomStringUtils.randomAlphabetic(5, 20))
                    .streamName(streamName)
                    .data(SdkBytes.fromByteArray(bytes))
                    .build();

            client.putRecord(request).get();
        } catch (ExecutionException e) {
            log.info("Interrupted: ", e);
            throw new KinesisStreamException("Error writing to Kinesis stream", e);
        } catch (InterruptedException e) {
            log.info("Exception while sending data to Kinesis. Will try again.", e);
            throw new KinesisStreamException("Error writing to Kinesis stream", e);
        }
    }

    public byte[] toJsonAsBytes(RawMessage message) {
        try {
            return JSON.writeValueAsBytes(message);
        } catch (IOException e) {
            return null;
        }
    }
}
