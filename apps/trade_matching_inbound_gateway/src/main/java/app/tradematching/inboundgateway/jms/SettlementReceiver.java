// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.inboundgateway.jms;

import app.tradematching.inboundgateway.exceptions.DynamoDBConnectionException;
import app.tradematching.inboundgateway.exceptions.KinesisStreamException;
import app.tradematching.inboundgateway.exceptions.SettlementMessageParsingException;
import app.tradematching.inboundgateway.pojo.RawMessage;
import app.tradematching.inboundgateway.pojo.Settlement;
import app.tradematching.inboundgateway.services.SettlementService;
import app.tradematching.inboundgateway.utils.AwsConfig;
import lombok.extern.slf4j.Slf4j;
import org.apache.activemq.command.ActiveMQTextMessage;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jms.annotation.JmsListener;
import org.springframework.jms.config.JmsListenerEndpointRegistry;
import org.springframework.stereotype.Component;
import software.amazon.awssdk.enhanced.dynamodb.DynamoDbTable;
import software.amazon.awssdk.services.kinesis.KinesisAsyncClient;

import javax.jms.JMSException;

@Slf4j
@Component
public class SettlementReceiver {
    @Autowired
    AwsConfig awsConfig;

    @Autowired
    JmsListenerEndpointRegistry jmsListenerEndpointRegistry;

    @Autowired
    SettlementService service;

    @JmsListener(destination = "${spring.jms.settlementQueue.name}", containerFactory = "jmsFactory")
    public void receiveMessage(ActiveMQTextMessage settlementMessage) throws DynamoDBConnectionException, KinesisStreamException {
        try
        {
            Settlement settlement = service.settlementFromBytes(settlementMessage.getText().getBytes());
            // Save the message to dynamoDB, first checkpoint
            service.persistSettlement(settlement);
            // acknowledge since message is persisted
            settlementMessage.acknowledge();
            // now send the message to kinesis
            service.pushUpstream(settlement);
        }
        catch (SettlementMessageParsingException e) {
            log.error("Unable to parse Settlement", e);
        }
        catch (DynamoDBConnectionException e) {
            log.error("Exception in receiveMessage, Error Connecting to dynamoDB", e);
            //Stop listening to Queue, can't relay message to dynamoDB
            jmsListenerEndpointRegistry.stop();
            throw e;
        }
        catch (KinesisStreamException e) {
            log.error("Exception in receiveMessage, Error connecting to Kinesis", e);
            // no need to throw since already persisting in DB
//             throw e;
        }
        catch (JMSException e) {
            e.printStackTrace();
        }
    }

}
