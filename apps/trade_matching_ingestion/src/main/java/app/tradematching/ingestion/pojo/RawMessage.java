// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.ingestion.pojo;

import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;

import lombok.Data;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import software.amazon.awssdk.core.SdkBytes;
import software.amazon.awssdk.enhanced.dynamodb.DynamoDbTable;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbAttribute;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbBean;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbPartitionKey;
import software.amazon.awssdk.services.kinesis.KinesisAsyncClient;
import software.amazon.awssdk.services.kinesis.model.PutRecordRequest;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.ObjectOutputStream;
import java.io.Serializable;
import java.util.concurrent.ExecutionException;

@Slf4j
@DynamoDbBean
@Data
@Component
public class RawMessage {

    private final static ObjectMapper JSON = new ObjectMapper();
    static {
        JSON.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
    }

    private long timestamp;
    private String id;
    private String rawMessage;
    private String currentDate;
    private String currentTime;

    public static RawMessage fromMessage(String rawMessage) {
        RawMessage newMessage = new RawMessage();
        newMessage.setTimestamp(System.currentTimeMillis());
        newMessage.setId(java.util.UUID.randomUUID().toString());
        newMessage.setRawMessage(rawMessage);
        return newMessage;
    }

    @DynamoDbPartitionKey
    public String getId(){
        return this.id;
    }

    public static RawMessage fromJsonAsBytes(byte[] bytes) {
        try {
            return JSON.readValue(bytes, RawMessage.class);
        } catch (IOException e) {
            return null;
        }
    }

    public byte[] toJsonAsBytes() {
        try {
            return JSON.writeValueAsBytes(this);
        } catch (IOException e) {
            return null;
        }
    }
//
//    private byte[] toByteArray() {
//        ByteArrayOutputStream bos = new ByteArrayOutputStream();
//        ObjectOutputStream out = null;
//        byte[] bytesResult = new byte[0];
//        try {
//            out = new ObjectOutputStream(bos);
//            out.writeObject(this);
//            out.flush();
//            bytesResult = bos.toByteArray();
//        } catch (Exception e){
//            log.error("Error occurred turning object to bytes: " + e);
//        } finally {
//            try {
//                bos.close();
//            } catch (IOException ex) {
//                // ignore close exception
//            }
//        }
//        return bytesResult;
//    }

    @Override
    public String toString() {
        return String.format("RawMessage {id=%s, timestamp=%s, message=%s}",
                getId(), getTimestamp(), getRawMessage());
    }

}

