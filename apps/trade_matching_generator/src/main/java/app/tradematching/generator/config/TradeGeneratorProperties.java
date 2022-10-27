// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.generator.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

import java.util.List;

@Data
@Configuration
@ConfigurationProperties(prefix = "trades-generator")
public class TradeGeneratorProperties {
    private int batchCount;
    private String outputDirectory;
    private boolean generateFiles;
    private boolean generateQueue;
    private int tradeQuantityMin;
    private int tradeQuantityMax;
    private double tradePriceMin;
    private double tradePriceMax;
    private int tradeAllocationsMin;
    private int tradeAllocationsMax;
    private List<String> brokerIds;
    private List<String> investmentManagerIds;
    private List<String> tradeIds;
}
