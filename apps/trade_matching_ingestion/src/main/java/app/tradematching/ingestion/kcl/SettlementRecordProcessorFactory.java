// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.ingestion.kcl;

import org.springframework.stereotype.Component;
import software.amazon.kinesis.processor.ShardRecordProcessor;
import software.amazon.kinesis.processor.ShardRecordProcessorFactory;

@Component
public class SettlementRecordProcessorFactory implements ShardRecordProcessorFactory {
    public ShardRecordProcessor shardRecordProcessor(){
        return new SettlementRecordProcessor();
    }
}
