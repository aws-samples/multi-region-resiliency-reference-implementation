// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.settlement.outbound.processor;

import app.settlement.outbound.StaticApplicationContext;
import app.settlement.outbound.exceptions.DynamoDBConnectionException;
import app.settlement.outbound.exceptions.KinesisStreamException;
import app.settlement.outbound.exceptions.SettlementMessageParsingException;
import app.settlement.outbound.pojo.NackMessage;
import app.settlement.outbound.pojo.Settlement;
import app.settlement.outbound.services.NackService;
import app.settlement.outbound.services.SettlementService;
import lombok.extern.slf4j.Slf4j;
import org.slf4j.MDC;
import org.springframework.context.ApplicationContext;
import software.amazon.kinesis.exceptions.InvalidStateException;
import software.amazon.kinesis.exceptions.ShutdownException;
import software.amazon.kinesis.lifecycle.events.*;
import software.amazon.kinesis.processor.ShardRecordProcessor;
import software.amazon.kinesis.retrieval.KinesisClientRecord;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;


@Slf4j
public class RecordProcessor implements ShardRecordProcessor {
    SettlementService settlementService;
    NackService nackService;
    private static final String SHARD_ID_MDC_KEY = "ShardId";
    private String shardId;
    public RecordProcessor() {
        ApplicationContext context = StaticApplicationContext.getContext();;
        settlementService = context.getBean(SettlementService.class);
        nackService = context.getBean(NackService.class);
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

        byte[] b = null;
        List<Settlement> settlements = new ArrayList<Settlement>();
        Settlement settlement = null;
        List<NackMessage> nacks = new ArrayList<>();
        NackMessage nack = null;
        log.info("Processing Trades {} record(s)", processRecordsInput.records().size());
        // Data is read here from the Kinesis data stream
        for (KinesisClientRecord record : processRecordsInput.records()) {
            log.info("Processing Record For Partition Key : {}", record.partitionKey());
            try {
                b = new byte[record.data().remaining()];
                record.data().get(b);
                // try Settlements first
                settlement = settlementService.settlementFromBytes(b);
                settlements.add(settlement);
            } catch (SettlementMessageParsingException e) {
                try {
                    nack = nackService.nackFromBytes(b);
                } catch (IOException ex) {
                    log.error("Error processing record", e);
                }
                nacks.add(nack);
            } catch (Exception e){
                log.error("Error processing record", e);
                Runtime.getRuntime().halt(1);
            }
        }

        if(!settlements.isEmpty()){
            try {
                settlementService.persistSettlements(settlements);
                // now send the valid messages to kinesis
                settlementService.pushSettlementsToQueue(settlements);
            }
            catch (DynamoDBConnectionException e) {
                log.error("Exception persisting settlements, ", e);
                Runtime.getRuntime().halt(1);
            }
        }

        if(!nacks.isEmpty()){
            try {
                nackService.persistNacks(nacks);
                // now send the valid messages to kinesis
                nackService.pushNacksToQueue(nacks);
            }
            catch (DynamoDBConnectionException e) {
                log.error("Exception persisting nack settlements, ", e);
                Runtime.getRuntime().halt(1);
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