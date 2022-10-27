// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.generator.generators;


import app.tradematching.generator.config.TradeGeneratorProperties;
import app.tradematching.generator.enums.TradePrice;
import app.tradematching.generator.enums.TradeSecurity;
import app.tradematching.generator.enums.TradeStatus;
import app.tradematching.generator.enums.TransactionIndicator;
import app.tradematching.generator.interfaces.IGenerator;
import app.tradematching.generator.pojo.Allocation;
import app.tradematching.generator.pojo.Trade;
import com.github.javafaker.Faker;
import lombok.extern.slf4j.Slf4j;

import java.lang.reflect.Field;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;
import java.util.concurrent.ThreadLocalRandom;

@Slf4j
public class TradeGenerator implements IGenerator {
    private TradeGeneratorProperties configProperties;

    public TradeGenerator(TradeGeneratorProperties configProperties)
    {
        this.configProperties=configProperties;
    }

    @Override
    public List<Trade> generate(int quantity) {
        List<Trade> trades = new ArrayList<Trade>();
        Random random = new Random();
        Faker faker = new Faker();
        for (long i=0;i<quantity;i++) {
            int scenario = random.nextInt(3);
            Trade trade = getRandomTrade();
            log.info("scenario" + scenario);
            if (scenario==0)
            {
                log.info("MATCHED Scenario");
                // MATCHED
                Trade copy = cloneTrade(trade);
                if (copy.getSenderID().equalsIgnoreCase(copy.getBrokerID()))
                    copy.setSenderID(copy.getImID());
                else
                    copy.setSenderID(copy.getBrokerID());
                trades.add(copy);
            }
            else if (scenario==1)
            {
                log.info("MISMATCHED Scenario");
                //MISMATCHED
                Trade copy = cloneTrade(trade);
                if (copy.getSenderID().equalsIgnoreCase(copy.getBrokerID()))
                    copy.setSenderID(copy.getImID());
                else
                    copy.setSenderID(copy.getBrokerID());
                // Change security price and quantity
                copy.setSecurity(TradeSecurity.values()[random.nextInt(TradeSecurity.values().length)].toString());
                copy.setPrice(TradePrice.values()[random.nextInt(TradePrice.values().length)].getNumVal());
                copy.setQuantity(generateRandomIntegerFromRange(
                        configProperties.getTradeQuantityMin(),
                        configProperties.getTradeQuantityMax()
                ));
                trades.add(copy);
            }
            else if (scenario==2){
                //UNMATCHED
                log.info("UNMATCHED Scenario");
                Trade copy = cloneTrade(trade);
                if (copy.getSenderID().equalsIgnoreCase(copy.getBrokerID()))
                    copy.setSenderID(copy.getImID());
                else
                    copy.setSenderID(copy.getBrokerID());
                // override trade ID
                copy.setTradeID(faker.number().digits(7));
                trades.add(copy);

            }
            trades.add(trade);

        }
        return trades;
    }

    public Trade cloneTrade(Trade trade) {
        Trade clone = new Trade();
        try{
            for (Field field : trade.getClass().getDeclaredFields()) {
                field.setAccessible(true);
                field.set(clone, field.get(trade));
            }
            return clone;
        }catch(Exception e){
            return null;
        }
    }

    public Trade getRandomTrade()
    {
        Faker faker = new Faker();
        Trade trade = new Trade();
        Random random = new Random();

//        trade.setSenderID(faker.lorem().fixedString(8).toUpperCase());
//        trade.setImID(faker.number().digits(10));
//        trade.setBrokerID(faker.number().digits(10));
//        trade.setTradeID(faker.number().digits(5));
//        trade.setSecurity(faker.lorem().fixedString(3).toUpperCase());

        //trade.setSenderID("QAINS012");
        trade.setImID(configProperties.getInvestmentManagerIds().get(random.nextInt(configProperties.getInvestmentManagerIds().size())));
        trade.setBrokerID(configProperties.getBrokerIds().get(random.nextInt(configProperties.getBrokerIds().size())));
//        trade.setTradeID(configProperties.getTradeIds().get(random.nextInt(configProperties.getTradeIds().size())));
        trade.setTradeID(faker.number().digits(7));

//        trade.setImID("QAINS012");
//        trade.setBrokerID("QABRO010");
//        trade.setTradeID("3500017");

        if (random.nextBoolean()) {
            trade.setSenderID(trade.getImID());
        }
        else
            trade.setSenderID(trade.getBrokerID());

        trade.setSecurity(TradeSecurity.values()[random.nextInt(TradeSecurity.values().length)].toString());

        trade.setTransactionIndicator(TransactionIndicator.values()[random.nextInt(TransactionIndicator.values().length)].toString());
//        trade.setPrice(generateRandomDecimalFromRange(
//                configProperties.getTradePriceMin(),
//                configProperties.getTradePriceMax()));

        trade.setPrice(TradePrice.values()[random.nextInt(TradePrice.values().length)].getNumVal());
        trade.setQuantity(generateRandomIntegerFromRange(
                configProperties.getTradeQuantityMin(),
                configProperties.getTradeQuantityMax()
        ));
        //trade.setTradeDate(betweenInstants(Instant.now().minus(Duration.ofDays(10)), Instant.now().minus(Duration.ofDays(2))));
        Instant instant
                = Instant.parse("2022-02-08T00:00:00.00Z");


        trade.setTradeDate(instant);
        trade.setSettlementDate(instant);
        trade.setDeliveryInstructions(faker.lorem().fixedString(15));
        //trade.setStatus(TradeStatus.values()[random.nextInt(TradeStatus.values().length)].toString());
        trade.setStatus(String.valueOf(TradeStatus.Unmatched));
        // generator allocations
        int allocation_count = random.nextInt(configProperties.getTradeAllocationsMax()) + configProperties.getTradeAllocationsMin();
        List<Allocation> allocations= new ArrayList<Allocation>();
        int total_percentage = 0;
        for (int i=0;i<allocation_count;i++) {
            Allocation allocation;
            int current_percentage= (int) 100 / allocation_count;
            if ((i+1) == allocation_count)
                allocation = getRandomAllocation(i+1, 100 - total_percentage);
            else
                allocation = getRandomAllocation(i+1, current_percentage);
            total_percentage+=current_percentage;
            allocations.add(allocation);
        }
        trade.setAllocations(allocations);
        return trade;
    }

    public static double generateRandomDecimalFromRange(double min, double max) {
        return (min + Math.random() * (max - min));
    }

    public static int generateRandomIntegerFromRange(int min, int max) {
        return (int) ((Math.random() * (max - min)) + min);
    }

    public static Instant betweenInstants(Instant startInclusive, Instant endExclusive) {
        long startSeconds = startInclusive.getEpochSecond();
        long endSeconds = endExclusive.getEpochSecond();
        long random = ThreadLocalRandom
                .current()
                .nextLong(startSeconds, endSeconds);

        return Instant.ofEpochSecond(random);
    }

    public static Allocation getRandomAllocation(int blockId, int percentage) {
        Allocation allocation = new Allocation();
        Faker faker = new Faker();
        allocation.setAccount(faker.number().digits(10));
        allocation.setQuantity(percentage);
        allocation.setStatus("Unmatched");
        allocation.setAllocationID(blockId);
        return allocation;
    }

}
