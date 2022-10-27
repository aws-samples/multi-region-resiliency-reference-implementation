// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.core.matching.kcl;

import app.tradematching.core.matching.config.StaticApplicationContext;
import app.tradematching.core.matching.exceptions.KinesisStreamException;
import app.tradematching.core.matching.exceptions.SettlementMessageParsingException;
import app.tradematching.core.matching.exceptions.SettlementPersistException;
import app.tradematching.core.matching.exceptions.TradePersistException;
import app.tradematching.core.matching.pojo.Settlement;
import app.tradematching.core.matching.services.SettlementService;
import app.tradematching.core.matching.services.TradeMessageService;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import lombok.extern.slf4j.Slf4j;
import org.slf4j.MDC;
import org.springframework.dao.DataIntegrityViolationException;
import software.amazon.kinesis.exceptions.InvalidStateException;
import software.amazon.kinesis.exceptions.ShutdownException;
import software.amazon.kinesis.lifecycle.events.*;
import software.amazon.kinesis.processor.ShardRecordProcessor;
import software.amazon.kinesis.retrieval.KinesisClientRecord;

import java.util.ArrayList;
import java.util.List;

@Slf4j
public class SettlementKinesisStreamProcessor implements ShardRecordProcessor {
    private static final String SHARD_ID_MDC_KEY = "ShardId";
    private String shardId;
    private final TradeMessageService tradeMessageService;
    private final SettlementService settlementService;
    private ObjectMapper objectMapper;

    public SettlementKinesisStreamProcessor(){
        tradeMessageService = StaticApplicationContext.getContext().getBean(TradeMessageService.class);
        settlementService = StaticApplicationContext.getContext().getBean(SettlementService.class);
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
        log.info("Initialization complete");
    }

    @Override
    public void processRecords(ProcessRecordsInput processRecordsInput) {
        MDC.put(SHARD_ID_MDC_KEY, shardId);
        log.info("Processing {} record(s)", processRecordsInput.records().size());
        // Process each Settlement separately
        for (KinesisClientRecord r: processRecordsInput.records())
        {
            try {
                log.info("Processing record pk: {} -- Seq: {}", r.partitionKey(), r.sequenceNumber());
                // 1. Parse the message
                byte[] bytes = new byte[r.data().remaining()];
                r.data().get(bytes);
                Settlement s = settlementService.settlementFromBytes(bytes);
                // 2. Update the coming back settlement
                String tradeUuidUpdated = settlementService.doTradeSettling(s);
                // 3. check for settled trade
                tradeMessageService.updateSettledTrade(tradeUuidUpdated);
            } catch (SettlementMessageParsingException e) {
                log.error("Error parsing settlement, Skipping", e);
            }
            catch (SettlementPersistException e) {
                log.error("Failed to Persist Settlement message, HARD EXIT", e);
                Runtime.getRuntime().halt(1);       // Hard exit
            }
            catch (TradePersistException e) {
                log.error("Trade Persist Exception HARD EXIT");
                Runtime.getRuntime().halt(1);
            }
            catch (KinesisStreamException e) {
                log.error("KinesisStreamException HARD EXIT");
                Runtime.getRuntime().halt(1);
            }
            catch (DataIntegrityViolationException e){
                log.info("Ignoring ConstraintViolationException");
            } catch (Throwable t) {
                log.error("Caught throwable while processing records. Aborting.");
                Runtime.getRuntime().halt(1);
            }
        }

        // 5. Block is finished. no hard exit. move checkpoint for next batch
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
