// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.outbound.configs;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Data
@ConfigurationProperties(prefix = "aws")
@Configuration
public class AwsProperties {
    private String stateTableName;
    private String stateSettlementTableName;
    private String inboundStreamName;
    private String inboundSettlementStreamName;
    private String region;

    @Bean(name="AwsConfigs")
    AwsProperties getConfigs() { return new AwsProperties(); }
}
