// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.egress.pojo;

import lombok.Data;

import java.io.Serializable;

@Data
public class TradeAllocation implements Serializable {

    private long id;
    private long allocationID; // A counter beginning at 1, incrementing for each allocation associated with
                                    // the block
    private int quantity; // Will be a value up to 100% of the Block quantity. For 1 allocation, this
                                    // quantity will be equal to the Block quantity.
    private String account; // an account for whom the IM made the trade
    private String status;

}
