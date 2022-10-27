// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.generator.services;

import app.tradematching.generator.config.TradeGeneratorProperties;
import app.tradematching.generator.pojo.Trade;
import lombok.extern.slf4j.Slf4j;
import org.apache.activemq.ActiveMQConnectionFactory;
import org.apache.activemq.command.ActiveMQQueue;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jms.connection.CachingConnectionFactory;
import org.springframework.jms.core.JmsTemplate;
import org.springframework.stereotype.Component;

import javax.jms.TextMessage;
import java.util.List;

@Slf4j
public class JMSPublisher {
    private TradeGeneratorProperties configProperties;
    private JmsTemplate jmsTemplate;

    private String WIRE_LEVEL_ENDPOINT;
    private String ACTIVE_MQ_USERNAME;
    private String ACTIVE_MQ_PASSWORD;
    private String ACTIVE_MQ_QUEUE;

    public JMSPublisher(String amqEndPoint, String amqUsername, String amqPassword, String amqQueueName) {
        this.WIRE_LEVEL_ENDPOINT=amqEndPoint;
        this.ACTIVE_MQ_USERNAME=amqUsername;
        this.ACTIVE_MQ_PASSWORD=amqPassword;
        this.ACTIVE_MQ_QUEUE=amqQueueName;
        this.jmsTemplate = getJmsTemplate();
    }

    public void SendMessages(List<Trade> trades) {
        // for bad message testing
//        this.jmsTemplate.send(new MessageCreator() {
//            @Override
//            public Message createMessage(Session session) throws JMSException {
//                return session.createTextMessage("bad message");
//            }
//        });
        int index=1;

        for (Trade t : trades) {
            this.jmsTemplate.send(session -> {
                TextMessage message = session.createTextMessage();
                message.setText(t.toJson());
                String id = t.getSenderID() +"-" + t.getImID() + "-" + t.getBrokerID() + "-" + t.getTradeID();
                message.setJMSCorrelationID(id);
                return message;
            });

            index++;
            if (index%10==0)
                log.info("Pushed " + index + " Messages.");

        }
    }

    private ActiveMQConnectionFactory createActiveMQConnectionFactory() {
        final ActiveMQConnectionFactory connectionFactory =
                new ActiveMQConnectionFactory(WIRE_LEVEL_ENDPOINT);

        connectionFactory.setUserName(ACTIVE_MQ_USERNAME);
        connectionFactory.setPassword(ACTIVE_MQ_PASSWORD);
        return connectionFactory;
    }

    public CachingConnectionFactory cachingConnectionFactory() {
        CachingConnectionFactory cachingConnectionFactory =
                new CachingConnectionFactory(createActiveMQConnectionFactory());
        cachingConnectionFactory.setSessionCacheSize(10);

        return cachingConnectionFactory;
    }

    public JmsTemplate getJmsTemplate() {
        JmsTemplate jmsTemplate =
                new JmsTemplate(cachingConnectionFactory());
        jmsTemplate.setDefaultDestination(new ActiveMQQueue(ACTIVE_MQ_QUEUE));
        jmsTemplate.setReceiveTimeout(5000);

        return jmsTemplate;
    }


}
