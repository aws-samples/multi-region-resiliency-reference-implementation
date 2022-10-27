// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.settlement.inbound.processor;

import app.settlement.inbound.dao.RawMessageDAO;
import app.settlement.inbound.exceptions.DynamoDBConnectionException;
import app.settlement.inbound.exceptions.KinesisStreamException;
import app.settlement.inbound.pojo.RawMessage;
import app.settlement.inbound.service.RawMessageService;
import lombok.extern.slf4j.Slf4j;
import org.apache.activemq.command.ActiveMQTextMessage;
import org.springframework.jms.annotation.JmsListener;
import org.springframework.jms.config.JmsListenerEndpointRegistry;
import org.springframework.stereotype.Component;

import javax.jms.JMSException;

@Slf4j
@Component
public class Receiver {

    JmsListenerEndpointRegistry jmsListenerEndpointRegistry;
    RawMessageDAO dao;
    RawMessageService service;

    public Receiver(JmsListenerEndpointRegistry jmsListenerEndpointRegistry, RawMessageDAO rawMessageDAO, RawMessageService rawMessageService){
        this.jmsListenerEndpointRegistry = jmsListenerEndpointRegistry;
        this.dao = rawMessageDAO;
        this.service = rawMessageService;
    }

    @JmsListener(destination = "${spring.jms.queue.name}", containerFactory = "jmsFactory")
    public void receiveMessage(ActiveMQTextMessage settlementMessage) throws DynamoDBConnectionException, KinesisStreamException {
        String id;
        try
        {
            String correlationID = settlementMessage.getJMSCorrelationID();
            log.info("Received settlement ID: " + correlationID);
            // use ID passed from TM if it matches format
            if (correlationID.matches("[a-zA-Z0-9 ]+-[a-zA-Z0-9 ]+-[a-zA-Z0-9 ]+-[a-zA-Z0-9 ]+-\\d+")){
                id = correlationID;
            } else {
                // otherwise we generate an id TODO: determine if we are going to parse here
                id = java.util.UUID.randomUUID().toString();
            }
            RawMessage message = service.givenMessage(settlementMessage.getText(), id);
            // Save the message to dynamoDB, first checkpoint
            dao.save(message);
            // acknowledge since message is persisted
            settlementMessage.acknowledge();
            // now send the message to kinesis
            service.pushToIngestion(message);
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