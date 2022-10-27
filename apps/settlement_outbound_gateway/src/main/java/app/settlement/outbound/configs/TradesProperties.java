// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.settlement.outbound.configs;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Data
@ConfigurationProperties(prefix = "trades")
@Configuration
public class TradesProperties {
    private String endpoint;
    private String username;
    private String password;
    private String queue;

    @Bean(name="TradesConfigs")
    TradesProperties getConfigs() { return new TradesProperties(); }
}
