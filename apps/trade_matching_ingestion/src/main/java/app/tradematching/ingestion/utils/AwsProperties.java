// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.ingestion.utils;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Data
@ConfigurationProperties(prefix = "aws")
@Configuration
public class AwsProperties {
    private String region;
    private String stateTableName;
    private String settlementStateTableName;
    private String inboundStream;
    private String settlementInboundStream;
    private String outboundStream;
    private String settlementOutboundStream;
    private String nackStream;

    @Bean(name="AwsConfigs")
    AwsProperties getConfigs(){
        return new AwsProperties();
    }
}