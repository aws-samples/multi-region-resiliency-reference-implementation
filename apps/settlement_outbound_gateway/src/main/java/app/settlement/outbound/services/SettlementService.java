// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.settlement.outbound.services;

import app.settlement.outbound.configs.AwsConfig;
import app.settlement.outbound.configs.OutboundQueue;
import app.settlement.outbound.dao.SettlementDAO;
import app.settlement.outbound.exceptions.DynamoDBConnectionException;
import app.settlement.outbound.exceptions.SettlementMessageParsingException;
import app.settlement.outbound.pojo.Settlement;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jms.core.JmsTemplate;
import org.springframework.stereotype.Service;

import javax.jms.TextMessage;
import java.text.SimpleDateFormat;
import java.util.*;

@Slf4j
@Service
public class SettlementService {
    SettlementDAO dao;
    AwsConfig awsConfig;
    OutboundQueue queue;

    private final static ObjectMapper JSON = new ObjectMapper();
    static {
        JSON.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
        JSON.registerModule(new JavaTimeModule());
    }

    public SettlementService(SettlementDAO dao, AwsConfig awsConfig, OutboundQueue outboundQueue){
        this.dao = dao;
        this.awsConfig = awsConfig;
        this.queue = outboundQueue;
    }


    public Settlement settlementFromBytes(byte[] bytes) throws SettlementMessageParsingException {
        try{
            // parse settlement
            Settlement settlement = JSON.readValue(bytes, Settlement.class);
            // then return new settlement from old with fields needed for storage + tracking
            return Settlement.builder()
                    .id(settlement.getId())
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
        }
        throw new SettlementMessageParsingException("Error parsing settlement message");
    }

    public void persistSettlements(List<Settlement> settlements) throws DynamoDBConnectionException {
        dao.save(settlements);
    }

    public void pushSettlementsToQueue(List<Settlement> settlements) {
        log.info("Sending " + settlements.size() + " settlements to queue");
        JmsTemplate jmsTemplate = queue.getTradesTemplate();
        // if we are sending a settlement we need to pass id as correlation ID to Trades
        settlements.forEach(s -> {
            jmsTemplate.send(session -> {
                TextMessage message = session.createTextMessage();
                try {
                    message.setText(JSON.writeValueAsString(s));
                } catch (JsonProcessingException e) {
//                        e.printStackTrace();
                    log.error("Error sending settlement message to Trades ", e);
                    return null;
                }
                message.setJMSCorrelationID(s.getId());
                return message;
            });
        });
    }
}
