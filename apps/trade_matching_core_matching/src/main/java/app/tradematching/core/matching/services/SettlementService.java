// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.core.matching.services;

import app.tradematching.core.matching.config.AwsConfig;
import app.tradematching.core.matching.exceptions.SettlementMessageParsingException;
import app.tradematching.core.matching.exceptions.SettlementPersistException;
import app.tradematching.core.matching.jpa.SettlingRepository;
import app.tradematching.core.matching.pojo.Settlement;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.text.SimpleDateFormat;
import java.util.Date;

@Slf4j
@Service
public class SettlementService {
    private SettlingRepository repo;
    private AwsConfig awsConfig;

    private final static ObjectMapper JSON = new ObjectMapper();
    static {
        JSON.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
        JSON.registerModule(new JavaTimeModule());
    }

    public SettlementService(SettlingRepository settlingRepository, AwsConfig awsConfig){
        this.repo = settlingRepository;
        this.awsConfig = awsConfig;
    }

    public Settlement settlementFromBytes(byte[] bytes) throws SettlementMessageParsingException {
        try{
            // parse settlement
            Settlement settlement = JSON.readValue(bytes, Settlement.class);
            // then return new settlement from old with fields needed for storage + tracking
            return Settlement.builder()
                    .id(settlement.getId())
//                    .timestamp(System.currentTimeMillis())
                    .timestamp(settlement.getTimestamp())
                    .currentDate(new SimpleDateFormat("yyyy-MM-dd").format(new Date()))
                    .currentTime(new SimpleDateFormat("HH:mm:ss").format(new Date()))
                    .senderID(settlement.getSenderID())
                    .imID(settlement.getImID())
                    .brokerID(settlement.getBrokerID())
                    .tradeID(settlement.getTradeID())
                    .allocationID(settlement.getAllocationID())
                    .quantity(settlement.getQuantity())
                    .security(settlement.getSecurity())
                    .transactionIndicator(settlement.getTransactionIndicator())
                    .price(settlement.getPrice())
                    .tradeDate(settlement.getTradeDate()).settlementDate(settlement.getSettlementDate())
                    .deliveryInstructions(settlement.getDeliveryInstructions()).status(settlement.getStatus())
                    .account(settlement.getAccount())
                    .build();
        }catch (Exception e) {
            log.error("Cannot parse as Settlement json string");
            throw new SettlementMessageParsingException("Error parsing settlement message");
        }
    }

    public String doTradeSettling(Settlement settlement) throws SettlementPersistException {
        // for each settlement:
        // update TA status to align
        // add trade message IDs to a set (avoids re-searching trades that may have had multiple settlements in batch
        // return Trade UUID

        // build trade uuid for querying + checking later
        String tradeUuid = settlement.getSenderID() +"-" + settlement.getImID() + "-" +
                settlement.getBrokerID() + "-" + settlement.getTradeID();
        try{
            repo.updateTradeAllocationStatus(
                    settlement.getStatus(),
                    settlement.getAllocationID(),
                    tradeUuid,
                    settlement.getAccount(),
                    settlement.getQuantity()
            );
        }catch (Exception e){
            log.error("error settling trade allocation: ", e);
            throw new SettlementPersistException("Can't update settlement");
        }
        return tradeUuid;
    }
}
