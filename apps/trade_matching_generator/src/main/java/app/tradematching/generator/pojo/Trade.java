// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.generator.pojo;

import lombok.Data;
import net.minidev.json.JSONArray;
import net.minidev.json.JSONObject;

import java.text.DateFormat;
import java.text.DecimalFormat;
import java.time.Instant;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.time.format.FormatStyle;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

@Data
public class Trade {
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
    private List<Allocation> allocations;

    @Override
    public String toString() {
        DecimalFormat df = new DecimalFormat("#,###.00");
        DecimalFormat df2 = new DecimalFormat("#,###");
        Locale locale = new Locale("en", "US");
        DateFormat dateFormat = DateFormat.getTimeInstance(DateFormat.DEFAULT, locale);
        return String.format("Trade {senderID=%s, imID=%s, " +
                        "brokerID=%s, tradeID=%s, security=%s, " +
                        "transactionIndicator=%s, price=%s, quantity=%s," +
                        "tradeDate=%s, settlementDate=%s, " +
                        "deliveryInstructions=%s, status=%s }",
                getSenderID(), getImID(), getBrokerID(), getTradeID(),
                getSecurity(), getTransactionIndicator(),
                df.format(getPrice()), df2.format(getQuantity()),
                getTradeDate(), getSettlementDate(),
                getDeliveryInstructions(), getStatus());
    }

    public String toJson() {
        DateTimeFormatter formatter =
                DateTimeFormatter.ofLocalizedDateTime( FormatStyle.FULL )
                        .withLocale( Locale.US )
                        .withZone( ZoneId.systemDefault() );
        JSONObject jsonObj = new JSONObject();
        jsonObj.put("senderID", getSenderID());
        jsonObj.put("imID",getImID());
        jsonObj.put("brokerID", getBrokerID());
        jsonObj.put("tradeID", getTradeID());
        jsonObj.put("security", getSecurity());
        jsonObj.put("transactionIndicator", getTransactionIndicator());
        jsonObj.put("price", getPrice());
        jsonObj.put("quantity", getQuantity());
//        jsonObj.put("tradeDate", formatter.format(getTradeDate()));
//        jsonObj.put("settlementDate", formatter.format(getSettlementDate()));
        jsonObj.put("tradeDate", getTradeDate().toString());
        jsonObj.put("settlementDate", getSettlementDate().toString());
        jsonObj.put("deliveryInstructions", getDeliveryInstructions());
        jsonObj.put("status", getStatus());
        List<Allocation> allocations_json = getAllocations();
        JSONArray allocations_array = new JSONArray();
        for (Allocation allocation: allocations_json)
            allocations_array.add(allocation.toJson());
        jsonObj.put("allocations", allocations_array);

        return jsonObj.toString();
    }

    public Map<String, Object> toMap() {
        DateTimeFormatter formatter =
                DateTimeFormatter.ofLocalizedDateTime( FormatStyle.FULL )
                        .withLocale( Locale.US )
                        .withZone( ZoneId.systemDefault() );

        Map<String, Object> map = new HashMap<>();
        map.put("senderID", this.getSenderID());
        map.put("imID", this.getImID());
        map.put("brokerID", this.getBrokerID());
        map.put("tradeID", this.getTradeID());
        map.put("security", this.getSecurity());
        map.put("transactionIndicator", this.getTransactionIndicator());
        map.put("price", this.getPrice());
        map.put("quantity", this.getQuantity());
        map.put("tradeDate", formatter.format(this.getTradeDate()));
        map.put("settlementDate", formatter.format(this.getSettlementDate()));
        map.put("deliveryInstructions", this.getDeliveryInstructions());
        map.put("status", this.getStatus());
        List<Allocation> allocations = this.getAllocations();
        int index = 1;

        for (Allocation allocation : allocations) {
            Map<String, String> allocation_map = new HashMap<String,String>();
            allocation_map.put("AllocationID", String.valueOf(allocation.getAllocationID()));
            allocation_map.put("Quantity", String.valueOf(allocation.getQuantity()));
            allocation_map.put("Account", String.valueOf(allocation.getAccount()));
            allocation_map.put("Status", String.valueOf(allocation.getStatus()));
            map.put("allocation" + String.valueOf(index), allocation_map);
            index++;
        }

        return map;
    }
}

