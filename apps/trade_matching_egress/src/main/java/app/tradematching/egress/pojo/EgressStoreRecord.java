// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.egress.pojo;

import java.time.Instant;

import lombok.Builder;
import lombok.Getter;
import lombok.Value;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbImmutable;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbPartitionKey;

@Value
@Builder
@DynamoDbImmutable(builder = EgressStoreRecord.EgressStoreRecordBuilder.class)
public class EgressStoreRecord {
	
	@Getter(onMethod = @__({@DynamoDbPartitionKey}))
	private String id;
	private long timestamp;
	private String currentDate;
	private String currentTime;
	private String status;
	private String description;
	private String tradeMessage;

}
