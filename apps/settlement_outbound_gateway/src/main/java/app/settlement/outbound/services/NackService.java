// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.settlement.outbound.services;

import app.settlement.outbound.configs.AwsConfig;
import app.settlement.outbound.configs.OutboundQueue;
import app.settlement.outbound.dao.NackMessageDAO;
import app.settlement.outbound.exceptions.DynamoDBConnectionException;
import app.settlement.outbound.pojo.NackMessage;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jms.core.JmsTemplate;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

@Slf4j
@Service
public class NackService {
    NackMessageDAO dao;
    private AwsConfig awsConfig;
    private OutboundQueue queue;

    private final static ObjectMapper JSON = new ObjectMapper();
    static {
        JSON.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
        JSON.registerModule(new JavaTimeModule());
    }

    public NackService(NackMessageDAO dao, AwsConfig awsConfig, OutboundQueue outboundQueue){
        this.dao = dao;
        this.awsConfig = awsConfig;
        this.queue = outboundQueue;
    }

    public NackMessage nackFromBytes(byte[] bytes) throws IOException {
        NackMessage nackMessage = JSON.readValue(bytes, NackMessage.class);
        return NackMessage.builder().id(nackMessage.getId()).message(nackMessage.getMessage())
                .status(nackMessage.getStatus()).destination(nackMessage.getDestination()).description(nackMessage.getDescription())
                .timestamp(nackMessage.getTimestamp())
                .currentDate(new SimpleDateFormat("yyyy-MM-dd").format(new Date()))
                .currentTime(new SimpleDateFormat("HH:mm:ss").format(new Date()))
                .build();
    }

    public void persistNacks(List<NackMessage> nacks) throws DynamoDBConnectionException {
        dao.save(nacks);
    }

    public void pushNacksToQueue(List<NackMessage> nacks){
        JmsTemplate jmsTemplate = queue.getSettlementsTemplate();
        // if we are sending a NACK we don't need to set a correlation ID
        nacks.forEach(s -> {
            try {
                jmsTemplate.convertAndSend(JSON.writeValueAsString(s));
            } catch (JsonProcessingException e) {
                log.error("Error sending settlement message to settlements out ", e);
            }
        });
    }
}
