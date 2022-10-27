// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.egress;

import app.tradematching.egress.configs.AwsProperties;
import app.tradematching.egress.exceptions.KinesisStreamException;
import app.tradematching.egress.services.KinesisStreamProcessor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.cloudwatch.CloudWatchAsyncClient;
import software.amazon.awssdk.services.dynamodb.DynamoDbAsyncClient;
import software.amazon.awssdk.services.kinesis.KinesisAsyncClient;
import software.amazon.kinesis.common.ConfigsBuilder;
import software.amazon.kinesis.common.InitialPositionInStream;
import software.amazon.kinesis.common.InitialPositionInStreamExtended;
import software.amazon.kinesis.coordinator.Scheduler;
import software.amazon.kinesis.processor.ShardRecordProcessor;
import software.amazon.kinesis.processor.ShardRecordProcessorFactory;
import software.amazon.kinesis.retrieval.RetrievalConfig;
import software.amazon.kinesis.retrieval.polling.PollingConfig;

import java.util.UUID;

@SpringBootApplication
@Slf4j
public class TradeMatchingEgressApplication implements CommandLineRunner {

	@Autowired
	private AwsProperties awsProperties;

	public static void main(String[] args) {
		SpringApplication.run(TradeMatchingEgressApplication.class, args);
	}

	@Override
	public void run(String... args) throws Exception {
		log.info("Egress App Starting...");
		log.info("Configurations load:");
		log.info(awsProperties.toString());

		Region region = Region.of(awsProperties.getRegion());
		String streamName = awsProperties.getInboundStreamName();

		ConfigsBuilder configsBuilder = getConfigBuilder(streamName, region, new KinesisStreamProcessorFactory());
		RetrievalConfig retrievalConfig = getRetrievalConfig(configsBuilder, streamName);

		Scheduler scheduler = new Scheduler(
				configsBuilder.checkpointConfig(),
				configsBuilder.coordinatorConfig(),
				configsBuilder.leaseManagementConfig(),
				configsBuilder.lifecycleConfig(),
				configsBuilder.metricsConfig(),
				configsBuilder.processorConfig(),
				retrievalConfig);
		Thread schedulerThread = new Thread(scheduler);
		schedulerThread.setDaemon(true);
		schedulerThread.start();
	}
	private class KinesisStreamProcessorFactory implements ShardRecordProcessorFactory {
		public ShardRecordProcessor shardRecordProcessor() {
			return new KinesisStreamProcessor();
		}
	}

	public KinesisAsyncClient getKinesisClient() throws KinesisStreamException {
		KinesisAsyncClient kinesisClient;
		try {
			kinesisClient = KinesisAsyncClient.builder()
					.region(Region.of(awsProperties.getRegion()))
					.build();
		} catch(Exception e)
		{
			log.error("Error Connecting to Kinesis", e);
			throw new KinesisStreamException("Error Connecting to Kinesis", e);
		}
		return kinesisClient;
	}

	public DynamoDbAsyncClient getDynamoDbAsyncClient() {
		return DynamoDbAsyncClient.builder().region(Region.of(awsProperties.getRegion())).build();
	}

	private ConfigsBuilder getConfigBuilder(String streamName, Region region, ShardRecordProcessorFactory factory){
		ConfigsBuilder configsBuilder = null;
		try {
			KinesisAsyncClient kinesisClient = getKinesisClient();
			DynamoDbAsyncClient dynamoClient = getDynamoDbAsyncClient();
			CloudWatchAsyncClient cloudWatchClient = CloudWatchAsyncClient.builder().region(region).build();
			configsBuilder = new ConfigsBuilder(streamName, streamName, kinesisClient, dynamoClient, cloudWatchClient, UUID.randomUUID().toString(), factory);
		} catch (KinesisStreamException ex) {
			log.error("Exception in RetrievalConfig" , ex);
		}
		return configsBuilder;
	}

	private RetrievalConfig getRetrievalConfig(ConfigsBuilder configsBuilder, String streamName){
		log.info("Using new Retrieval Config");
		RetrievalConfig retrievalConfig;
		InitialPositionInStreamExtended initialPositionInStreamExtended = InitialPositionInStreamExtended.newInitialPosition(InitialPositionInStream.TRIM_HORIZON);
		retrievalConfig = configsBuilder.retrievalConfig().retrievalSpecificConfig(new PollingConfig(streamName, configsBuilder.kinesisClient()));
		retrievalConfig.initialPositionInStreamExtended(initialPositionInStreamExtended);
		return retrievalConfig;
	}
}
