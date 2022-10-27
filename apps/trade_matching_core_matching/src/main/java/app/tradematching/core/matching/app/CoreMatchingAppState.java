// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.core.matching.app;

import app.tradematching.core.matching.config.AwsConfig;
import app.tradematching.core.matching.config.AwsProperties;
import app.tradematching.core.matching.exceptions.KinesisStreamException;
import app.tradematching.core.matching.interfaces.IStateAction;
import app.tradematching.core.matching.kcl.KinesisStreamProcessorFactory;
import app.tradematching.core.matching.kcl.SettlementKinesisStreamProcessorFactory;
import lombok.extern.slf4j.Slf4j;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.cloudwatch.CloudWatchAsyncClient;
import software.amazon.awssdk.services.dynamodb.DynamoDbAsyncClient;
import software.amazon.awssdk.services.kinesis.KinesisAsyncClient;
import software.amazon.kinesis.common.ConfigsBuilder;
import software.amazon.kinesis.common.InitialPositionInStream;
import software.amazon.kinesis.common.InitialPositionInStreamExtended;
import software.amazon.kinesis.coordinator.Scheduler;
import software.amazon.kinesis.processor.ShardRecordProcessorFactory;
import software.amazon.kinesis.retrieval.RetrievalConfig;
import software.amazon.kinesis.retrieval.polling.PollingConfig;

import java.util.UUID;

@Slf4j
public class CoreMatchingAppState implements IStateAction {

    public AwsConfig awsConfig;

    public CoreMatchingAppState(AwsConfig config){
        this.awsConfig=config;
    }

    private static Scheduler tradesScheduler;
    private static Thread tradesSchedulerThread;
    private static Scheduler settlementsScheduler;
    private static Thread settlementsSchedulerThread;

    @Override
    public void start() {
        log.info("Starting CoreMatchingAppState");
        startTradesKinesis();
        startSettlementsKinesis();
        tradesSchedulerThread.start();
        settlementsSchedulerThread.start();
        log.info("Starting CoreMatchingAppState Finished.");
    }

    @Override
    public void stop() {
        tradesSchedulerThread.interrupt();
        tradesScheduler.shutdown();
        settlementsSchedulerThread.interrupt();
        settlementsScheduler.shutdown();
    }

    public void startTradesKinesis(){
        Region region = Region.of(awsConfig.awsProperties.getRegion());
        String tradesStreamName = awsConfig.awsProperties.getTradeInboundStreamName();
        log.info("Creating Kinesis client for stream: " + tradesStreamName);
        KinesisStreamProcessorFactory kinesisStreamFactory = new KinesisStreamProcessorFactory();
        ConfigsBuilder configsBuilder = getConfigBuilder(tradesStreamName, region, kinesisStreamFactory);
        RetrievalConfig retrievalConfig = getRetrievalConfig(configsBuilder, tradesStreamName);
        System.out.println("Custom retrievalConfig created");
        tradesScheduler = new Scheduler(
                configsBuilder.checkpointConfig(),
                configsBuilder.coordinatorConfig(),
                configsBuilder.leaseManagementConfig(),
                configsBuilder.lifecycleConfig(),
                configsBuilder.metricsConfig(),
                configsBuilder.processorConfig(),
                retrievalConfig);
        tradesSchedulerThread = new Thread(tradesScheduler);
        tradesSchedulerThread.setDaemon(true);
        log.info("Creating Kinesis client started for stream: " + tradesStreamName);
    }

    public void startSettlementsKinesis(){
        Region region = Region.of(awsConfig.awsProperties.getRegion());
        String settlementsStreamName = awsConfig.awsProperties.getSettlementInboundStreamName();
        log.info("Creating Kinesis client for stream: " + settlementsStreamName);

        SettlementKinesisStreamProcessorFactory kinesisSettlementStreamFactory = new SettlementKinesisStreamProcessorFactory();

        ConfigsBuilder configsBuilder = getConfigBuilder(settlementsStreamName, region, kinesisSettlementStreamFactory);
        RetrievalConfig retrievalConfig = getRetrievalConfig(configsBuilder, settlementsStreamName);

        settlementsScheduler = new Scheduler(
                configsBuilder.checkpointConfig(),
                configsBuilder.coordinatorConfig(),
                configsBuilder.leaseManagementConfig(),
                configsBuilder.lifecycleConfig(),
                configsBuilder.metricsConfig(),
                configsBuilder.processorConfig(),
                retrievalConfig);
        settlementsSchedulerThread = new Thread(settlementsScheduler);
        settlementsSchedulerThread.setDaemon(true);
        log.info("Creating Kinesis client started for stream: " + settlementsStreamName);
    }



    public DynamoDbAsyncClient getDynamoDbAsyncClient() {
        return DynamoDbAsyncClient.builder().region(Region.of(awsConfig.awsProperties.getRegion())).build();
    }

    private ConfigsBuilder getConfigBuilder(String streamName, Region region, ShardRecordProcessorFactory factory){
        ConfigsBuilder configsBuilder = null;
        try {
            KinesisAsyncClient kinesisClient = awsConfig.getKinesisClient();
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
