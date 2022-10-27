// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
 package app.tradematching.core.matching.kcl;

 import app.tradematching.core.matching.config.StaticApplicationContext;
 import app.tradematching.core.matching.exceptions.IncomingTradeParsingException;
 import app.tradematching.core.matching.exceptions.TradePersistException;
 import app.tradematching.core.matching.pojo.LookupTrade;
 import app.tradematching.core.matching.pojo.TradeMessage;
 import app.tradematching.core.matching.services.MatchedTradeMessageProducerService;
 import app.tradematching.core.matching.services.TradeMatchingService;
 import app.tradematching.core.matching.services.TradeMessageService;
 import com.fasterxml.jackson.core.JsonProcessingException;
 import com.fasterxml.jackson.databind.DatabindException;
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
public class KinesisStreamProcessor implements ShardRecordProcessor {
    private final TradeMessageService tradeMessageService;
    private final TradeMatchingService tradeMatchingService;
     private MatchedTradeMessageProducerService producerService;

    private final ObjectMapper objectMapper;
    private static final String SHARD_ID_MDC_KEY = "ShardId";
    private String shardId;

    public KinesisStreamProcessor(){
        tradeMessageService = StaticApplicationContext.getContext().getBean(TradeMessageService.class);
        tradeMatchingService = StaticApplicationContext.getContext().getBean(TradeMatchingService.class);
        producerService = StaticApplicationContext.getContext().getBean(MatchedTradeMessageProducerService.class);
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
        // Process each trade separately
        for (KinesisClientRecord r: processRecordsInput.records()) {
            try {
                log.info("Processing record pk: {} -- Seq: {}", r.partitionKey(), r.sequenceNumber());
                byte[] bytes = new byte[r.data().remaining()];
                r.data().get(bytes);
                TradeMessage tradeMessage = parseMessage(new String(bytes));
//                log.info(new String(bytes));
                // 1. check if trade exist
                boolean trade_found = tradeMessageService.checkExistingTrade(tradeMessage.getId());
                if (trade_found) {
                    log.info("Trade already found. Skipping");
                } else {
                    // 2. try to match new trade with a potential match
                    log.info("Do Matching First");
                    LookupTrade matchedTrade = tradeMatchingService.tradeMatching(tradeMessage);
                    if (matchedTrade != null) {
                        log.info("MATCHED Trade Found ID:" + matchedTrade.getId());
                        // Persist new trade
                        tradeMessage.setStatus("MATCHED");
                        tradeMatchingService.persistSingleTrade(tradeMessage);
                        TradeMessage matchedTradeObject = tradeMessageService.getTradeByID(matchedTrade.getId());
                        log.info(matchedTradeObject.getId());
                        List<TradeMessage> tradeMessages = new ArrayList<>();
                        tradeMessages.add(tradeMessage);
                        tradeMessages.add(matchedTradeObject);
                        producerService.produceTradeMessageToKinesis(tradeMessages);
                    } else {
                        log.info("No Matched Trade Found");
                        // 3. search for mismatch
                        LookupTrade misMatchedTrades = tradeMatchingService.tradeMisMatching(tradeMessage);
                        if (misMatchedTrades != null) {
                            log.info("MisMATCHED Trade Found ID:" + misMatchedTrades.getId());
                            tradeMessage.setStatus("MISMATCHED");
                            tradeMatchingService.persistSingleTrade(tradeMessage);
                            TradeMessage misMatchedTradeObject = tradeMessageService.getTradeByID(misMatchedTrades.getId());
                            List<TradeMessage> tradeMessages = new ArrayList<>();
                            tradeMessages.add(tradeMessage);
                            tradeMessages.add(misMatchedTradeObject);
                            producerService.produceTradeMessageToKinesis(tradeMessages);
                        } else {
                            log.info("No Matched Trade Found");
                            //4. Persist the trade set it to unmatched
                            tradeMessage.setStatus("UNMATCHED");
                            tradeMatchingService.persistSingleTrade(tradeMessage);
                        }
                    }

                }
            } catch (TradePersistException e) {
                log.error("Failed to Persist message, HARD EXIT", e);
                Runtime.getRuntime().halt(1);       // Hard exit
            } catch (IncomingTradeParsingException e) {
                log.error("Failed to parse message, log and skip", e);
            } catch (DataIntegrityViolationException e) {
                log.info("Ignoring ConstraintViolationException", e);
            } catch (Throwable t) {
                log.error("Caught throwable while processing records. Aborting.", t);
                Runtime.getRuntime().halt(1);
            }
        }
    // 5. Block is finished. no hard exit. move checkpoint for next batch
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

    private TradeMessage parseMessage(String rawMessage) throws IncomingTradeParsingException {
        TradeMessage tm=null;
        try {
            tm = objectMapper.readValue(rawMessage, TradeMessage.class);
            tm.setStatus("UNMATCHED");
            TradeMessage finalTm = tm;
            tm.getAllocations().forEach(a -> a.setTradeMessage(finalTm));
        } catch (DatabindException e) {
            log.error("DatabindException!!!", e);
            throw new IncomingTradeParsingException("Error Parsing Trade");
        } catch (JsonProcessingException e) {
            log.error("JsonProcessingException!!!", e);
            throw new IncomingTradeParsingException("Error Parsing Trade");
        }
        return tm;
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
