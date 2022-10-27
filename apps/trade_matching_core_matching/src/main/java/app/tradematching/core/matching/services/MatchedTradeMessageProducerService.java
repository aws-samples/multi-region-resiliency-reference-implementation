// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.core.matching.services;

import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CompletableFuture;

import app.tradematching.core.matching.config.AwsProperties;
import app.tradematching.core.matching.exceptions.TradePersistException;
import app.tradematching.core.matching.pojo.TradeAllocation;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import org.apache.commons.lang3.RandomStringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.util.SerializationUtils;

import app.tradematching.core.matching.pojo.TradeMessage;
import lombok.extern.slf4j.Slf4j;
import software.amazon.awssdk.core.SdkBytes;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.kinesis.KinesisAsyncClient;
import software.amazon.awssdk.services.kinesis.model.PutRecordsRequest;
import software.amazon.awssdk.services.kinesis.model.PutRecordsRequestEntry;
import software.amazon.awssdk.services.kinesis.model.PutRecordsResponse;
import com.fasterxml.jackson.databind.ObjectMapper;

import javax.annotation.PostConstruct;

@Service
@Slf4j
public class MatchedTradeMessageProducerService {

	@Value("${EGRESS_KDS_NAME}")
	private String streamName = "egress_stream";

	private AwsProperties awsProperties;
	private KinesisAsyncClient client;
	private ObjectMapper objectMapper;

	public MatchedTradeMessageProducerService(AwsProperties awsProperties)
	{
		this.awsProperties = awsProperties;
		objectMapper = new ObjectMapper();
		objectMapper.registerModule(new JavaTimeModule());
	}

	@PostConstruct
	private void buildClient(){
		Region region = Region.of(this.awsProperties.getRegion());
		this.client = KinesisAsyncClient.builder().region(region).build();
	}

	public void produceTradeMessageToKinesis(List<TradeMessage> tradeMessages) throws TradePersistException {
		String test = "";
		List<PutRecordsRequestEntry> putRecordsRequestEntryList = new ArrayList<>();
		log.info("Received " + tradeMessages.size() + " Messages to process");
		try {
//			TradeMessage t = tradeMessages.get(0);
//			for (TradeAllocation ta : t.getAllocation())
//			{
//				ta.setTradeMessage(null);
//			}
//			test = objectMapper.writeValueAsString(t);
//			log.info(test);

			for (TradeMessage tm : tradeMessages) {
				log.info("Sending Pair");
				log.info(tm.getId());
				log.info(String.valueOf(tm.getAllocations().size()));
				for (TradeAllocation ta : tm.getAllocations())
				{
					ta.setTradeMessage(null);
				}
				var entry = PutRecordsRequestEntry.builder()
					.partitionKey(RandomStringUtils.randomAlphabetic(5, 20))
					.data(SdkBytes.fromByteArray(objectMapper.writeValueAsString(tm).getBytes()))
					.build();
				putRecordsRequestEntryList.add(entry);
			}
			log.info("Submitting " + putRecordsRequestEntryList.size() + " Messages to kinesis stream: " + streamName);
			PutRecordsRequest putRecordsRequest = PutRecordsRequest.builder()
					.streamName(streamName)
					.records(putRecordsRequestEntryList)
					.build();

			CompletableFuture<PutRecordsResponse> putRecordsResult = client.putRecords(putRecordsRequest);
			putRecordsResult.join();
			log.info("Put Result:::::" + putRecordsResult);
		} catch (JsonProcessingException e) {
			log.info("Error in produceTradeMessageToKinesis ", e);
			throw new TradePersistException("Can't Presist trade to Kinesis");
		}

	}

}
