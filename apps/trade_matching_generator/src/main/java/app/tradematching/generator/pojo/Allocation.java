// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.generator.pojo;

import lombok.Data;
import net.minidev.json.JSONObject;

@Data
public class Allocation {
    private int allocationID;  // A counter beginning at 1, incrementing for each allocation associated with the block
    private int quantity;         // Will be a value up to 100% of the Block quantity. For 1 allocation, this quantity will be equal to the Block quantity.
    private String account;       // an account for whom the IM made the trade
    private String status;        // Valid Value is ‘Settled’. This value is populated from the Settlement application.

    public Object toJson() {
        JSONObject jsonObj = new JSONObject();
        jsonObj.put("allocationID", getAllocationID());
        jsonObj.put("quantity",getQuantity());
        jsonObj.put("account", getAccount());
        jsonObj.put("status", getStatus());
        return jsonObj.toString();
    }
}
