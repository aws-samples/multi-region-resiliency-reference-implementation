// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.outbound.services;


import app.tradematching.outbound.StaticApplicationContext;
import app.tradematching.outbound.pojo.ResponseMessage;
import app.tradematching.outbound.pojo.SettlementMessage;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;
import software.amazon.kinesis.exceptions.InvalidStateException;
import software.amazon.kinesis.exceptions.ShutdownException;
import software.amazon.kinesis.lifecycle.events.*;
import software.amazon.kinesis.processor.ShardRecordProcessor;

import java.util.ArrayList;
import java.util.List;

public class KinesisSettlementStreamProcessor implements ShardRecordProcessor {


    private static final String SHARD_ID_MDC_KEY = "ShardId";

    private static final Logger log = LoggerFactory.getLogger(KinesisSettlementStreamProcessor.class);

    private String shardId;

    private TradeMatchingOutboundSettlementService service;

    public KinesisSettlementStreamProcessor(){
        service = StaticApplicationContext.getContext().getBean(TradeMatchingOutboundSettlementService.class);
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
            log.info("Processing Settlement {} record(s)", processRecordsInput.records().size());
            List<SettlementMessage> messageList = new ArrayList<>();
            processRecordsInput.records().forEach(r -> {log.info("Processing record pk: {} -- Seq: {}", r.partitionKey(), r.sequenceNumber());
                byte[] bytes = new byte[r.data().remaining()];
                r.data().get(bytes);
                try {
                    SettlementMessage sm = service.settlementMessageFromBytesString(new String(bytes));
                    messageList.add(sm);
                } catch (JsonProcessingException e) {
                    log.error("", e);
                } 
            });
            if (!messageList.isEmpty()){
                service.processOutboundSettlementMessages(messageList);
            }

        } catch (Throwable t) {
            log.error("Caught throwable while processing records. Aborting.", t);
            Runtime.getRuntime().halt(1);
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
