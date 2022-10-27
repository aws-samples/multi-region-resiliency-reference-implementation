// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.core.matching;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import app.tradematching.core.matching.jpa.TradeMessageRepository;
import app.tradematching.core.matching.pojo.PairedTrade;
import app.tradematching.core.matching.pojo.TradeAllocation;
import app.tradematching.core.matching.pojo.TradeMessage;
import app.tradematching.core.matching.services.TradeMatchingService;

@SpringBootTest
class TradeMessageConversionTests {
	@Autowired
	private TradeMessageRepository tradeAllocationRepository;
	@Autowired
	private TradeMatchingService tradeMatchingService;

	List<TradeMessage> messages = new ArrayList<>();

	@BeforeEach
	void setUp() {
		TradeMessage message1 = tradeAllocationRepository.saveAndFlush(getSampleTradeMessage(1234));
		TradeMessage message2 = tradeAllocationRepository.saveAndFlush(getSampleTradeMessage(2345));
		messages.add(message1);
		messages.add(message2);
	}

	@Test
	void testTradeMatchingConversion() {
		PairedTrade trade = new PairedTrade();
		trade.setFirstID(messages.get(0).getId());
		trade.setSecondID(messages.get(1).getId());
		List<PairedTrade> tradeList = new ArrayList<>();
		tradeList.add(trade);
		List<TradeMessage> tradeMessages = tradeMatchingService.convertMatchedTradeToTradeMessage(tradeList);
		assertFalse(tradeMessages.isEmpty());
		assertEquals(2, tradeMessages.size());
		assertNotNull(tradeMessages.get(1));
		assertNotNull(tradeMessages.get(0));
	}
	@AfterEach
	void tearDown(){
		messages.forEach(e -> tradeAllocationRepository.delete(e));
	}

	TradeMessage getSampleTradeMessage(long tradeID) {
		TradeMessage ta = new TradeMessage();
		ta.setTradeMesssageID(tradeID);
		ta.setSenderID("SENDER123");
		ta.setImID("IM123");
		ta.setBrokerID("BK123");
		ta.setTradeID("Tradeid");
		ta.setSecurity("AMZN");
		ta.setTransactionIndicator("B");
		ta.setPrice(123.21);
		ta.setQuantity(100);
		ta.setTradeDate(Instant.now());
		ta.setSettlementDate(Instant.now());
		ta.setDeliveryInstructions("hello");
		ta.setStatus("UNMATCHED");

		TradeAllocation taa = new TradeAllocation();
		taa.setTradeAllocationID(123123);
		taa.setTradeMessage(ta);
		taa.setAllocationAccount("100");
		taa.setAllocationQuantity(10);
		taa.setAllocaitonStatus("HELLO");
		List<TradeAllocation> list = new ArrayList<TradeAllocation>();
		list.add(taa);

		ta.setAllocation(list);

		return ta;
	}
}
