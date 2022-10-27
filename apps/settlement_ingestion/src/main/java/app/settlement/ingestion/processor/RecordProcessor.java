// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.settlement.ingestion.processor;

import app.settlement.ingestion.StaticApplicationContext;
import app.settlement.ingestion.exceptions.DynamoDBConnectionException;
import app.settlement.ingestion.exceptions.KinesisStreamException;
import app.settlement.ingestion.exceptions.SettlementMessageParsingException;
import app.settlement.ingestion.pojo.NackMessage;
import app.settlement.ingestion.pojo.RawMessage;
import app.settlement.ingestion.pojo.Settlement;
import app.settlement.ingestion.services.NackService;
import app.settlement.ingestion.services.RawMessageService;
import app.settlement.ingestion.services.SettlementService;
import lombok.extern.slf4j.Slf4j;
import org.slf4j.MDC;
import org.springframework.context.ApplicationContext;
import software.amazon.kinesis.exceptions.InvalidStateException;
import software.amazon.kinesis.exceptions.ShutdownException;
import software.amazon.kinesis.lifecycle.events.*;
import software.amazon.kinesis.processor.ShardRecordProcessor;
import software.amazon.kinesis.retrieval.KinesisClientRecord;

import java.util.ArrayList;
import java.util.List;


@Slf4j
public class RecordProcessor implements ShardRecordProcessor {
    RawMessageService rawMessageService;
    SettlementService settlementService;
    NackService nackService;
    private static final String SHARD_ID_MDC_KEY = "ShardId";
    private String shardId;

    public RecordProcessor() {
        ApplicationContext context = StaticApplicationContext.getContext();
        rawMessageService = context.getBean(RawMessageService.class);
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
        log.info("Initialization complete");
    }

    @Override
    public void processRecords(ProcessRecordsInput processRecordsInput) {
        MDC.put(SHARD_ID_MDC_KEY, shardId);
        List<Settlement> settlements = new ArrayList<Settlement>();
        List<NackMessage> nacks = new ArrayList<>();
        Settlement settlement = null;
        RawMessage rawMessage = null;
        NackMessage nack = null;

        // Data is read here from the Kinesis data stream
        for (KinesisClientRecord record : processRecordsInput.records()) {
            log.info("Processing Record For Partition Key : {}", record.partitionKey());
            try {
                byte[] b = new byte[record.data().remaining()];
                record.data().get(b);
                // Get raw message first
                rawMessage = rawMessageService.fromBytes(b);
                // then attempt to build settlement object
                settlement = settlementService.settlementFromRawMessage(rawMessage);
                // Validate fields are not null
                if(!settlementService.isValidSettlement(settlement)){
                    nack = nackService.nackFromRawMessage(rawMessage, "Invalid settlement! Missing required fields.");
                    nackService.persistNack(nack);
                    nacks.add(nack);
                }else {
                    settlementService.persistSettlement(settlement);
                    settlements.add(settlement);
                }
            } catch (DynamoDBConnectionException e) {
                log.error("Exception in persisting trade, Error Connecting to dynamoDB", e);
                Runtime.getRuntime().halt(1);
            } catch (SettlementMessageParsingException e) {
                log.error("Error parsing record {}", e);
                nack = nackService.nackFromRawMessage(rawMessage, "Unable to parse settlement message.");
                try {
                    nackService.persistNack(nack);
                } catch (DynamoDBConnectionException ex) {
                    log.error("Exception in persisting nack, Error Connecting to dynamoDB", ex);
                    Runtime.getRuntime().halt(1);
                }
                nacks.add(nack);
            } catch (Exception e){
                log.error("Error processing record", e);
                Runtime.getRuntime().halt(1);
            }
        }

        if(!settlements.isEmpty()){
            try {
                // now send the valid messages to kinesis
                settlementService.pushSettlementsUpstream(settlements);
            }
            catch (KinesisStreamException e) {
                log.error("Exception pushing trade upstream, Error connecting to Kinesis", e);
                Runtime.getRuntime().halt(1);
            }
        }

        if(!nacks.isEmpty()){
            try {
                nackService.pushNacksToEgress(nacks);
            }
            catch (KinesisStreamException e) {
                log.error("Exception pushing Nacks to Egress, Error connecting to Kinesis", e);
                Runtime.getRuntime().halt(1);
            }
        }
        try {
            processRecordsInput.checkpointer().checkpoint();
            log.info("Setting checkpoint for current batch");
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