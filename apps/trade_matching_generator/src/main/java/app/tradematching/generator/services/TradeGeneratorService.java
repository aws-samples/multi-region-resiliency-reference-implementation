// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.generator.services;

import app.tradematching.generator.config.AwsConfig;
import app.tradematching.generator.generators.TradeGenerator;
import app.tradematching.generator.pojo.Trade;
import lombok.extern.slf4j.Slf4j;

import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.util.List;

@Slf4j
public class TradeGeneratorService implements Runnable {
    TradeGenerator generator;
    AwsConfig config;
    JMSPublisher jmsPublisher;
    public boolean Generating = true;

    public TradeGeneratorService(AwsConfig config)
    {
        this.config = config;
        this.generator= new TradeGenerator(config.tradeGeneratorProperties);

    }

    @Override
    public void run() {
        while(Generating) {
            Generate();
        }
    }

    public void Generate() {
        log.info("Hello From Data Generator");
        try {
            List<Trade> trades = generator.generate(this.config.tradeGeneratorProperties.getBatchCount());
            log.info("Generated batch of " + this.config.tradeGeneratorProperties.getBatchCount() + " trades");
            if (this.config.tradeGeneratorProperties.isGenerateFiles()) {
                log.info("Generating trades files");
                String fileNameBase = "trade_";

                long index = 1;
                for (Trade t : trades) {
                    //log.info(t.toString());
                    String fileName = fileNameBase + String.valueOf(index) + ".json";
                    log.info("Writing file: " + fileName);
                    String filePath = this.config.tradeGeneratorProperties.getOutputDirectory() + File.separator + fileName;
                    File file = new File(filePath);
                    file.getParentFile().mkdirs();
                    PrintWriter out = new PrintWriter(new OutputStreamWriter(new FileOutputStream(this.config.tradeGeneratorProperties.getOutputDirectory() + File.separator + fileName), "UTF-8"));
                    out.println(t.toJson());
                    index++;
                    out.close();
                }
                log.info("Finished generating trades files.");
            }

            if (this.config.tradeGeneratorProperties.isGenerateQueue())
            {
                log.info("Distributing trades to Queue");
                this.jmsPublisher = new JMSPublisher(this.config.awsProperties.getQueueEndPoint(),
                        this.config.awsProperties.getQueueUsername(),
                        this.config.awsProperties.getQueuePassword(),
                        this.config.awsProperties.getDestinationQueue());
                jmsPublisher.SendMessages(trades);
                log.info("Finished Distributing trades to Queue");
            }
            Thread.sleep(5000); // sleep for 5 seconds
        }
        catch(Exception e) {
            log.error("Exception in Generate Trades" ,e);
        }
    }


}
