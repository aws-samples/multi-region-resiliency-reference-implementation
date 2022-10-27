// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.ingestion.services;

import app.tradematching.ingestion.exceptions.DynamoDBConnectionException;
import app.tradematching.ingestion.exceptions.KinesisStreamException;
import app.tradematching.ingestion.pojo.NackMessage;
import app.tradematching.ingestion.pojo.RawMessage;
import app.tradematching.ingestion.pojo.Trade;
import app.tradematching.ingestion.utils.AwsConfig;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.RandomStringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import software.amazon.awssdk.core.SdkBytes;
import software.amazon.awssdk.enhanced.dynamodb.DynamoDbTable;
import software.amazon.awssdk.enhanced.dynamodb.Expression;
import software.amazon.awssdk.enhanced.dynamodb.model.PutItemEnhancedRequest;
import software.amazon.awssdk.services.dynamodb.model.ConditionalCheckFailedException;
import software.amazon.awssdk.services.kinesis.KinesisAsyncClient;
import software.amazon.awssdk.services.kinesis.model.PutRecordsRequest;
import software.amazon.awssdk.services.kinesis.model.PutRecordsRequestEntry;
import software.amazon.awssdk.services.kinesis.model.PutRecordsResponse;

import java.text.SimpleDateFormat;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.time.format.FormatStyle;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.concurrent.CompletableFuture;

@Slf4j
@Service
public class NackService {

    private final static ObjectMapper JSON = new ObjectMapper();
    static {
        JSON.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
    }

    @Autowired
    private AwsConfig awsConfig;

    private static final DateTimeFormatter dateFormatter =
            DateTimeFormatter.ofLocalizedDateTime( FormatStyle.FULL )
                    .withLocale( Locale.US )
                    .withZone( ZoneId.systemDefault() );

    public NackMessage nackFromRawMessage(RawMessage message, String description) {
        return NackMessage.builder().id(message.getId()).message(message.getRawMessage())
                .status("NACK").destination("destination").description(description)
                .timestamp(System.currentTimeMillis())
                .currentDate(new SimpleDateFormat("yyyy-MM-dd").format(new Date()))
                .currentTime(new SimpleDateFormat("HH:mm:ss").format(new Date()))
                .build();
    }

    public void persistNack(NackMessage nm) throws DynamoDBConnectionException {
        DynamoDbTable<NackMessage> table = awsConfig.getNackTable();
        log.info("Putting nack into safe store: " + nm);
        try {
            Expression putExpression = Expression.builder().expression("attribute_not_exists(id)").build();
            PutItemEnhancedRequest<NackMessage> request = PutItemEnhancedRequest.<NackMessage>builder(NackMessage.class)
                    .conditionExpression(putExpression)
                    .item(nm)
                    .build();
            table.putItem(request);
        } catch (ConditionalCheckFailedException e){
            log.error("Record already exists in table");
        } catch(Exception e) {
            log.error("Error Putting nack into dynamoDB", e);
            throw new DynamoDBConnectionException("Error Saving Nack Trade to dynamoDB", e);
        }
    }

    public void pushNacksToEgress(List<NackMessage> nacks) throws KinesisStreamException {
        String streamName = awsConfig.awsProperties.getNackStream();
        KinesisAsyncClient client = awsConfig.getKinesisClient();
        ObjectMapper objectMapper = new ObjectMapper();
        objectMapper.registerModule(new JavaTimeModule());
        log.info("Pushing NACKs to Egress");
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
            log.error("Exception pushing NACKs to Egress: ", e);
            throw new KinesisStreamException("Error writing to Kinesis stream", e);
        }
    }

}
