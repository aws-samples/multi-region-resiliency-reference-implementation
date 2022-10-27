// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.outbound.pojo;

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
@DynamoDbImmutable(builder = SettlementMessage.SettlementMessageBuilder.class)
public class SettlementMessage {
	@Getter(onMethod = @__({@DynamoDbPartitionKey}))
	private String id;
	private long timestamp;
	private String currentDate;
	private String currentTime;
	// for matching
	private String senderID;
	private String imID;
	private String brokerID;
	private String tradeID;
	private long allocationID; // counter beginning at 1
	private int quantity; // allocation level quantity as described in the TM
	private String security;
	private String transactionIndicator;    //  Can be ‘B’ for Buy or ‘S’ for Sell.
	private double price;
	private Instant tradeDate;
	private Instant settlementDate;
	private String deliveryInstructions;
	private String status;
	private String account;

}
