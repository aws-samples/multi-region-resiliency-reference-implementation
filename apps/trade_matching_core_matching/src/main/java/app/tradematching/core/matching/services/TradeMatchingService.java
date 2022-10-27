// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.core.matching.services;

import app.tradematching.core.matching.data.TradeAllocationDAO;
import app.tradematching.core.matching.exceptions.TradePersistException;
import app.tradematching.core.matching.jpa.TradeMessageRepository;
import app.tradematching.core.matching.pojo.LookupTrade;
import app.tradematching.core.matching.pojo.TradeMessage;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Slf4j
@Service
public class TradeMatchingService {

	@Autowired
	private TradeAllocationDAO dao;

	@Autowired
	private TradeMessageRepository repo;

	public LookupTrade tradeMatching(TradeMessage message) {
		return dao.doMatching(message);
	}

	public boolean persistSingleTrade(TradeMessage message) throws TradePersistException{
		try {
			TradeMessage result = repo.save(message);
		} catch (Exception e) {
			throw new TradePersistException("Error persisting trade to SQL DB trade:" + message.getId());
		}
		return true;
	}

	public LookupTrade tradeMisMatching(TradeMessage message) {
		return dao.doMisMatching(message);
	}

//	public List<TradeMessage> convertMatchedTradeToTradeMessage(List<LookupTrade> matchedTrade){
//		log.info("Before Conversion: " + matchedTrade.size());
//		List<TradeMessage> result = new ArrayList<>();
//		Hashtable<String, Long> matchedIds = new Hashtable<>();
//		for (PairedTrade pt : matchedTrade)
//		{
//			if (!matchedIds.containsKey(pt.getFirstID()))
//				matchedIds.put(String.valueOf(pt.getFirstID()), pt.getFirstID());
//			if (!matchedIds.containsKey(pt.getSecondID()))
//				matchedIds.put(String.valueOf(pt.getSecondID()), pt.getSecondID());
//		}
////		log.info("Middle Conversion: " + matchedIds.keySet().size());
//		Long matchedTradeId = null;
//		for (String key : matchedIds.keySet()) {
//			matchedTradeId = matchedIds.get(key);
//			Optional<TradeMessage> trade = repo.findById(matchedTradeId);
//			if (trade.isPresent())
//				result.add(trade.get());
//		}
//		log.info("After Conversion: " + result.size());
//		return result;
//	}

}
