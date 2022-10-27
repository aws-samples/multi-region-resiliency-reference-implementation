// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.ingestion.kcl;

import app.tradematching.ingestion.StaticApplicationContext;

import app.tradematching.ingestion.exceptions.DynamoDBConnectionException;
import app.tradematching.ingestion.exceptions.KinesisStreamException;
import app.tradematching.ingestion.exceptions.TradeMessageParsingException;
import app.tradematching.ingestion.pojo.NackMessage;
import app.tradematching.ingestion.pojo.RawMessage;
import app.tradematching.ingestion.pojo.Trade;

import app.tradematching.ingestion.services.NackService;
import app.tradematching.ingestion.services.TradeService;
import lombok.extern.slf4j.Slf4j;
import software.amazon.kinesis.exceptions.InvalidStateException;
import software.amazon.kinesis.exceptions.ShutdownException;
import software.amazon.kinesis.lifecycle.events.InitializationInput;
import software.amazon.kinesis.lifecycle.events.LeaseLostInput;
import software.amazon.kinesis.lifecycle.events.ProcessRecordsInput;
import software.amazon.kinesis.lifecycle.events.ShardEndedInput;
import software.amazon.kinesis.lifecycle.events.ShutdownRequestedInput;
import software.amazon.kinesis.processor.ShardRecordProcessor;
import software.amazon.kinesis.retrieval.KinesisClientRecord;
import org.slf4j.MDC;

import java.util.ArrayList;
import java.util.List;


@Slf4j
public class RecordProcessor implements ShardRecordProcessor {
    private TradeService tradeService;
    private NackService nackService;
    private static final String SHARD_ID_MDC_KEY = "ShardId";
    private String shardId;


    public RecordProcessor() {
        tradeService = StaticApplicationContext.getContext().getBean(TradeService.class);
        nackService = StaticApplicationContext.getContext().getBean(NackService.class);
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
        List<Trade> trades = new ArrayList<Trade>();
        List<NackMessage> nacks = new ArrayList<>();
        Trade trade = null;
        RawMessage rawMessage = null;
        NackMessage nack = null;
        log.info("Processing {} Records",processRecordsInput.records().size());
        // Data is read here from the Kinesis data stream
        for (KinesisClientRecord record : processRecordsInput.records()) {
            log.info("Processing Record For Partition Key : {}", record.partitionKey());
            try {
                byte[] b = new byte[record.data().remaining()];
                record.data().get(b);
                // Get raw message first
                rawMessage = RawMessage.fromJsonAsBytes(b);
                // then attempt to build trade object
                trade = tradeService.tradeFromRawMessage(rawMessage);
                // Validate fields are not null
                if(!tradeService.isValidTrade(trade)){
                    nack = nackService.nackFromRawMessage(rawMessage, "Invalid trade! Missing required fields.");
                    nackService.persistNack(nack);
                    nacks.add(nack);
                }else {
                    // Save the message to dynamoDB, first checkpoint
                    tradeService.persistTrade(trade);
//                trade.setType("ACK");
                    trades.add(trade);
                }
            } catch (DynamoDBConnectionException e) {
                log.error("Exception in persisting trade, Error Connecting to dynamoDB", e);
                Runtime.getRuntime().halt(1);       // Hard exit
//                throw e;
            } catch (TradeMessageParsingException e) {
                log.error("Error parsing record {}", e);
                nack = nackService.nackFromRawMessage(rawMessage, "Unable to parse trade message.");
                try {
                    nackService.persistNack(nack);
                } catch (DynamoDBConnectionException ex) {
                    log.error("Exception in persisting nack, Error Connecting to dynamoDB", ex);
                }
                nacks.add(nack);
            } catch (Exception e){
                log.error("Error processing record", e);
                Runtime.getRuntime().halt(1);       // Hard exit
            }
        }

        if(!trades.isEmpty()){
            try {
                // todo send ACKs to Egress before pushing to trade matching
                // now send the valid messages to kinesis
                tradeService.pushTradesUpstream(trades);
            }
            catch (KinesisStreamException e) {
                log.error("Exception pushing trade upstream, Error connecting to Kinesis", e);
                // no need to throw since already persisting in DB
                Runtime.getRuntime().halt(1);       // Hard exit
            }
        }

        if(!nacks.isEmpty()){
            try {
                nackService.pushNacksToEgress(nacks);
            }
            catch (KinesisStreamException e) {
                log.error("Exception pushing Nacks to Egress, Error connecting to Kinesis", e);
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