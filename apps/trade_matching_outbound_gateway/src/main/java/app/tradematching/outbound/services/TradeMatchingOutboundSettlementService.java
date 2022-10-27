// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.outbound.services;

import app.tradematching.outbound.dao.TradeMatchingOutboundDAO;
import app.tradematching.outbound.pojo.ResponseMessage;
import app.tradematching.outbound.pojo.SafeStoreResponseMessage;
import app.tradematching.outbound.pojo.SettlementMessage;
import app.tradematching.outbound.stream.OutboundSettlementStream;
import app.tradematching.outbound.stream.OutboundStream;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

@Service
@Slf4j
public class TradeMatchingOutboundSettlementService {

	@Autowired
	private TradeMatchingOutboundDAO dao;

	@Autowired
	private OutboundSettlementStream outboundStream;

	private ObjectMapper mapper = new ObjectMapper();

	public TradeMatchingOutboundSettlementService() {
		mapper.registerModule(new JavaTimeModule());
	}

	public SettlementMessage settlementMessageFromBytesString(String bytes) throws JsonProcessingException {
		SettlementMessage sm = mapper.readValue(bytes, SettlementMessage.class);
		return SettlementMessage.builder()
				.id(sm.getId())
				.senderID(sm.getSenderID())
				.imID(sm.getImID()).brokerID(sm.getBrokerID()).tradeID(sm.getTradeID())
				.allocationID(sm.getAllocationID()).quantity(sm.getQuantity())
				.security(sm.getSecurity()).transactionIndicator(sm.getTransactionIndicator())
				.price(sm.getPrice())
				.tradeDate(sm.getTradeDate())
				.settlementDate(sm.getSettlementDate())
				.deliveryInstructions(sm.getDeliveryInstructions())
				.status(sm.getStatus()).account(sm.getAccount())
				.timestamp(sm.getTimestamp())
				.currentDate(new SimpleDateFormat("yyyy-MM-dd").format(new Date()))
				.currentTime(new SimpleDateFormat("HH:mm:ss").format(new Date()))
				.build();
	}

	public void processOutboundSettlementMessages(List<SettlementMessage> settlementMessages) {
		dao.persistSettlementMessage(settlementMessages);
		outboundStream.sendMessages(settlementMessages);
//		for (SettlementMessage message : settlementMessages){
//			try {
//				SettlementMessage settlementMessage = safeStoreSettlementMessageFromMessage(message);
//				dao.persistSettlementMessage(settlementMessage);
////				outboundStream.sendMessage(message);
//			} catch (Exception e){
//				log.error("Error processing outbound message", e);
//			}
//		}
	}
}