// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.outbound.configs;

import lombok.Data;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Data
@ConfigurationProperties(prefix = "settlements")
@Configuration
public class SettlementsProperties {
    private String endpoint;
    private String username;
    private String password;
    private String queue;

    @Bean(name="SettlementsConfigs")
    SettlementsProperties getConfigs() { return new SettlementsProperties(); }
}
