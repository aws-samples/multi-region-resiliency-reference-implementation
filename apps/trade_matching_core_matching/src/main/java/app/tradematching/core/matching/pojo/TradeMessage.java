// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.core.matching.pojo;

import java.io.Serializable;
import java.math.BigInteger;
import java.time.Instant;
import java.util.List;

import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.OneToMany;
import javax.persistence.Table;

import lombok.Data;

@Data
@Entity
@Table(name = "trade_message")
public class TradeMessage implements Serializable {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id", columnDefinition = "serial")
    private long dbID;
    @Column(name = "uuid")
    private String id;
    @Column(name = "curr_date")
    private String currentDate;
    @Column(name = "curr_time")
    private String currentTime;
    @Column(name = "timestamp")
    private BigInteger timestamp;
    @Column(name = "sender_id")
    private String senderID;
    @Column(name = "im_id")
    private String imID;
    @Column(name = "broker_id")
    private String brokerID;
    @Column(name = "trade_id")
    private String tradeID;
    @Column(name = "security")
    private String security;
    @Column(name = "transaction_indicator")
    private String transactionIndicator;    //  Can be ‘B’ for Buy or ‘S’ for Sell.
    @Column(name = "price")
    private double price;
    @Column(name = "quantity")
    private int quantity;
    @Column(name = "trade_date")
    private Instant tradeDate;
    @Column(name = "settlement_date")
    private Instant settlementDate;
    @Column(name = "delivery_instructions")
    private String deliveryInstructions;
    @Column(name = "status")
    private String status;                  // Valid values are ‘Unmatched’, ‘Mismatched’, ‘Matched’, ‘Cancelled’, and ‘Settled’

    @OneToMany(cascade = CascadeType.ALL, orphanRemoval = true, mappedBy = "tradeMessage", fetch = FetchType.EAGER)
    private List<TradeAllocation> allocations;


}
