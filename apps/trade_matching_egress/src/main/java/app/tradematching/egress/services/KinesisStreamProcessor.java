// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.egress.services;


import java.util.ArrayList;
import java.util.List;

import app.tradematching.egress.pojo.ResponseMessage;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.DatabindException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;

import app.tradematching.egress.StaticApplicationContext;
import app.tradematching.egress.pojo.TradeMessage;
import software.amazon.kinesis.exceptions.InvalidStateException;
import software.amazon.kinesis.exceptions.ShutdownException;
import software.amazon.kinesis.lifecycle.events.InitializationInput;
import software.amazon.kinesis.lifecycle.events.LeaseLostInput;
import software.amazon.kinesis.lifecycle.events.ProcessRecordsInput;
import software.amazon.kinesis.lifecycle.events.ShardEndedInput;
import software.amazon.kinesis.lifecycle.events.ShutdownRequestedInput;
import software.amazon.kinesis.processor.ShardRecordProcessor;

public class KinesisStreamProcessor implements ShardRecordProcessor {


    private static final String SHARD_ID_MDC_KEY = "ShardId";

    private static final Logger log = LoggerFactory.getLogger(KinesisStreamProcessor.class);

    private String shardId;

    private ObjectMapper objectMapper;  

    private TradeMatchingEgressService service;

    public KinesisStreamProcessor(){
        service = StaticApplicationContext.getContext().getBean(TradeMatchingEgressService.class);
        objectMapper = new ObjectMapper();
        objectMapper.registerModule(new JavaTimeModule());
    }

    @Override
    public void initialize(InitializationInput initializationInput) {
        shardId = initializationInput.shardId();
        MDC.put(SHARD_ID_MDC_KEY, shardId);
        try {
            log.info("Initializing @ Sequence: {}", initializationInput.extendedSequenceNumber());
        } finally {
            MDC.remove(SHARD_ID_MDC_KEY);
        }
    }

    @Override
    public void processRecords(ProcessRecordsInput processRecordsInput) {
        MDC.put(SHARD_ID_MDC_KEY, shardId);
        try {
            log.info("Processing {} record(s)", processRecordsInput.records().size());
            List<TradeMessage> tmList = new ArrayList<>();
            List<ResponseMessage> nackMessages = new ArrayList<>();
            processRecordsInput.records().forEach(r -> {log.info("Processing record pk: {} -- Seq: {}", r.partitionKey(), r.sequenceNumber());
                byte[] bytes = new byte[r.data().remaining()];
                r.data().get(bytes);
                try {
                    TradeMessage tm = objectMapper.readValue(new String(bytes), TradeMessage.class);
                    tm.setTradeUUID(tm.getId());
                    tmList.add(tm);
                } catch (DatabindException e){
                    log.info("Not a trade message");
                    log.error("", e);
                    try {
                        ResponseMessage rm = objectMapper.readValue(new String(bytes), ResponseMessage.class);
                        nackMessages.add(rm);
                    } catch (JsonProcessingException err){
                        log.error("JsonProcessingException1", err);
                    }
                } catch (JsonProcessingException e) {
                    log.error("JsonProcessingException2", e);
                } 
            });

            if (!tmList.isEmpty()){
                service.egressTradeMessages(tmList);
            }

            if (!nackMessages.isEmpty()){
                service.egressNackMessages(nackMessages);
            }

        } catch (Throwable t) {
            log.error("Caught throwable while processing records. Aborting.");
            Runtime.getRuntime().halt(1);       // Hard exit
        }


        try {
            processRecordsInput.checkpointer().checkpoint();
        } catch (InvalidStateException | ShutdownException e) {
            log.error("Could not set Checkpoint");
            Runtime.getRuntime().halt(1);       // Hard exit
        }
        MDC.remove(SHARD_ID_MDC_KEY);
    }

    @Override
    public void leaseLost(LeaseLostInput leaseLostInput) {
        MDC.put(SHARD_ID_MDC_KEY, shardId);
        try {
            log.info("Lost lease, so terminating.");
        } finally {
            MDC.remove(SHARD_ID_MDC_KEY);
        }
    }

    @Override
    public void shardEnded(ShardEndedInput shardEndedInput) {
        MDC.put(SHARD_ID_MDC_KEY, shardId);
        try {
            log.info("Reached shard end checkpointing.");
            shardEndedInput.checkpointer().checkpoint();
        } catch (ShutdownException | InvalidStateException e) {
            log.error("Exception while checkpointing at shard end. Giving up.", e);
        } finally {
            MDC.remove(SHARD_ID_MDC_KEY);
        }
    }

    @Override
    public void shutdownRequested(ShutdownRequestedInput shutdownRequestedInput) {
        MDC.put(SHARD_ID_MDC_KEY, shardId);
        try {
            log.info("Scheduler is shutting down, checkpointing.");
            shutdownRequestedInput.checkpointer().checkpoint();
        } catch (ShutdownException | InvalidStateException e) {
            log.error("Exception while checkpointing at requested shutdown. Giving up.", e);
        } finally {
            MDC.remove(SHARD_ID_MDC_KEY);
        }
    }
}
