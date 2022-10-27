// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.ingestion.kcl;

import app.tradematching.ingestion.StaticApplicationContext;
import app.tradematching.ingestion.exceptions.DynamoDBConnectionException;
import app.tradematching.ingestion.exceptions.KinesisStreamException;
import app.tradematching.ingestion.exceptions.TradeMessageParsingException;
import app.tradematching.ingestion.pojo.NackMessage;
import app.tradematching.ingestion.pojo.RawMessage;
import app.tradematching.ingestion.pojo.Settlement;
import app.tradematching.ingestion.pojo.Trade;
import app.tradematching.ingestion.services.NackService;
import app.tradematching.ingestion.services.SettlementService;
import app.tradematching.ingestion.services.TradeService;
import lombok.extern.slf4j.Slf4j;
import org.slf4j.MDC;
import software.amazon.kinesis.exceptions.InvalidStateException;
import software.amazon.kinesis.exceptions.ShutdownException;
import software.amazon.kinesis.lifecycle.events.*;
import software.amazon.kinesis.processor.ShardRecordProcessor;
import software.amazon.kinesis.retrieval.KinesisClientRecord;

import java.util.ArrayList;
import java.util.List;

@Slf4j
public class SettlementRecordProcessor implements ShardRecordProcessor {
    private static final String SHARD_ID_MDC_KEY = "ShardId";
    private String shardId;
    private SettlementService service;

    public SettlementRecordProcessor() {
        this.service = StaticApplicationContext.getContext().getBean(SettlementService.class);
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
        log.info("Settlement shard Initialization complete");
    }

    @Override
    public void processRecords(ProcessRecordsInput processRecordsInput) {
        MDC.put(SHARD_ID_MDC_KEY, shardId);
        List<Settlement> settlements = new ArrayList<Settlement>();
        log.info("Processing {} Records",processRecordsInput.records().size());
        for (KinesisClientRecord record : processRecordsInput.records()) {
            log.info("Processing Record For Partition Key : {}", record.partitionKey());
            try {
                byte[] b = new byte[record.data().remaining()];
                record.data().get(b);
                Settlement settlement = service.settlementFromBytes(b);
                settlements.add(settlement);
            }  catch (Exception e){
                log.error("Error processing record", e);
                Runtime.getRuntime().halt(1);       // Hard exit
            }
        }

        if(!settlements.isEmpty()){
            try {
                service.persistSettlements(settlements);
                service.pushSettlementsUpstream(settlements);
            }
            catch (DynamoDBConnectionException e) {
                log.error("Exception in persisting trade, Error Connecting to dynamoDB", e);
                Runtime.getRuntime().halt(1);       // Hard exit
            }
            catch (KinesisStreamException e) {
                log.error("Exception pushing settlements upstream, Error connecting to Kinesis", e);
                // no need to throw since already persisting in DB
                Runtime.getRuntime().halt(1);       // Hard exit
            }
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
