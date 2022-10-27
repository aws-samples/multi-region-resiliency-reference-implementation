// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.egress.pojo;

import java.io.Serializable;
import java.time.Instant;
import java.util.List;

import lombok.Data;

@Data
public class TradeMessage implements Serializable {
    private long dbID;
    private String id;
    private String tradeUUID;
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
    private String status;                  // Valid values are ‘Unmatched’, ‘Mismatched’, ‘Matched’, ‘Cancelled’, and ‘Settled’

    private List<TradeAllocation> allocations;


}
