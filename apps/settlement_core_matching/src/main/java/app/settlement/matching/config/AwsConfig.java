// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

package app.settlement.matching.config;

import app.settlement.matching.app.MatchingAppState;
import app.settlement.matching.exceptions.KinesisStreamException;
import app.settlement.matching.interfaces.IStateAction;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import software.amazon.awssdk.core.client.config.ClientOverrideConfiguration;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.kinesis.KinesisAsyncClient;
import software.amazon.awssdk.services.route53recoverycontrolconfig.Route53RecoveryControlConfigClient;
import software.amazon.awssdk.http.apache.ApacheHttpClient;

@Slf4j
@Configuration
public class AwsConfig {
    public AwsProperties awsProperties;

    AwsConfig(AwsProperties awsProperties){
        this.awsProperties = awsProperties;
    }

    @Bean
    public IStateAction getAppState(){
        return new MatchingAppState();
    }

    @Bean
    public Route53RecoveryControlConfigClient getArcConfigClient() {
        ClientOverrideConfiguration.Builder overrideConfig =
                ClientOverrideConfiguration.builder();

        return Route53RecoveryControlConfigClient.builder()
                .overrideConfiguration(overrideConfig.build())
                .httpClient(ApacheHttpClient.create())
                .region(Region.AWS_GLOBAL)
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

}