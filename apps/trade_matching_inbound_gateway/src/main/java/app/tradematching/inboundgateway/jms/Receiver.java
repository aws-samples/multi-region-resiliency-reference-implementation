// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.inboundgateway.jms;

import app.tradematching.inboundgateway.exceptions.DynamoDBConnectionException;
import app.tradematching.inboundgateway.exceptions.KinesisStreamException;
import app.tradematching.inboundgateway.utils.AwsConfig;
import lombok.extern.slf4j.Slf4j;
import org.apache.activemq.command.ActiveMQMapMessage;
import org.apache.activemq.command.ActiveMQTextMessage;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jms.annotation.JmsListener;
import org.springframework.jms.config.JmsListenerEndpointRegistry;
import org.springframework.stereotype.Component;

import app.tradematching.inboundgateway.pojo.RawMessage;
import software.amazon.awssdk.enhanced.dynamodb.DynamoDbTable;
import software.amazon.awssdk.services.kinesis.KinesisAsyncClient;

import javax.jms.JMSException;

@Slf4j
@Component
public class Receiver {
    @Autowired
    AwsConfig awsConfig;

    @Autowired
    JmsListenerEndpointRegistry jmsListenerEndpointRegistry;

    @JmsListener(destination = "${spring.jms.queue.name}", containerFactory = "jmsFactory")
    public void receiveMessage(ActiveMQTextMessage tradeMessage) throws DynamoDBConnectionException, KinesisStreamException {
//        log.info("Received trade message: " + tradeMessage);
        try
        {
            RawMessage message = RawMessage.givenMessage(tradeMessage.getText());
            message.setId(tradeMessage.getCorrelationId());
            // Save the message to dynamoDB, first checkpoint
            DynamoDbTable<RawMessage> ddbTable = awsConfig.getTradeTable();
            message.save(ddbTable);
            // acknowledge since message is persisted
            tradeMessage.acknowledge();

            // now send the message to kinesis
            KinesisAsyncClient kinesisAsyncClient = awsConfig.getKinesisClient();
            String kinesisName = awsConfig.awsProperties.getStreamName();
            message.pushUpstream(kinesisAsyncClient, kinesisName);

        } catch (DynamoDBConnectionException e) {
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