// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.generator.app;

import app.tradematching.generator.config.AwsConfig;
import app.tradematching.generator.interfaces.IStateAction;
import app.tradematching.generator.services.TradeGeneratorService;
import org.springframework.beans.factory.annotation.Autowired;

public class TradesGeneratorAppState implements IStateAction {

    @Autowired
    public AwsConfig config;
    private static Thread thread;
    TradeGeneratorService service;

    @Override
    public void start() {
        service = new TradeGeneratorService(config);
        thread = new Thread(service);
        thread.setDaemon(true);
        thread.start();
    }

    @Override
    public void stop() {
        //stop the app
        service.Generating=false;
//        thread.interrupt();
//        thread.stop();
    }

}
