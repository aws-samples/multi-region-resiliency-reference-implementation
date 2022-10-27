// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.egress.services;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.List;
import java.util.stream.Collectors;

import app.tradematching.egress.configs.OutputStreamType;
import app.tradematching.egress.pojo.*;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import app.tradematching.egress.dao.TradeMatchingEgressDAO;
import app.tradematching.egress.stream.OutboundStreamAccess;
import app.tradematching.egress.util.MessageConversionUtil;
import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
public class TradeMatchingEgressService {

	@Autowired
	private TradeMatchingEgressDAO dao;
	@Autowired
	private OutboundStreamAccess outboundStreamAccess;

	private ObjectMapper mapper = new ObjectMapper();

	public TradeMatchingEgressService() {
		mapper.registerModule(new JavaTimeModule());
	}

	public void egressNackMessages(List<ResponseMessage> rmList) {
		log.info("Saving Egress " + rmList.size() + " Nack Messages ");
		if(rmList.size() > 0 && !persistNackToSafeStore(rmList)){
			log.error("Could not persist NACK messages!");
			return;
		}
		log.info("Finished Saving Egress " + rmList.size() + " Nack Messages ");
		// send trades to streams
		sendResponseToOutboundKinesis(rmList);
	}

	public void egressTradeMessages(List<TradeMessage> tmList) {
		// persist to dynamo
//		log.info("Egress Trades " + Arrays.toString(tmList.toArray()));
		log.info("Saving Egress " + tmList.size() + " Trades ");
		if (tmList.size()>0 && !persistToSafeStore(tmList)){
			log.error("Could not persist trade messages!");
			return;
		}
		log.info("Finished Saving Egress " + tmList.size() + " Trades ");
//		List<TradeMessage> matched = new ArrayList<>();
//		List<TradeMessage> misMatched = new ArrayList<>();
//		List<TradeMessage> nack = new ArrayList<>();

		List<TradeMessage> matched = tmList.stream()
				.filter(tm -> tm.getStatus().equalsIgnoreCase("MATCHED"))
				.collect(Collectors.toList());
		log.info("Found " + matched.size() + " Matched Trades");
//		for (TradeMessage t : tmList)
//			if (t.getStatus().equalsIgnoreCase("MATCHED"))
//				matched.add(t);
//			else if (t.getStatus().equalsIgnoreCase("MISMATCHED"))
//				misMatched.add(t);
//			// Does NACK ever come from TM Core? Do we need to check this here?
//			else if (t.getStatus().equalsIgnoreCase("NACK"))
//				nack.add(t);
//			else
//				log.error("should fall in one of the category");
		// convert and persist settlement

		List<SettlementMessage> matchedSettlements = new ArrayList<>();

		for (TradeMessage t : matched) {
			log.info("Processing Matched Trade settlements " + t.getId());
			matchedSettlements.addAll(MessageConversionUtil.convertTradeMessageToSettlement(t));
		}
		log.info("Saving Egress " + matchedSettlements.size() + " Settlements ");
		if (matchedSettlements.size()>0){
			persistSettlementToSafeStore(matchedSettlements);
//			log.error("Could not save Settlement  messages!!");
//			return;
		}
//		log.info("Saving Egress " + matchedSettlements.size() + " Settlements ");

// TODO:
//		if (misMatched.size()>0)
//
//		if (nack.size()>0)


		// send settlement messages to streams
		if (matched.size()>0)
			sendSettlementMessagesKinesis(matchedSettlements);

		// send trades to streams
		sendResponseToOutboundKinesis(tmList.stream()
				.map(tm -> {
					try {
						return MessageConversionUtil.convertTradeMessageToResponse(tm);
					} catch (JsonProcessingException e) {
						log.error("JSON processing error: ", e);
						return null;
					}
				})
				.filter(x -> x != null)
				.collect(Collectors.toList()));
	}


	private boolean persistToSafeStore(List<TradeMessage> tmList) {
		List<EgressStoreRecord> egressStoreRecords = new ArrayList<>();

		for (TradeMessage tm : tmList) {
			try {
				egressStoreRecords.add(MessageConversionUtil.convertTradeMessageToEgressStoreRecord(tm));
			} catch (JsonProcessingException e) {
				log.error("JSON processing error: ", e);
				return false;
			}
		}
		dao.persistTrades(egressStoreRecords);
		return true;
	}

	private boolean persistNackToSafeStore(List<ResponseMessage> rmList) {
		List<EgressStoreRecord> egressStoreRecords = new ArrayList<>();

		for (ResponseMessage rm : rmList) {
			try {
				egressStoreRecords.add(MessageConversionUtil.convertResponseMessageToEgressStoreRecord(rm));
			} catch (JsonProcessingException e) {
				log.error("JSON processing error: ", e);
				return false;
			}
		}
		dao.persistTrades(egressStoreRecords);
		return true;
	}

	private void persistSettlementToSafeStore(List<SettlementMessage> smList) {
		dao.persistSettlements(smList);
	}

	private void sendSettlementMessagesKinesis(List<SettlementMessage> smList) {
		outboundStreamAccess.produceSettlementMessageToOutboundKinesis(smList, OutputStreamType.Settlements);
	}

	private void sendResponseToOutboundKinesis(List<ResponseMessage> responses) {
		// send ACK to client
		outboundStreamAccess.produceResponseMessageToOutboundKinesis(responses, OutputStreamType.Trades);
	}

}