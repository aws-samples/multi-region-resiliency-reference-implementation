// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.outbound.pojo;

import lombok.Builder;
import lombok.Getter;
import lombok.Value;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbImmutable;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbPartitionKey;

@Value
@DynamoDbImmutable(builder = SafeStoreResponseMessage.SafeStoreResponseMessageBuilder.class)
@Builder
public class SafeStoreResponseMessage {
    @Getter(onMethod = @__({@DynamoDbPartitionKey}))
    private String id;
    private String currentDate;
    private String currentTime;
    private long timestamp;
    private String status;
    private String description;
    private String destination;
    private String message;

}
