// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.generator.config;

import app.tradematching.generator.app.TradesGeneratorAppState;
import app.tradematching.generator.interfaces.IStateAction;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import software.amazon.awssdk.core.client.config.ClientOverrideConfiguration;
import software.amazon.awssdk.http.apache.ApacheHttpClient;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.route53recoverycontrolconfig.Route53RecoveryControlConfigClient;

@Slf4j
@Configuration
public class AwsConfig {
    @Autowired
    public AwsProperties awsProperties;

    @Autowired
    public TradeGeneratorProperties tradeGeneratorProperties;

    @Bean
    public IStateAction getAppState(){
        return new TradesGeneratorAppState();
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
}