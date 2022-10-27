// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.ingestion.pojo;

import lombok.Data;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbBean;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbPartitionKey;

import java.io.Serializable;
import java.time.Instant;
import java.util.*;

@Slf4j
@DynamoDbBean
@Data
@Component
public class Trade implements Serializable {
    private String id;
    private String currentDate;
    private String currentTime;
    private long timestamp;
    private String senderID;
    private String imID;
    private String brokerID;
    private String tradeID;
    private String security;
    private String transactionIndicator;    //  Can be ‘B’ for Buy or ‘S’ for Sell.
    private double price;
    private int quantity;
    private Instant tradeDate;
    private Instant settlementDate;
    private String deliveryInstructions;
    private String status;                  // Valid values are ‘Unmatched’, ‘Mismatched’, ‘Matched’, ‘Cancelled’, and ‘Settled’ and NACK
    private List<Allocation> allocations;

    // for Egress
//    private String type;  // ACK, NACK, Matched, Unmatched
//    private String description;   // Ex. Unable to parse trade message

    @DynamoDbPartitionKey
    public String getId(){
        return this.id;
    }
}

