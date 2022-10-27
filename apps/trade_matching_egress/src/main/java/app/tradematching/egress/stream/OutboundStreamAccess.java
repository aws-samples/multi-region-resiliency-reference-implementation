// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.egress.stream;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.concurrent.CompletableFuture;

import app.tradematching.egress.configs.AwsProperties;
import app.tradematching.egress.configs.OutputStreamType;
import app.tradematching.egress.pojo.SettlementMessage;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;

import org.apache.commons.lang3.RandomStringUtils;
import org.checkerframework.checker.units.qual.A;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import app.tradematching.egress.pojo.ResponseMessage;
import lombok.extern.slf4j.Slf4j;
import software.amazon.awssdk.core.SdkBytes;
import software.amazon.awssdk.services.kinesis.KinesisAsyncClient;
import software.amazon.awssdk.services.kinesis.model.PutRecordsRequest;
import software.amazon.awssdk.services.kinesis.model.PutRecordsRequestEntry;
import software.amazon.awssdk.services.kinesis.model.PutRecordsResponse;

@Component
@Slf4j
public class OutboundStreamAccess {

//	@Value("${OUTBOUND_KMS_NAME}")
//	private String streamName = "outbound_stream";

	@Autowired
	private AwsProperties awsProperties;

	private KinesisAsyncClient client = KinesisAsyncClient.builder().build();

	private ObjectMapper mapper = new ObjectMapper();

	public OutboundStreamAccess() {
		mapper.registerModule(new JavaTimeModule());
	}

	public void produceResponseMessageToOutboundKinesis(ResponseMessage responseMessage, OutputStreamType streamType) {
		
		produceToKinesis(Arrays.asList(responseMessage), streamType);

	}

	public void produceSettlementMessageToOutboundKinesis(List<SettlementMessage> settlementMessages, OutputStreamType streamType) {

		produceToKinesis(settlementMessages, streamType);

	}

	public void produceResponseMessageToOutboundKinesis(List<ResponseMessage> responseMessage, OutputStreamType streamType) {

		produceToKinesis(responseMessage, streamType);

	}

	private void produceToKinesis(List<?> messages, OutputStreamType streamType) {

		List<PutRecordsRequestEntry> putRecordsRequestEntryList = new ArrayList<>();
		messages.forEach(tm -> {
			try {
				putRecordsRequestEntryList.add(
						PutRecordsRequestEntry.builder()
								.partitionKey(RandomStringUtils.randomAlphabetic(5, 20))
								.data(SdkBytes.fromByteArray(mapper
										.writeValueAsString(tm).getBytes()))
								.build());
			} catch (JsonProcessingException e) {
				throw new RuntimeException(e);
			}
		});
		PutRecordsRequest putRecordsRequest = null;

		if (streamType.equals(OutputStreamType.Trades))
			putRecordsRequest = PutRecordsRequest.builder()
					.streamName(awsProperties.getOutboundStreamName())
					.records(putRecordsRequestEntryList)
					.build();

		if (streamType.equals(OutputStreamType.Settlements))
			putRecordsRequest = PutRecordsRequest.builder()
					.streamName(awsProperties.getOutboundSettlementStreamName())
					.records(putRecordsRequestEntryList)
					.build();

		CompletableFuture<PutRecordsResponse> putRecordsResult = client.putRecords(putRecordsRequest);
		putRecordsResult.join();
		log.info("Put Result" + putRecordsResult);
	}
}
