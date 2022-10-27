// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.generator.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Data
@ConfigurationProperties(prefix = "aws")
@Configuration
public class AwsProperties {
    private String region;
    private String rout53arcClusterArn;
    private String controlPanel;
    private String routingControl;
    private String destinationQueue;
    private String queueEndPoint;
    private String queueUsername;
    private String queuePassword;

    @Bean(name="AwsConfigs")
    AwsProperties getConfigs(){
        return new AwsProperties();
    }
}