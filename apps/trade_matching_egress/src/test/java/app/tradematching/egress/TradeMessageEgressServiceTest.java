// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.egress;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import app.tradematching.egress.pojo.TradeAllocation;
import app.tradematching.egress.pojo.TradeMessage;
import app.tradematching.egress.services.TradeMatchingEgressService;

@SpringBootTest
public class TradeMessageEgressServiceTest {

    @Autowired
    private TradeMatchingEgressService service;

    @Test
    void testGenerateTradeMessageToKinesis() {
        ArrayList<TradeMessage> list = new ArrayList<>();
        for (int i = 0; i < 10; i++) {
            list.add(getSampleTradeMessage());
        }
        service.egressTradeMessages(list);

    }

    private TradeMessage getSampleTradeMessage() {
        TradeMessage tm = new TradeMessage();
        tm.setTradeUUID(UUID.randomUUID().toString());
//        tm.setTradeMesssageID("123123");
        tm.setSenderID("SENDER123");
        tm.setImID("IM123");
        tm.setBrokerID("BK123");
        tm.setTradeID("Tradeid");
        tm.setSecurity("AMZN");
        tm.setTransactionIndicator("B");
        tm.setPrice(123.21);
        tm.setQuantity(100);
        tm.setTradeDate(Instant.now());
        tm.setSettlementDate(Instant.now());
        tm.setDeliveryInstructions("hello");
        tm.setStatus("MATCHED");

        TradeAllocation taa = new TradeAllocation();
        taa.setTradeAllocationID(312312);
        // taa.setTradeMessage(tm);
        taa.setAllocationAccount("100");
        taa.setAllocationQuantity(10);
        taa.setAllocaitonStatus("HELLO");
        List<TradeAllocation> list = new ArrayList<TradeAllocation>();
        list.add(taa);
        tm.setAllocations(list);
        return tm;
    }

}
