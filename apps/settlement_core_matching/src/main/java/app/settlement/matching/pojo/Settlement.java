// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.settlement.matching.pojo;

import com.fasterxml.jackson.annotation.JsonAlias;
import lombok.Builder;
import lombok.Data;
import lombok.Getter;
import lombok.Value;
import lombok.extern.jackson.Jacksonized;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbImmutable;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbPartitionKey;

import javax.persistence.*;
import java.time.Instant;

@Data
@Entity
@Table(name = "settlement_message")
public class Settlement {
    // for reconciliation
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "db_id", columnDefinition = "serial")
    private long dbID;
    @Column(name = "id")
    private String id;
    @Column(name = "curr_date")
    private String currentDate;
    @Column(name = "curr_time")
    private String currentTime;
    @Column(name = "timestamp")
    private long timestamp;
    // for matching
    @Column(name = "sender_id")
    private String senderID;
    @Column(name = "im_id")
    private String imID;
    @Column(name = "broker_id")
    private String brokerID;
    @Column(name = "trade_id")
    private String tradeID;
    @Column(name = "allocation_id")
    private long allocationID;
    @Column(name = "quantity")
    private int quantity;
    @Column(name = "security")
    private String security;
    @Column(name = "transaction_indicator")
    private String transactionIndicator;    //  Can be ‘B’ for Buy or ‘S’ for Sell.
    @Column(name = "price")
    private double price;
    @Column(name = "trade_date")
    private Instant tradeDate;
    @Column(name = "settlement_date")
    private Instant settlementDate;
    @Column(name = "delivery_instructions")
    private String deliveryInstructions;
    @Column(name = "status")
    private String status;
    @Column(name = "account")
    private String account; // Freeform text indicating an account for whom the IM made the trade

}

