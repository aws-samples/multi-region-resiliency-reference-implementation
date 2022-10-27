// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.settlement.matching.app;

import app.settlement.matching.SettlementMatchingApplication;
import app.settlement.matching.config.AwsProperties;
import app.settlement.matching.interfaces.IStateAction;
import app.settlement.matching.processor.KinesisStreamProcessor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.cloudwatch.CloudWatchAsyncClient;
import software.amazon.awssdk.services.dynamodb.DynamoDbAsyncClient;
import software.amazon.awssdk.services.kinesis.KinesisAsyncClient;
import software.amazon.kinesis.common.ConfigsBuilder;
import software.amazon.kinesis.common.InitialPositionInStream;
import software.amazon.kinesis.common.InitialPositionInStreamExtended;
import software.amazon.kinesis.common.KinesisClientUtil;
import software.amazon.kinesis.coordinator.Scheduler;
import software.amazon.kinesis.processor.ShardRecordProcessor;
import software.amazon.kinesis.processor.ShardRecordProcessorFactory;
import software.amazon.kinesis.retrieval.RetrievalConfig;
import software.amazon.kinesis.retrieval.polling.PollingConfig;

import java.util.UUID;

@Slf4j
public class MatchingAppState implements IStateAction {

    @Autowired
    public AwsProperties awsProperties;

    private static KinesisAsyncClient kinesisClient;
    private static Scheduler scheduler;
    private static Thread schedulerThread;


    @Override
    public void start() {
        String streamName = awsProperties.getInboundStream();
        Region region = Region.of(awsProperties.getRegion());

        ConfigsBuilder configsBuilder = getConfigBuilder(streamName, region, new KinesisStreamProcessorFactory());
        RetrievalConfig retrievalConfig = getRetrievalConfig(configsBuilder, streamName);

        kinesisClient = KinesisClientUtil.createKinesisAsyncClient(KinesisAsyncClient.builder().region(region));


        scheduler = new Scheduler(
                configsBuilder.checkpointConfig(),
                configsBuilder.coordinatorConfig(),
                configsBuilder.leaseManagementConfig(),
                configsBuilder.lifecycleConfig(),
                configsBuilder.metricsConfig(),
                configsBuilder.processorConfig(),
                retrievalConfig);
        schedulerThread = new Thread(scheduler);
        schedulerThread.setDaemon(true);
        schedulerThread.start();
    }

    @Override
    public void stop() {
        //stop the app
        //TODO: Implement safe shutdown if pending transaction are in process TBD

        schedulerThread.interrupt();
        scheduler.shutdown();
        //kinesisClient.
    }

    public class KinesisStreamProcessorFactory implements ShardRecordProcessorFactory {
        public ShardRecordProcessor shardRecordProcessor() {
            return new KinesisStreamProcessor();
        }
    }

    public DynamoDbAsyncClient getDynamoDbAsyncClient() {
        return DynamoDbAsyncClient.builder().region(Region.of(awsProperties.getRegion())).build();
    }

    public KinesisAsyncClient getKinesisClient() throws Exception {
        KinesisAsyncClient kinesisClient;
        try {
            kinesisClient = KinesisAsyncClient.builder()
                    .region(Region.of(awsProperties.getRegion()))
                    .build();
        } catch(Exception e)
        {
            log.error("Error Connecting to Kinesis", e);
            throw new Exception("Error Connecting to Kinesis", e);
        }
        return kinesisClient;
    }

    private ConfigsBuilder getConfigBuilder(String streamName, Region region, ShardRecordProcessorFactory factory){
        ConfigsBuilder configsBuilder = null;
        try {
            KinesisAsyncClient kinesisClient = getKinesisClient();
            DynamoDbAsyncClient dynamoClient = getDynamoDbAsyncClient();
            CloudWatchAsyncClient cloudWatchClient = CloudWatchAsyncClient.builder().region(region).build();
            configsBuilder = new ConfigsBuilder(streamName, streamName, kinesisClient, dynamoClient, cloudWatchClient, UUID.randomUUID().toString(), factory);
        } catch (Exception ex) {
            log.error("Exception in RetrievalConfig" , ex);
        }
        return configsBuilder;
    }

    private RetrievalConfig getRetrievalConfig(ConfigsBuilder configsBuilder, String streamName){
        log.info("Using new Retrieval Config");
        RetrievalConfig retrievalConfig = null;
        InitialPositionInStreamExtended initialPositionInStreamExtended = InitialPositionInStreamExtended.newInitialPosition(InitialPositionInStream.TRIM_HORIZON);
        retrievalConfig = configsBuilder.retrievalConfig().retrievalSpecificConfig(new PollingConfig(streamName, configsBuilder.kinesisClient()));
        retrievalConfig.initialPositionInStreamExtended(initialPositionInStreamExtended);
        return retrievalConfig;
    }
}
