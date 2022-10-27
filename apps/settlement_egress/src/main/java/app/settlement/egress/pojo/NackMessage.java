// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.settlement.egress.pojo;

import lombok.Builder;
import lombok.Getter;
import lombok.Value;
import lombok.extern.jackson.Jacksonized;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbImmutable;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbPartitionKey;

@Value
@Builder
@Jacksonized
@DynamoDbImmutable(builder = NackMessage.NackMessageBuilder.class)
public class NackMessage {

    @Getter(onMethod = @__({@DynamoDbPartitionKey}))
    private String id;
    private long timestamp;
    private String currentDate;
    private String currentTime;
    private String status;
    private String description;
    private String destination;
    private String message;
}
