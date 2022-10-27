// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.core.matching.pojo;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.Data;

import javax.persistence.*;
import java.io.Serializable;

@Data
@Entity
@Table(name = "trade_allocation")
@JsonIgnoreProperties(value = { "tradeMessage" })
public class TradeAllocation implements Serializable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(columnDefinition = "serial")
    private long id;
    @Column(name = "trade_allocation_id")
    private long allocationID;  // A counter beginning at 1, incrementing for each allocation associated with the block
    @Column(name = "allocation_quantity")
    private int quantity;         // Will be a value up to 100% of the Block quantity. For 1 allocation, this quantity will be equal to the Block quantity.
    @Column(name = "allocation_account")
    private String account;       // an account for whom the IM made the trade
    @Column(name = "allocation_status")
    private String status;

    @ManyToOne
    @JoinColumn(name="trade_message_id")
    private TradeMessage tradeMessage;
}
