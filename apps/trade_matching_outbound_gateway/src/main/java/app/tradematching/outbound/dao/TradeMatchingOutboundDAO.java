// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.outbound.dao;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import app.tradematching.outbound.configs.AwsProperties;
import app.tradematching.outbound.pojo.SettlementMessage;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Repository;

import app.tradematching.outbound.pojo.SafeStoreResponseMessage;
import lombok.extern.slf4j.Slf4j;
import software.amazon.awssdk.core.client.config.ClientOverrideConfiguration;
import software.amazon.awssdk.enhanced.dynamodb.DynamoDbEnhancedClient;
import software.amazon.awssdk.enhanced.dynamodb.DynamoDbTable;
import software.amazon.awssdk.enhanced.dynamodb.Expression;
import software.amazon.awssdk.enhanced.dynamodb.TableSchema;
import software.amazon.awssdk.enhanced.dynamodb.model.PutItemEnhancedRequest;
import software.amazon.awssdk.http.apache.ApacheHttpClient;
import software.amazon.awssdk.enhanced.dynamodb.model.BatchWriteResult;
import software.amazon.awssdk.enhanced.dynamodb.model.WriteBatch;
import software.amazon.awssdk.enhanced.dynamodb.model.WriteBatch.Builder;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.dynamodb.DynamoDbClient;
import software.amazon.awssdk.services.dynamodb.model.AttributeValue;
import software.amazon.awssdk.services.dynamodb.model.ConditionalCheckFailedException;

import javax.annotation.PostConstruct;

@Repository
@Slf4j
public class TradeMatchingOutboundDAO {

	@Autowired
	private AwsProperties awsProperties;
	private DynamoDbEnhancedClient enhancedClient;
	private DynamoDbEnhancedClient enhancedSettlementClient;
	private DynamoDbTable<SafeStoreResponseMessage> outboundSafeStoreTable;
	private DynamoDbTable<SettlementMessage> outboundSettlementSafeStoreTable;

	@PostConstruct
	public void buildClient() {
		enhancedClient = DynamoDbEnhancedClient
				.builder()
				.dynamoDbClient(getDynamoDbClient())
				.build();

		enhancedSettlementClient = DynamoDbEnhancedClient
				.builder()
				.dynamoDbClient(getDynamoDbClient())
				.build();


		outboundSafeStoreTable = enhancedClient.table(awsProperties.getStateTableName(), TableSchema.fromImmutableClass(SafeStoreResponseMessage.class));
		outboundSettlementSafeStoreTable = enhancedSettlementClient.table(awsProperties.getStateSettlementTableName(), TableSchema.fromImmutableClass(SettlementMessage.class));
	}

	private DynamoDbClient getDynamoDbClient() {
		ClientOverrideConfiguration.Builder overrideConfig =
				ClientOverrideConfiguration.builder();

		return DynamoDbClient.builder()
				.overrideConfiguration(overrideConfig.build())
				.httpClient(ApacheHttpClient.create())
				.region(Region.of(awsProperties.getRegion()))
				.build();
	}

	public void persistMessages(List<SafeStoreResponseMessage> records){
		for (SafeStoreResponseMessage m : records){
			try {
				Map<String, String> expressionNames = new HashMap<>();
				expressionNames.put("#s", "status");
				Map<String, AttributeValue> expressionValues = new HashMap<>();
				expressionValues.put(":status", AttributeValue.builder().s(m.getStatus()).build());
				Expression putExpression = Expression.builder()
						.expressionNames(expressionNames)
						.expressionValues(expressionValues)
						.expression("#s <> :status or attribute_not_exists(id)").build();
				PutItemEnhancedRequest<SafeStoreResponseMessage> request = PutItemEnhancedRequest.<SafeStoreResponseMessage>builder(SafeStoreResponseMessage.class)
						.conditionExpression(putExpression)
						.item(m)
						.build();
				outboundSafeStoreTable.putItem(request);
			} catch (ConditionalCheckFailedException e){
				log.error("Record already exists in table");
			}
			catch (Exception e)
			{
				log.error("Exception in persistMessages", e);
			}

		}
//		try {
//			Builder<SafeStoreResponseMessage> recordBuilder = WriteBatch.builder(SafeStoreResponseMessage.class).mappedTableResource(outboundSafeStoreTable);
//			for (int i = 0; i < records.size(); i++){
//				recordBuilder.addPutItem(records.get(i));
//				if (i % 24 == 0 || i == records.size() - 1) {
//					Builder<SafeStoreResponseMessage> finalRecordBuilder = recordBuilder;
//					BatchWriteResult result = enhancedClient.batchWriteItem(r -> r.addWriteBatch(finalRecordBuilder.build()));
//					log.info(result.toString());
//					recordBuilder = WriteBatch.builder(SafeStoreResponseMessage.class).mappedTableResource(outboundSafeStoreTable);
//				}
//			}
//		} catch (Exception e)
//		{
//			log.error("Exception in persistMessages", e);
//		}
	}

	public void persistMessage(SafeStoreResponseMessage message){
		log.info("Putting message into safe store: " + message);
		try {
			outboundSafeStoreTable.putItem(message);
		}
		catch(Exception e) {
			log.error("Error putting message into dynamoDB", e);
//			throw new DynamoDBConnectionException("Error Saving Mesage to dynamoDB", e);
		}
	}

	public void persistSettlementMessage(SettlementMessage message){
		log.info("Putting Settlement message into safe store: " + message);
		try {
			outboundSettlementSafeStoreTable.putItem(message);
		}
		catch(Exception e) {
			log.error("Error putting persistSettlementMessage message into dynamoDB", e);
//			throw new DynamoDBConnectionException("Error Saving Mesage to dynamoDB", e);
		}
	}

	public void persistSettlementMessage(List<SettlementMessage> records){
		for (SettlementMessage m : records){
			try {
				Expression putExpression = Expression.builder().expression("attribute_not_exists(id)").build();
				PutItemEnhancedRequest<SettlementMessage> request = PutItemEnhancedRequest.<SettlementMessage>builder(SettlementMessage.class)
						.conditionExpression(putExpression)
						.item(m)
						.build();
				outboundSettlementSafeStoreTable.putItem(request);
			} catch (ConditionalCheckFailedException e){
				log.error("Record already exists in table");
			} catch (Exception e)
			{
				log.error("Exception in persistSettlementMessage", e);
			}

		}
//		try {
//			Builder<SettlementMessage> recordBuilder = WriteBatch.builder(SettlementMessage.class).mappedTableResource(outboundSettlementSafeStoreTable);
//			for (int i = 0; i < records.size(); i++){
//				recordBuilder.addPutItem(records.get(i));
//				if (i % 24 == 0 || i == records.size() - 1) {
//					Builder<SettlementMessage> finalRecordBuilder = recordBuilder;
//					BatchWriteResult result = enhancedClient.batchWriteItem(r -> r.addWriteBatch(finalRecordBuilder.build()));
//					log.info(result.toString());
//					recordBuilder = WriteBatch.builder(SettlementMessage.class).mappedTableResource(outboundSettlementSafeStoreTable);
//				}
//			}
//		}catch (Exception e)
//		{
//			log.error("Exception in persistSettlementMessage", e);
//		}
	}
	
}
