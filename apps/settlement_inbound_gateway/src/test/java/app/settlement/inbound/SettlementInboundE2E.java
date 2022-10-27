// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.settlement.inbound;

import org.apache.activemq.ActiveMQConnectionFactory;
import org.apache.activemq.command.ActiveMQQueue;
import org.junit.jupiter.api.Test;
import org.springframework.jms.connection.CachingConnectionFactory;
import org.springframework.jms.core.JmsTemplate;

import javax.jms.*;

public class SettlementInboundE2E {
    private String brokerUrl = "failover:ssl://b-011fb7ca-af6e-4ede-916c-143f6a744918-1.mq.us-east-1.amazonaws.com:61617,ssl://b-011fb7ca-af6e-4ede-916c-143f6a744918-2.mq.us-east-1.amazonaws.com:61617";

    private String userName = "mqadmin";

    private String password = "8FCLe2ukTnkr";

    private String orderDestination = "settlements";

    @Test
    void testGenerateSettlementMessages(){
        JmsTemplate jmsTemplate = getJmsTemplate();
        jmsTemplate.convertAndSend("this is a test");
    }


    public ActiveMQConnectionFactory senderConnectionFactory() {
        ActiveMQConnectionFactory activeMQConnectionFactory =
                new ActiveMQConnectionFactory(brokerUrl);
        activeMQConnectionFactory.setUserName(userName);
        activeMQConnectionFactory.setPassword(password);

        return activeMQConnectionFactory;
    }

    public CachingConnectionFactory cachingConnectionFactory() {
        CachingConnectionFactory cachingConnectionFactory =
                new CachingConnectionFactory(senderConnectionFactory());
        cachingConnectionFactory.setSessionCacheSize(10);

        return cachingConnectionFactory;
    }

    public Destination orderDestination() {
        return new ActiveMQQueue(orderDestination);
    }

    public JmsTemplate getJmsTemplate() {
        JmsTemplate jmsTemplate =
                new JmsTemplate(cachingConnectionFactory());
        jmsTemplate.setDefaultDestination(orderDestination());
        jmsTemplate.setReceiveTimeout(5000);

        return jmsTemplate;
    }
}
