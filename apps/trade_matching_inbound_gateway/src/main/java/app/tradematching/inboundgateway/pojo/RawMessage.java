// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.inboundgateway.pojo;

import app.tradematching.inboundgateway.exceptions.DynamoDBConnectionException;
import app.tradematching.inboundgateway.exceptions.KinesisStreamException;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;

import lombok.Data;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import software.amazon.awssdk.core.SdkBytes;
import software.amazon.awssdk.enhanced.dynamodb.DynamoDbTable;
import software.amazon.awssdk.enhanced.dynamodb.Expression;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbBean;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbPartitionKey;
import software.amazon.awssdk.enhanced.dynamodb.model.PutItemEnhancedRequest;
import software.amazon.awssdk.services.dynamodb.model.ConditionalCheckFailedException;
import software.amazon.awssdk.services.kinesis.KinesisAsyncClient;
import software.amazon.awssdk.services.kinesis.model.PutRecordRequest;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
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

    public static RawMessage givenMessage(String rawMessage) {
        RawMessage newMessage = new RawMessage();
        newMessage.setTimestamp(System.currentTimeMillis());
//        newMessage.setId(java.util.UUID.randomUUID().toString());         Using actual concat id
        newMessage.setRawMessage(rawMessage);

        newMessage.setCurrentDate(new SimpleDateFormat("yyyy-MM-dd").format(new Date()));
        newMessage.setCurrentTime(new SimpleDateFormat("HH:mm:ss").format(new Date()));
        return newMessage;
    }

    @DynamoDbPartitionKey
    public String getId(){
        return this.id;
    }

    public void save(DynamoDbTable<RawMessage> table) throws DynamoDBConnectionException {
//        log.info("Putting message into safe store: " + this);
        try {
            Expression putExpression = Expression.builder().expression("attribute_not_exists(id)").build();
            PutItemEnhancedRequest<RawMessage> request = PutItemEnhancedRequest.<RawMessage>builder(RawMessage.class)
                    .conditionExpression(putExpression)
                    .item(this)
                    .build();
            table.putItem(request);
//            table.putItem(this);
        } catch (ConditionalCheckFailedException e){
            log.error("Record already exists in table");
        } catch(Exception e) {
            log.error("Error Putting trade into dynamoDB", e);
            throw new DynamoDBConnectionException("Error Saving Trade to dynamoDB", e);
        }
    }

    public void pushUpstream(KinesisAsyncClient client, String stream) throws KinesisStreamException {
        byte[] bytes = this.toJsonAsBytes();
        if (bytes == null || bytes.length < 1) {
            log.error("Could not get JSON bytes for raw message");
            return;
        }

//        log.info("Pushing message upstream");
        try {
            PutRecordRequest request = PutRecordRequest.builder()
                .partitionKey(getId())
                .streamName(stream)
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
        return String.format("RawMessage {id=%s, timestamp=%s, message=%s, date=%s, time=%s}",
                getId(), getTimestamp(), getRawMessage(), getCurrentDate(), getCurrentTime());
    }

}

