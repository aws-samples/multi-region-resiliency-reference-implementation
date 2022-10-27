// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.egress.util;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.UUID;

import app.tradematching.egress.pojo.*;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;

public class MessageConversionUtil {
	private static final ObjectMapper mapper = new ObjectMapper();

	static {
		mapper.registerModule(new JavaTimeModule());
	}

	public static EgressStoreRecord convertTradeMessageToEgressStoreRecord(TradeMessage tm) throws JsonProcessingException {
		return EgressStoreRecord.builder().id(tm.getTradeUUID())
				.timestamp(tm.getTimestamp())
//				.timestamp(System.currentTimeMillis())
				.status(tm.getStatus()).description("description").tradeMessage(mapper.writeValueAsString(tm))
				// Generating Date Time dynamically to align with timestamp
//				.currentDate(tm.getCurrentDate()).currentTime(tm.getCurrentTime())
				.currentDate(new SimpleDateFormat("yyyy-MM-dd").format(new Date()))
				.currentTime(new SimpleDateFormat("HH:mm:ss").format(new Date()))
				.build();
	}

	public static EgressStoreRecord convertResponseMessageToEgressStoreRecord(ResponseMessage rm) throws JsonProcessingException {
		return EgressStoreRecord.builder().id(rm.getId())
//				.timestamp(System.currentTimeMillis())
				.timestamp(rm.getTimestamp())
				.status(rm.getStatus()).description(rm.getDescription()).tradeMessage(mapper.writeValueAsString(rm))
				// Generating Date Time dynamically to align with timestamp
//				.currentDate(tm.getCurrentDate()).currentTime(tm.getCurrentTime())
				.currentDate(new SimpleDateFormat("yyyy-MM-dd").format(new Date()))
				.currentTime(new SimpleDateFormat("HH:mm:ss").format(new Date()))
				.build();
	}

	public static EgressSettlementStoreRecord convertSettlementMessageToEgressSettlementStoreRecord(SettlementMessage sm) throws JsonProcessingException {
		return EgressSettlementStoreRecord.builder().id(sm.getId())
				.timestamp(sm.getTimestamp())
//				.timestamp(System.currentTimeMillis())
				.status(sm.getStatus()).description("description").settlementMessage(mapper.writeValueAsString(sm))
				// Generating Date Time dynamically to align with timestamp
//				.currentDate(sm.getCurrentDate()).currentTime(sm.getCurrentTime())
				.currentDate(new SimpleDateFormat("yyyy-MM-dd").format(new Date()))
				.currentTime(new SimpleDateFormat("HH:mm:ss").format(new Date()))
				.build();
	}

	public static List<SettlementMessage> convertTradeMessageToSettlement(TradeMessage tm) {
		List<SettlementMessage> result = new ArrayList<>();
		for (TradeAllocation ta : tm.getAllocations())
		{
			String senderId = tm.getSenderID();
			String imId = tm.getImID();
			String brokerId = tm.getBrokerID();
			String tradeId = tm.getTradeID();
			long allocationId = ta.getAllocationID();
			String settlementId = String.format("%s-%s-%s-%s-%d", senderId, imId, brokerId, tradeId, allocationId);
			SettlementMessage.SettlementMessageBuilder message = SettlementMessage.builder()
					.id(settlementId)
					.senderID(senderId)
					.imID(imId).brokerID(brokerId).tradeID(tradeId)
					.allocationID(allocationId).quantity(ta.getQuantity())
					.security(tm.getSecurity()).transactionIndicator(tm.getTransactionIndicator())
					.price(tm.getPrice())
					.tradeDate(tm.getTradeDate())
					.settlementDate(tm.getSettlementDate())
					.deliveryInstructions(tm.getDeliveryInstructions())
					.status(ta.getStatus()).account(ta.getAccount())
					.timestamp(tm.getTimestamp())
					.currentDate(new SimpleDateFormat("yyyy-MM-dd").format(new Date()))
					.currentTime(new SimpleDateFormat("HH:mm:ss").format(new Date()));
			result.add(message.build());
		}

		return result;
	}
	public static ResponseMessage convertSettlementMessagesToResponse(SettlementMessage sm) throws JsonProcessingException {
		return ResponseMessage.builder().id(sm.getId()).status("MATCHED").description("MATCHED TRADES")
				.destination("SETTLEMENT").timestamp(sm.getTimestamp()).message(mapper.writeValueAsString(sm)).build();
	}
	public static ResponseMessage convertTradeMessageToResponse(TradeMessage tm) throws JsonProcessingException {
		return ResponseMessage.builder().id(tm.getTradeUUID()).status(tm.getStatus()).description("description")
				.destination("destination").timestamp(tm.getTimestamp()).message(mapper.writeValueAsString(tm)).build();
	}
}
