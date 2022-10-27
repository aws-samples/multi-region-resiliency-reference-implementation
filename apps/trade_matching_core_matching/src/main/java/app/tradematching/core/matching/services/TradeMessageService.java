// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.core.matching.services;


import app.tradematching.core.matching.config.AwsConfig;
import app.tradematching.core.matching.exceptions.KinesisStreamException;
import app.tradematching.core.matching.exceptions.TradePersistException;
import app.tradematching.core.matching.jpa.TradeMessageRepository;
import app.tradematching.core.matching.pojo.TradeAllocation;
import app.tradematching.core.matching.pojo.TradeMessage;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.RandomStringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import software.amazon.awssdk.core.SdkBytes;
import software.amazon.awssdk.services.kinesis.KinesisAsyncClient;
import software.amazon.awssdk.services.kinesis.model.PutRecordsRequest;
import software.amazon.awssdk.services.kinesis.model.PutRecordsRequestEntry;
import software.amazon.awssdk.services.kinesis.model.PutRecordsResponse;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CompletableFuture;

@Service
@Slf4j
public class TradeMessageService {
	@Autowired
	private TradeMessageRepository repo;

	@Autowired
	private AwsConfig awsConfig;

	public void updateSettledTrade(String tradeId) throws KinesisStreamException, TradePersistException {
		// filter out trades where all allocations are not settled
		// update remaining trades status to settled
		// send list of settled trades to egress
		try {
			TradeMessage trade = repo.getTradeByUUID(tradeId);
			//update trade to settled if all allocation are settled
			if (trade==null) {
				return;
			}
			if (trade.getAllocations().stream().allMatch(ta -> ta.getStatus().equals("Settled"))){
				trade.setStatus("SETTLED");
				repo.save(trade);

				//send trade and associated settlements to egress stream
				pushSettledUpstream(trade);
			}
		} catch (KinesisStreamException e) {
			throw e;
		}
		catch (Exception e){
			log.error("Error settling trades: ", e);
			throw new TradePersistException("Error persisting trade status");
		}
	}

	public void pushSettledUpstream(TradeMessage tradeMessage) throws KinesisStreamException {
		String streamName = awsConfig.awsProperties.getTradeOutboundStreamName();

		KinesisAsyncClient client = awsConfig.getKinesisClient();
		ObjectMapper objectMapper = new ObjectMapper();
		objectMapper.registerModule(new JavaTimeModule());
		log.info("Pushing SETTLED trades to Outbound");
		List<PutRecordsRequestEntry> putRecordsRequestEntryList = new ArrayList<>();

		for (TradeAllocation ta : tradeMessage.getAllocations())
		{
			ta.setTradeMessage(null);
		}
		try {
			putRecordsRequestEntryList.add(
					PutRecordsRequestEntry.builder()
							.partitionKey(RandomStringUtils.randomAlphabetic(5, 20))
							.data(SdkBytes.fromByteArray(objectMapper.writeValueAsString(tradeMessage).getBytes()))
							.build()
			);
			PutRecordsRequest putRecordsRequest = PutRecordsRequest.builder()
					.streamName(streamName)
					.records(putRecordsRequestEntryList)
					.build();
			CompletableFuture<PutRecordsResponse> putRecordsResult = client.putRecords(putRecordsRequest);
			putRecordsResult.join();
			log.info("Put Result" + putRecordsResult);
		} catch (JsonProcessingException e) {
			log.error("", e);
		} catch (Exception e) {
			throw new KinesisStreamException("Error in pushSettledUpstream ");
		}
	}

	public boolean checkExistingTrade(String tradeUUID) {
		boolean result = false;
		TradeMessage trade = repo.getTradeByUUID(tradeUUID);
		if (trade != null)
			result=true;
		return result;
	}

	public TradeMessage getTradeByID(long id) {
		return repo.getTradeByDBID(id);
	}
}

