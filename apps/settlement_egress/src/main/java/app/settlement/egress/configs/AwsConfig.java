// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.settlement.egress.configs;

import app.settlement.egress.exceptions.DynamoDBConnectionException;
import app.settlement.egress.exceptions.KinesisStreamException;
import app.settlement.egress.pojo.NackMessage;
import app.settlement.egress.pojo.Settlement;
import app.settlement.egress.processor.RecordProcessorFactory;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.task.SimpleAsyncTaskExecutor;
import org.springframework.core.task.TaskExecutor;
import software.amazon.awssdk.core.client.config.ClientOverrideConfiguration;
import software.amazon.awssdk.enhanced.dynamodb.DynamoDbEnhancedClient;
import software.amazon.awssdk.enhanced.dynamodb.DynamoDbTable;
import software.amazon.awssdk.enhanced.dynamodb.TableSchema;
import software.amazon.awssdk.http.apache.ApacheHttpClient;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.cloudwatch.CloudWatchAsyncClient;
import software.amazon.awssdk.services.dynamodb.DynamoDbAsyncClient;
import software.amazon.awssdk.services.dynamodb.DynamoDbClient;
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
@Configuration
public class AwsConfig {
    public AwsProperties awsProperties;

    AwsConfig(AwsProperties awsProperties){
        this.awsProperties = awsProperties;
    }

    @Bean
    public DynamoDbEnhancedClient dynamoDbEnhancedClient(){
        return DynamoDbEnhancedClient.builder()
                .dynamoDbClient(this.getDynamoDbClient())
                .build();
    }

    @Bean
    public DynamoDbTable<NackMessage> getNackTable() throws DynamoDBConnectionException {
        DynamoDbTable<NackMessage> table;
        try {
            DynamoDbEnhancedClient ddbClient = DynamoDbEnhancedClient.builder()
                    .dynamoDbClient(this.getDynamoDbClient())
                    .build();

            table = ddbClient.table(awsProperties.getSafeStoreTable(), TableSchema.fromImmutableClass(NackMessage.class));
        } catch (Exception e) {
            log.error("Error Connecting to dynamoDB or getting Table", e);
            throw new DynamoDBConnectionException("Error Connecting to DynamoDB", e);
        }
        return table;
    }

    @Bean
    public DynamoDbTable<Settlement> getSettlementTable() throws DynamoDBConnectionException {
        DynamoDbTable<Settlement> table;
        try {
            DynamoDbEnhancedClient ddbClient = DynamoDbEnhancedClient.builder()
                    .dynamoDbClient(this.getDynamoDbClient())
                    .build();

            table = ddbClient.table(awsProperties.getSafeStoreTable(), TableSchema.fromClass(Settlement.class));
        } catch (Exception e) {
            log.error("Error Connecting to dynamoDB or getting Table", e);
            throw new DynamoDBConnectionException("Error Connecting to DynamoDB", e);
        }
        return table;
    }

    private DynamoDbClient getDynamoDbClient() {
        ClientOverrideConfiguration.Builder overrideConfig =
                ClientOverrideConfiguration.builder();

        return DynamoDbClient.builder()
                .overrideConfiguration(overrideConfig.build())
                .httpClient(ApacheHttpClient.create())
                .region(Region.of(awsProperties.getRegion()))
                .build();
    }

    @Bean
    public DynamoDbAsyncClient getDynamoDbAsyncClient() {
        return DynamoDbAsyncClient.builder().region(Region.of(awsProperties.getRegion())).build();
    }

    @Bean
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

    @Bean
    public TaskExecutor taskExecutor(){
        return new SimpleAsyncTaskExecutor();
    }

    @Bean
    public void kclScheduler() throws KinesisStreamException {
        Region region = Region.of(awsProperties.getRegion());
        String streamName = awsProperties.getInboundStreamName();
        RecordProcessorFactory recordProcessorFactory = new RecordProcessorFactory();

        ConfigsBuilder configsBuilder = getConfigBuilder(streamName, region, recordProcessorFactory);
        RetrievalConfig retrievalConfig = getRetrievalConfig(configsBuilder, streamName);

        /**
         * The Scheduler (also called Worker in earlier versions of the KCL) is the entry point to the KCL. This
         * instance is configured with defaults provided by the ConfigsBuilder.
         */
        Scheduler scheduler = new Scheduler(
                configsBuilder.checkpointConfig(),
                configsBuilder.coordinatorConfig(),
                configsBuilder.leaseManagementConfig(),
                configsBuilder.lifecycleConfig(),
                configsBuilder.metricsConfig(),
                configsBuilder.processorConfig(),
                retrievalConfig
        );

        /**
         * Kickoff the Scheduler. Record processing of the stream of dummy data will continue indefinitely
         * until an exit is triggered.
         */
        taskExecutor().execute(scheduler);
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
        RetrievalConfig retrievalConfig = null;
        InitialPositionInStreamExtended initialPositionInStreamExtended = InitialPositionInStreamExtended.newInitialPosition(InitialPositionInStream.TRIM_HORIZON);
        retrievalConfig = configsBuilder.retrievalConfig().retrievalSpecificConfig(new PollingConfig(streamName, configsBuilder.kinesisClient()));
        retrievalConfig.initialPositionInStreamExtended(initialPositionInStreamExtended);
        return retrievalConfig;
    }
}