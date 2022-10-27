// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.outbound.stream;

import app.tradematching.outbound.configs.SettlementsProperties;
import app.tradematching.outbound.configs.TradesProperties;
import app.tradematching.outbound.pojo.ResponseMessage;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import lombok.extern.slf4j.Slf4j;
import org.apache.activemq.ActiveMQConnectionFactory;
import org.apache.activemq.command.ActiveMQQueue;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jms.connection.CachingConnectionFactory;
import org.springframework.jms.core.JmsTemplate;
import org.springframework.stereotype.Component;

import javax.annotation.PostConstruct;
import java.util.List;

@Slf4j
@Component
public class OutboundStream {

    private ObjectMapper objectMapper;

    private JmsTemplate tradesJmsTemplate;

    @Autowired
    private TradesProperties tradesProperties;

    @PostConstruct
    public void createTemplates(){
        objectMapper = new ObjectMapper();
        objectMapper.registerModule(new JavaTimeModule());
        this.tradesJmsTemplate = getJmsTemplate();
    }

    public void sendMessage(ResponseMessage message){
        JmsTemplate jmsTemplate = this.tradesJmsTemplate;
        try {
            jmsTemplate.convertAndSend(objectMapper.writeValueAsString(message));
        } catch (JsonProcessingException e) {
            log.error("Error sending Trade message", e);
        }

    }

    public void sendMessages(List<ResponseMessage> messages){
        JmsTemplate jmsTemplate = this.tradesJmsTemplate;
        log.info("Sending " + messages.size() + " Trade messages to queue");
        for (ResponseMessage rm: messages){
            try {
                jmsTemplate.convertAndSend(objectMapper.writeValueAsString(rm));
            } catch (JsonProcessingException e) {
                log.error("Error sending Trade message", e);
            }
        }
    }

    private ActiveMQConnectionFactory createActiveMQConnectionFactory() {

        final ActiveMQConnectionFactory connectionFactory =
                new ActiveMQConnectionFactory(tradesProperties.getEndpoint());

        connectionFactory.setUserName(tradesProperties.getUsername());
        connectionFactory.setPassword(tradesProperties.getPassword());
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
        jmsTemplate.setDefaultDestination(new ActiveMQQueue(tradesProperties.getQueue()));
        jmsTemplate.setReceiveTimeout(5000);

        return jmsTemplate;
    }
}
