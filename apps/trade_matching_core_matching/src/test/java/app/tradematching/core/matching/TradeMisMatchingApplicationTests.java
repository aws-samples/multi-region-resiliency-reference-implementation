// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.core.matching;

import static org.junit.jupiter.api.Assertions.*;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import app.tradematching.core.matching.jpa.TradeMessageRepository;
import app.tradematching.core.matching.pojo.PairedTrade;
import app.tradematching.core.matching.pojo.TradeAllocation;
import app.tradematching.core.matching.pojo.TradeMessage;
import app.tradematching.core.matching.services.TradeMatchingService;

@SpringBootTest
class TradeMisMatchingApplicationTests {
	@Autowired
	private TradeMessageRepository tradeAllocationRepository;
	@Autowired
	private TradeMatchingService tradeMatchingService;

	List<TradeMessage> messages = new ArrayList<>();

	void setUpMatchedTrade() {
		TradeMessage message1 = tradeAllocationRepository.saveAndFlush(getSampleTradeMessage(1234, 3000.00, "AMZN", 10));
		TradeMessage message2 = tradeAllocationRepository.saveAndFlush(getSampleTradeMessage(2345, 3000.00, "AMZN", 10));
		messages.add(message1);
		messages.add(message2);
	}
	// @BeforeEach
	void setUpMisMatchedPrice() {
		TradeMessage message1 = tradeAllocationRepository.saveAndFlush(getSampleTradeMessage(1234, 3000.00, "AMZN", 10));
		TradeMessage message2 = tradeAllocationRepository.saveAndFlush(getSampleTradeMessage(2345, 4000.01, "AMZN", 10));
		messages.add(message1);
		messages.add(message2);
	}

	void setUpMisMatchedSecurity() {
		TradeMessage message1 = tradeAllocationRepository.saveAndFlush(getSampleTradeMessage(1234, 3000.00, "AMZN", 10));
		TradeMessage message2 = tradeAllocationRepository.saveAndFlush(getSampleTradeMessage(2345, 3000.00, "AAPL", 10));
		messages.add(message1);
		messages.add(message2);
	}

	void setUpMisMatchedQuantity() {
		TradeMessage message1 = tradeAllocationRepository.saveAndFlush(getSampleTradeMessage(1234, 3000.00, "AMZN", 11));
		TradeMessage message2 = tradeAllocationRepository.saveAndFlush(getSampleTradeMessage(2345, 3000.00, "AMZN", 10));
		messages.add(message1);
		messages.add(message2);
	}
	@Test
	void testTradeMisMatching() {
		setUpMatchedTrade();
		List<PairedTrade> matched = tradeMatchingService.tradeMisMatching();
		
		assertTrue(matched.isEmpty());
		tearDownMisMatched();
	}
	@Test
	void testTradeMisMatchingPrice() {
		setUpMisMatchedPrice();
		List<PairedTrade> matched = tradeMatchingService.tradeMisMatching();
		
		assertFalse(matched.isEmpty());
		matched.forEach(m -> {
			Optional<TradeMessage> first = tradeAllocationRepository.findById(m.getFirstID());
			assertEquals("MISMATCHED", first.get().getStatus());

			Optional<TradeMessage> second = tradeAllocationRepository.findById(m.getSecondID());
			assertEquals("MISMATCHED", second.get().getStatus());

		});
		tearDownMisMatched();
	}
	@Test
	void testTradeMisMatchingSecurity() {
		setUpMisMatchedSecurity();
		List<PairedTrade> matched = tradeMatchingService.tradeMisMatching();
		
		assertFalse(matched.isEmpty());
		matched.forEach(m -> {
			Optional<TradeMessage> first = tradeAllocationRepository.findById(m.getFirstID());
			assertEquals("MISMATCHED", first.get().getStatus());

			Optional<TradeMessage> second = tradeAllocationRepository.findById(m.getSecondID());
			assertEquals("MISMATCHED", second.get().getStatus());

		});
		tearDownMisMatched();
	}
	@Test
	void testTradeMisMatchingQuantity() {
		setUpMisMatchedQuantity();
		List<PairedTrade> matched = tradeMatchingService.tradeMisMatching();
		
		assertFalse(matched.isEmpty());
		matched.forEach(m -> {
			Optional<TradeMessage> first = tradeAllocationRepository.findById(m.getFirstID());
			assertEquals("MISMATCHED", first.get().getStatus());

			Optional<TradeMessage> second = tradeAllocationRepository.findById(m.getSecondID());
			assertEquals("MISMATCHED", second.get().getStatus());

		});
		tearDownMisMatched();
	}
	
	void tearDownMisMatched(){
		messages.forEach(e -> tradeAllocationRepository.delete(e));
		messages.clear();
	}

	TradeMessage getSampleTradeMessage(long tradeID, double price, String security, int quantity) {
		TradeMessage ta = new TradeMessage();
		ta.setTradeMesssageID(tradeID);
		ta.setSenderID("SENDER123");
		ta.setImID("IM123");
		ta.setBrokerID("BK123");
		ta.setTradeID("Tradeid");
		ta.setSecurity(security);
		ta.setTransactionIndicator("B");
		ta.setPrice(price);
		ta.setQuantity(quantity);
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
