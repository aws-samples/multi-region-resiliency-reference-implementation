// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.outbound.stream;

import app.tradematching.outbound.configs.SettlementsProperties;
import app.tradematching.outbound.configs.TradesProperties;
import app.tradematching.outbound.pojo.ResponseMessage;
import app.tradematching.outbound.pojo.SettlementMessage;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import lombok.extern.slf4j.Slf4j;
import org.apache.activemq.ActiveMQConnectionFactory;
import org.apache.activemq.command.ActiveMQQueue;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jms.connection.CachingConnectionFactory;
import org.springframework.jms.core.JmsTemplate;
import org.springframework.jms.core.MessageCreator;
import org.springframework.stereotype.Component;

import javax.annotation.PostConstruct;
import javax.jms.JMSException;
import javax.jms.Message;
import javax.jms.Session;
import javax.jms.TextMessage;
import java.util.List;

@Slf4j
@Component
public class OutboundSettlementStream {

    private ObjectMapper objectMapper;

    private JmsTemplate settlementsJmsTemplate;

    @Autowired
    private SettlementsProperties settlementsProperties;

    @PostConstruct
    public void createTemplates(){
        objectMapper = new ObjectMapper();
        objectMapper.registerModule(new JavaTimeModule());
        this.settlementsJmsTemplate = getJmsTemplate();
    }

    public void sendMessages(List<SettlementMessage> messages){
        JmsTemplate jmsTemplate = this.settlementsJmsTemplate;
        log.info("Sending " +  messages.size() + " Settlements messages to Settlement platform");
        for(SettlementMessage sm : messages){
            jmsTemplate.send(session -> {
                TextMessage message = session.createTextMessage();
                try {
                    message.setText(objectMapper.writeValueAsString(sm));
                } catch (JsonProcessingException e) {
//                        e.printStackTrace();
                    log.error("Error sending settlement message ", e);
                    return null;
                }
                message.setJMSCorrelationID(sm.getId());
                return message;
            });
//            try {
//                jmsTemplate.convertAndSend(objectMapper.writeValueAsString(message));
//            } catch (JsonProcessingException e) {
//                log.error("Error sending Settlement message", e);
//            }
        }
    }

    private ActiveMQConnectionFactory createActiveMQConnectionFactory() {

        final ActiveMQConnectionFactory connectionFactory =
                new ActiveMQConnectionFactory(settlementsProperties.getEndpoint());

        connectionFactory.setUserName(settlementsProperties.getUsername());
        connectionFactory.setPassword(settlementsProperties.getPassword());
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
        jmsTemplate.setDefaultDestination(new ActiveMQQueue(settlementsProperties.getQueue()));
        jmsTemplate.setReceiveTimeout(5000);

        return jmsTemplate;
    }
}
