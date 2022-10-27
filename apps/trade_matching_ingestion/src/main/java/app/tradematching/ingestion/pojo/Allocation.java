// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.ingestion.pojo;

import com.fasterxml.jackson.databind.MapperFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.Data;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbBean;

import java.io.Serializable;

@DynamoDbBean
@Data
public class Allocation implements Serializable {
    private int allocationID;  // A counter beginning at 1, incrementing for each allocation associated with the block
    private int quantity;         // Will be a value up to 100% of the Block quantity. For 1 allocation, this quantity will be equal to the Block quantity.
    private String account;       // an account for whom the IM made the trade
    private String status;        // Valid Value is ‘Settled’. This value is populated from the Settlement application.

//    public static Allocation fromObject(Object obj){
//        ObjectMapper objectMapper = new ObjectMapper();
//        // Allocation key values coming in with capital letters
//        objectMapper.configure(MapperFeature.ACCEPT_CASE_INSENSITIVE_PROPERTIES, true);
//        Allocation newAllocation = objectMapper.convertValue(obj, Allocation.class);
//        return newAllocation;
//    }
}
