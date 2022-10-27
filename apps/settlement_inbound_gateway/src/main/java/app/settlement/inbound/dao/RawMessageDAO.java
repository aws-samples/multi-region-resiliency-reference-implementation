// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.settlement.inbound.dao;

import app.settlement.inbound.exceptions.DynamoDBConnectionException;
import app.settlement.inbound.pojo.RawMessage;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Repository;
import software.amazon.awssdk.enhanced.dynamodb.DynamoDbTable;
import software.amazon.awssdk.enhanced.dynamodb.Expression;
import software.amazon.awssdk.enhanced.dynamodb.model.PutItemEnhancedRequest;
import software.amazon.awssdk.services.dynamodb.model.ConditionalCheckFailedException;

@Repository
@Slf4j
public class RawMessageDAO {

    DynamoDbTable<RawMessage> rawMessageDynamoDbTable;

    public RawMessageDAO(DynamoDbTable<RawMessage> rawMessageDynamoDbTable){
        this.rawMessageDynamoDbTable = rawMessageDynamoDbTable;
    }

    public void save(RawMessage rawMessage) throws DynamoDBConnectionException {
//        log.info("Putting message into safe store: " + this);
        try {
            Expression putExpression = Expression.builder().expression("attribute_not_exists(id)").build();
            PutItemEnhancedRequest<RawMessage> request = PutItemEnhancedRequest.<RawMessage>builder(RawMessage.class)
                    .conditionExpression(putExpression)
                    .item(rawMessage)
                    .build();
            rawMessageDynamoDbTable.putItem(request);
        } catch (ConditionalCheckFailedException e){
            log.error("Record already exists in table");
        } catch(Exception e) {
            log.error("Error Putting trade into dynamoDB", e);
            throw new DynamoDBConnectionException("Error Saving Trade to dynamoDB", e);
        }
    }

}
