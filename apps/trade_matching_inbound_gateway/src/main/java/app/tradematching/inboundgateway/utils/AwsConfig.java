// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.inboundgateway.utils;

import app.tradematching.inboundgateway.exceptions.DynamoDBConnectionException;
import app.tradematching.inboundgateway.exceptions.KinesisStreamException;
import app.tradematching.inboundgateway.pojo.RawMessage;
import app.tradematching.inboundgateway.pojo.Settlement;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import software.amazon.awssdk.core.client.config.ClientOverrideConfiguration;
import software.amazon.awssdk.enhanced.dynamodb.DynamoDbEnhancedClient;
import software.amazon.awssdk.enhanced.dynamodb.DynamoDbTable;
import software.amazon.awssdk.enhanced.dynamodb.TableSchema;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.dynamodb.DynamoDbClient;
import software.amazon.awssdk.services.kinesis.KinesisAsyncClient;
import software.amazon.awssdk.services.route53recoverycluster.Route53RecoveryClusterClient;
import software.amazon.awssdk.services.route53recoverycontrolconfig.Route53RecoveryControlConfigAsyncClient;
import software.amazon.awssdk.services.route53recoverycontrolconfig.Route53RecoveryControlConfigClient;

@Slf4j
@Configuration
public class AwsConfig {
    @Autowired
    public AwsProperties awsProperties;

    @Bean
    public DynamoDbTable<Settlement> getSettlementTable() throws DynamoDBConnectionException {
        DynamoDbTable<Settlement> table;
        try {
            DynamoDbEnhancedClient ddbClient = DynamoDbEnhancedClient.builder()
                    .dynamoDbClient(this.getDynamoDbClient())
                    .build();

            table = ddbClient.table(this.awsProperties.getStateSettlementTableName(),
                    TableSchema.fromImmutableClass(Settlement.class));
        } catch (Exception e) {
            log.error("Error Connecting to dynamoDB or getting Settlement", e);
            throw new DynamoDBConnectionException("Error Connecting to DynamoDB", e);
        }
        return table;
    }

    @Bean
    public DynamoDbTable<RawMessage> getTradeTable() throws DynamoDBConnectionException {
        DynamoDbTable<RawMessage> table;
        try {
            DynamoDbEnhancedClient ddbClient = DynamoDbEnhancedClient.builder()
                    .dynamoDbClient(this.getDynamoDbClient())
                    .build();

            table = ddbClient.table(this.awsProperties.getStateTableName(),
                    TableSchema.fromBean(RawMessage.class));
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
                .region(Region.of(awsProperties.getRegion()))
                .build();
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
    public Route53RecoveryControlConfigClient getArcConfigClient() {
        return Route53RecoveryControlConfigClient.builder()
                .region(Region.AWS_GLOBAL).build();
    }
}