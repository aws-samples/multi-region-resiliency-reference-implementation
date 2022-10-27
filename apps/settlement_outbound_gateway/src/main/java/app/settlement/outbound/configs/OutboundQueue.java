// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.settlement.outbound.configs;

import lombok.extern.slf4j.Slf4j;
import org.apache.activemq.ActiveMQConnectionFactory;
import org.apache.activemq.command.ActiveMQQueue;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.jms.connection.CachingConnectionFactory;
import org.springframework.jms.core.JmsTemplate;

@Slf4j
@Configuration
public class OutboundQueue {
    private AwsConfig awsConfig;

    OutboundQueue(AwsConfig awsConfig) {
        this.awsConfig = awsConfig;
    }

    @Bean
    public JmsTemplate getSettlementsTemplate(){
        return getJmsTemplate(true);
    }

    @Bean
    public JmsTemplate getTradesTemplate(){
        return getJmsTemplate(false);
    }

    private ActiveMQConnectionFactory createActiveMQConnectionFactory(boolean toSettlement) {

        final ActiveMQConnectionFactory connectionFactory =
                new ActiveMQConnectionFactory(
                        toSettlement ? awsConfig.settlementsProperties.getEndpoint() : awsConfig.tradesProperties.getEndpoint());

        connectionFactory.setUserName(
                toSettlement ? awsConfig.settlementsProperties.getUsername() : awsConfig.tradesProperties.getUsername());
        connectionFactory.setPassword(
                toSettlement ? awsConfig.settlementsProperties.getPassword() : awsConfig.tradesProperties.getPassword());
        return connectionFactory;
    }

    public CachingConnectionFactory cachingConnectionFactory(boolean toSettlement) {
        CachingConnectionFactory cachingConnectionFactory =
                new CachingConnectionFactory(createActiveMQConnectionFactory(toSettlement));
        cachingConnectionFactory.setSessionCacheSize(10);

        return cachingConnectionFactory;
    }

    public JmsTemplate getJmsTemplate(boolean toSettlement) {
        JmsTemplate jmsTemplate =
                new JmsTemplate(cachingConnectionFactory(toSettlement));
        String queue = toSettlement ? awsConfig.settlementsProperties.getQueue() : awsConfig.tradesProperties.getQueue();
        jmsTemplate.setDefaultDestination(new ActiveMQQueue(queue));
        jmsTemplate.setReceiveTimeout(5000);

        return jmsTemplate;
    }
}
