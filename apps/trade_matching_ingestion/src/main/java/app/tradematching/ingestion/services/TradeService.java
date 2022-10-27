// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.ingestion.services;

import app.tradematching.ingestion.exceptions.DynamoDBConnectionException;
import app.tradematching.ingestion.exceptions.KinesisStreamException;
import app.tradematching.ingestion.exceptions.TradeMessageParsingException;
import app.tradematching.ingestion.pojo.Allocation;
import app.tradematching.ingestion.pojo.RawMessage;
import app.tradematching.ingestion.pojo.Trade;
import app.tradematching.ingestion.utils.AwsConfig;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import com.jayway.jsonpath.JsonPath;
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

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.time.Instant;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.FormatStyle;
import java.util.*;
import java.util.concurrent.CompletableFuture;
import java.util.stream.Stream;

@Slf4j
@Service
public class TradeService {

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

    public Trade tradeFromRawMessage(RawMessage message) throws TradeMessageParsingException {
        // try json first...
        try {
            Map<String, Object> messageMap = JsonPath.parse(message.getRawMessage()).read("$");
            Trade trade = tradeFromMap(messageMap);
            // carry-over id & add new timestamp
            trade.setId(message.getId());
//            trade.setTimestamp(System.currentTimeMillis());
            trade.setTimestamp(message.getTimestamp());
            trade.setCurrentDate(new SimpleDateFormat("yyyy-MM-dd").format(new Date()));
            trade.setCurrentTime(new SimpleDateFormat("HH:mm:ss").format(new Date()));
            return trade;
        } catch (Exception e) {
            log.error("Cannot parse as json string", e);
        }
        /**
         * Other parsing methods would go here...
         */
        // Throw exception if trade wasn't returned earlier
        throw new TradeMessageParsingException("Error Parsing Trade message");
    }

    public boolean isValidTrade(Trade trade)  {
        return Stream.of(trade.getSenderID(), trade.getImID(), trade.getBrokerID(), trade.getTradeID(),
                trade.getSecurity(), trade.getTransactionIndicator(), trade.getPrice(), trade.getQuantity(),
                trade.getTradeDate(), trade.getSettlementDate()).allMatch(Objects::nonNull);
    }

    private Trade tradeFromMap(Map<String, Object> mapObject) {
        Trade newTrade = new Trade();
        for ( String key: mapObject.keySet()){
            Object val = mapObject.get(key);
            if (key.contains("allocations")) {
                List<Allocation> allocations = new ArrayList<Allocation>();
                List<String> allocationsStringList = JsonPath.parse(val).read("$", List.class);
                for (String stringAllocation: allocationsStringList){
                    Allocation newAllocation = JsonPath.parse(stringAllocation).read("$", Allocation.class);
                    allocations.add(newAllocation);
                }
                val = allocations;
            }
            setWithSwitch(key, val, newTrade);
        }
        return newTrade;
    }

    private void setWithSwitch(String key, Object val, Trade t) {
        switch (key){
            case "senderID":
                t.setSenderID((String) val);
                break;
            case "imID":
                t.setImID((String) val);
                break;
            case "brokerID":
                t.setBrokerID((String) val);
                break;
            case "tradeID":
                t.setTradeID((String) val);
                break;
            case "security":
                t.setSecurity((String) val);
                break;
            case "transactionIndicator":
                t.setTransactionIndicator((String) val);
                break;
            case "price":
                t.setPrice((Double) val);
                break;
            case "quantity":
                t.setQuantity((int) val);
                break;
            case "tradeDate":
//                t.setTradeDate(t.stringToInstant((String)val));
                t.setTradeDate(Instant.parse((String)val));
                break;
            case "settlementDate":
//                t.setSettlementDate(t.stringToInstant((String)val));
                t.setSettlementDate(Instant.parse((String)val));
                break;
            case "deliveryInstructions":
                t.setDeliveryInstructions((String) val);
                break;
            case "status":
                t.setStatus((String) val);
                break;
            case "allocations":
                t.setAllocations((List<Allocation>) val);
                break;
            default:
                log.error("Unknown key to set in Trade object: " + key);
        }
    }

    public void persistTrade(Trade t) throws DynamoDBConnectionException {
        DynamoDbTable<Trade> table = awsConfig.getTradeTable();
        log.info("Putting trade into safe store: " + t);
        try {
            Expression putExpression = Expression.builder().expression("attribute_not_exists(id)").build();
            PutItemEnhancedRequest<Trade> request = PutItemEnhancedRequest.<Trade>builder(Trade.class)
                    .conditionExpression(putExpression)
                    .item(t)
                    .build();
            table.putItem(request);
        } catch (ConditionalCheckFailedException e){
            log.error("Record already exists in table");
        } catch(Exception e) {
            log.error("Error Putting trade into dynamoDB", e);
            throw new DynamoDBConnectionException("Error Saving Trade to dynamoDB", e);
        }
    }

    public void pushTradesUpstream(List<Trade> trades) throws KinesisStreamException {
        String streamName = awsConfig.awsProperties.getOutboundStream();
        KinesisAsyncClient client = awsConfig.getKinesisClient();
        ObjectMapper objectMapper = new ObjectMapper();
        objectMapper.registerModule(new JavaTimeModule());
        log.info("Pushing trades upstream");
        try {
            List<PutRecordsRequestEntry> putRecordsRequestEntryList = new ArrayList<>();
            int index  = 1;
            for (Trade t : trades) {
                if (index==500)
                {
                    PutRecordsRequest putRecordsRequest = PutRecordsRequest.builder()
                            .streamName(streamName)
                            .records(putRecordsRequestEntryList)
                            .build();

                    CompletableFuture<PutRecordsResponse> putRecordsResult = client.putRecords(putRecordsRequest);
                    putRecordsResult.join();
                    log.info("Put Result" + putRecordsResult);
                    index = 1;
                    putRecordsRequestEntryList = new ArrayList<>();
                }
                else {
                    try {
                        putRecordsRequestEntryList.add(
                                PutRecordsRequestEntry.builder()
                                        .partitionKey(RandomStringUtils.randomAlphabetic(5, 20))
                                        .data(SdkBytes.fromByteArray(objectMapper.writeValueAsString(t).getBytes()))
                                        .build());
                        index++;
                    } catch (JsonProcessingException e) {
                        // todo should an exception here throw an error or is logging fine?
                        log.error("Exception pushing trade to matching: ", e);
                    }
                }
            }
            //push left over
            if (index>1) {
                PutRecordsRequest putRecordsRequest = PutRecordsRequest.builder()
                        .streamName(streamName)
                        .records(putRecordsRequestEntryList)
                        .build();

                CompletableFuture<PutRecordsResponse> putRecordsResult = client.putRecords(putRecordsRequest);
                putRecordsResult.join();
                log.info("Put Result" + putRecordsResult);
            }
        } catch (Exception e) {
            log.error("Exception pushing trades to matching: ", e);
            throw new KinesisStreamException("Error writing to Kinesis stream", e);
        }
    }

    private Instant stringToInstant(String instantString) {
        ZonedDateTime zonedDateTime = ZonedDateTime.parse(instantString, this.dateFormatter);
        return zonedDateTime.toInstant();
    }


    public byte[] toJsonAsBytes(Trade t) {
        try {
            return JSON.writeValueAsBytes(t);
        } catch (IOException e) {
            return null;
        }
    }

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

//    @Override
//    public String toString() {
//        DecimalFormat df = new DecimalFormat("#,###.00");
//        DecimalFormat df2 = new DecimalFormat("#,###");
//        Locale locale = new Locale("en", "US");
//        DateFormat dateFormat = DateFormat.getTimeInstance(DateFormat.DEFAULT, locale);
//        return String.format("Trade {safeStoreID=%s, senderID=%s, imID=%s, " +
//                        "brokerID=%s, tradeID=%s, security=%s, " +
//                        "transactionIndicator=%s, price=%s, quantity=%s," +
//                        "tradeDate=%s, settlementDate=%s, " +
//                        "deliveryInstructions=%s, status=%s }",
//                String.valueOf(getId()),
//                getSenderID(), getImID(), getBrokerID(), getTradeID(),
//                getSecurity(), getTransactionIndicator(),
//                df.format(getPrice()), df2.format(getQuantity()),
//                getTradeDate(), getSettlementDate(),
//                getDeliveryInstructions(), getStatus());
//    }
    public Map<String, Object> toMap(Trade t) {
        Map<String, Object> map = new HashMap<>();
        map.put("senderID", t.getSenderID());
        map.put("imID", t.getImID());
        map.put("brokerID", t.getBrokerID());
        map.put("tradeID", t.getTradeID());
        map.put("security", t.getSecurity());
        map.put("transactionIndicator", t.getTransactionIndicator());
        map.put("price", t.getPrice());
        map.put("quantity", t.getQuantity());
        map.put("tradeDate", this.dateFormatter.format(t.getTradeDate()));
        map.put("settlementDate", this.dateFormatter.format(t.getSettlementDate()));
        map.put("deliveryInstructions", t.getDeliveryInstructions());
        map.put("status", t.getStatus());
        List<Allocation> allocations = t.getAllocations();
        int index = 1;

        for (Allocation allocation : allocations) {
            Map<String, String> allocation_map = new HashMap<String,String>();
            allocation_map.put("AllocationID", String.valueOf(allocation.getAllocationID()));
            allocation_map.put("Quantity", String.valueOf(allocation.getQuantity()));
            allocation_map.put("Account", String.valueOf(allocation.getAccount()));
            allocation_map.put("Status", String.valueOf(allocation.getStatus()));
            map.put("allocation" + String.valueOf(index), allocation_map);
            index++;
        }

        return map;
    }
}
