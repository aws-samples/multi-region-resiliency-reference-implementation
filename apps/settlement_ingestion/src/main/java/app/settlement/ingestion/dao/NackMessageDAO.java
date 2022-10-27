// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.settlement.ingestion.dao;

import app.settlement.ingestion.exceptions.DynamoDBConnectionException;
import app.settlement.ingestion.pojo.NackMessage;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Repository;
import software.amazon.awssdk.enhanced.dynamodb.DynamoDbEnhancedClient;
import software.amazon.awssdk.enhanced.dynamodb.DynamoDbTable;
import software.amazon.awssdk.enhanced.dynamodb.Expression;
import software.amazon.awssdk.enhanced.dynamodb.model.BatchWriteResult;
import software.amazon.awssdk.enhanced.dynamodb.model.PutItemEnhancedRequest;
import software.amazon.awssdk.enhanced.dynamodb.model.WriteBatch;
import software.amazon.awssdk.enhanced.dynamodb.model.WriteBatch.Builder;
import software.amazon.awssdk.services.dynamodb.model.ConditionalCheckFailedException;

import java.util.List;

@Repository
@Slf4j
public class NackMessageDAO {

    private DynamoDbEnhancedClient enhancedClient;
    private DynamoDbTable<NackMessage> nackMessageDynamoDbTable;

    public NackMessageDAO(DynamoDbEnhancedClient enhancedClient, DynamoDbTable<NackMessage> nackMessageDynamoDbTable){
        this.enhancedClient = enhancedClient;
        this.nackMessageDynamoDbTable = nackMessageDynamoDbTable;
    }

    public void save(NackMessage nackMessage) throws DynamoDBConnectionException {
        try{
            Expression putExpression = Expression.builder().expression("attribute_not_exists(id)").build();
            PutItemEnhancedRequest<NackMessage> request = PutItemEnhancedRequest.<NackMessage>builder(NackMessage.class)
                    .conditionExpression(putExpression)
                    .item(nackMessage)
                    .build();
            nackMessageDynamoDbTable.putItem(request);
        } catch (ConditionalCheckFailedException e){
            log.error("Record already exists in table");
        } catch (Exception e){
            log.error("Error saving nack into dynamodb");
            throw new DynamoDBConnectionException("Error saving nack to dynamodb", e);
        }
    }

    public void save(List<NackMessage> nackMessages){
        try {
            Builder<NackMessage> recordBuilder = WriteBatch.builder(NackMessage.class).mappedTableResource(nackMessageDynamoDbTable);
            for (int i = 0; i < nackMessages.size(); i++){
                recordBuilder.addPutItem(nackMessages.get(i));
                if (i % 24 == 0 || i == nackMessages.size() - 1){
                    Builder<NackMessage> finalRecordBuilder = recordBuilder;
                    BatchWriteResult result = enhancedClient.batchWriteItem(r -> r.addWriteBatch(finalRecordBuilder.build()));
                    log.info(result.toString());
                    recordBuilder = WriteBatch.builder(NackMessage.class).mappedTableResource(nackMessageDynamoDbTable);
                }
            }
        }catch (Exception e){
            log.error("Exception saving nacks to dynamodb");
        }
    }
}
