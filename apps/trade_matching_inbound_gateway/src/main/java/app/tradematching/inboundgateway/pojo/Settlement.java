// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.inboundgateway.pojo;

import lombok.Builder;
import lombok.Getter;
import lombok.Value;
import lombok.extern.jackson.Jacksonized;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbImmutable;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbPartitionKey;

import java.time.Instant;

@Value
@Builder
@Jacksonized
@DynamoDbImmutable(builder = Settlement.SettlementBuilder.class)
public class Settlement {
    // for reconciliation
    @Getter(onMethod = @__({@DynamoDbPartitionKey}))
    private String id;
    private String currentDate;
    private String currentTime;
    private long timestamp;
    // for matching
    private String senderID;
    private String imID;
    private String brokerID;
    private String tradeID;
//    @JsonAlias("tradeAllocationID")
    private long allocationID;
//    @JsonAlias("allocationQuantity")
    private int quantity;
    private String security;
    private String transactionIndicator;    //  Can be ‘B’ for Buy or ‘S’ for Sell.
    private double price;
    private Instant tradeDate;
    private Instant settlementDate;
    private String deliveryInstructions;
    private String status;
    private String account; // Freeform text indicating an account for whom the IM made the trade

}
