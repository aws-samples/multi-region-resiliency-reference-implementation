// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.settlement.outbound.dao;

import app.settlement.outbound.exceptions.DynamoDBConnectionException;
import app.settlement.outbound.pojo.Settlement;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Repository;
import software.amazon.awssdk.enhanced.dynamodb.DynamoDbEnhancedClient;
import software.amazon.awssdk.enhanced.dynamodb.DynamoDbTable;
import software.amazon.awssdk.enhanced.dynamodb.Expression;
import software.amazon.awssdk.enhanced.dynamodb.model.BatchWriteResult;
import software.amazon.awssdk.enhanced.dynamodb.model.PutItemEnhancedRequest;
import software.amazon.awssdk.enhanced.dynamodb.model.WriteBatch;
import software.amazon.awssdk.services.dynamodb.model.ConditionalCheckFailedException;

import java.util.List;

@Repository
@Slf4j
public class SettlementDAO {
    private DynamoDbEnhancedClient enhancedClient;
    private DynamoDbTable<Settlement> settlementDynamoDbTable;

    public SettlementDAO(DynamoDbEnhancedClient enhancedClient, DynamoDbTable<Settlement> settlementDynamoDbTable){
        this.enhancedClient = enhancedClient;
        this.settlementDynamoDbTable = settlementDynamoDbTable;
    }

    public void save(Settlement settlement) throws DynamoDBConnectionException {
        try{
            settlementDynamoDbTable.putItem(settlement);
        }catch (Exception e){
            log.error("Error saving settlement into dynamodb");
            throw new DynamoDBConnectionException("Error saving settlement to dynamodb", e);
        }
    }

    public void save(List<Settlement> settlements) throws DynamoDBConnectionException {
        for (Settlement s : settlements){
            try {
                Expression putExpression = Expression.builder().expression("attribute_not_exists(id)").build();
                PutItemEnhancedRequest<Settlement> request = PutItemEnhancedRequest.<Settlement>builder(Settlement.class)
                        .conditionExpression(putExpression)
                        .item(s)
                        .build();
                settlementDynamoDbTable.putItem(request);
            } catch (ConditionalCheckFailedException e){
                log.error("Record already exists in table");
            } catch (Exception e)
            {
                log.error("Exception saving settlements to dynamodb", e);
                throw new DynamoDBConnectionException("Error saving settlement to dynamodb", e);
            }

        }
//        try {
//            WriteBatch.Builder<Settlement> recordBuilder = WriteBatch.builder(Settlement.class).mappedTableResource(settlementDynamoDbTable);
//            for (int i = 0; i < settlements.size(); i++){
//                recordBuilder.addPutItem(settlements.get(i));
//                if (i % 24 == 0 || i == settlements.size() - 1){
//                    WriteBatch.Builder<Settlement> finalRecordBuilder = recordBuilder;
//                    BatchWriteResult result = enhancedClient.batchWriteItem(r -> r.addWriteBatch(finalRecordBuilder.build()));
//                    log.info(result.toString());
//                    recordBuilder = WriteBatch.builder(Settlement.class).mappedTableResource(settlementDynamoDbTable);
//                }
//            }
//        }catch (Exception e){
//            log.error("Exception saving settlements to dynamodb", e);
//            throw new DynamoDBConnectionException("Error saving settlement to dynamodb", e);
//        }
    }
}
