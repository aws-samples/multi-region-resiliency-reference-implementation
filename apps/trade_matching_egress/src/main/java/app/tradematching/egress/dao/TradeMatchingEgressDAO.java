// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.egress.dao;

import app.tradematching.egress.configs.AwsProperties;
import app.tradematching.egress.pojo.EgressStoreRecord;
import app.tradematching.egress.pojo.SettlementMessage;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import software.amazon.awssdk.core.client.config.ClientOverrideConfiguration;
import software.amazon.awssdk.enhanced.dynamodb.DynamoDbEnhancedClient;
import software.amazon.awssdk.enhanced.dynamodb.DynamoDbTable;
import software.amazon.awssdk.enhanced.dynamodb.Expression;
import software.amazon.awssdk.enhanced.dynamodb.TableSchema;
import software.amazon.awssdk.enhanced.dynamodb.model.PutItemEnhancedRequest;
import software.amazon.awssdk.http.apache.ApacheHttpClient;
import software.amazon.awssdk.services.dynamodb.DynamoDbClient;
import software.amazon.awssdk.services.dynamodb.model.AttributeValue;
import software.amazon.awssdk.services.dynamodb.model.ConditionalCheckFailedException;
import javax.annotation.PostConstruct;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Repository
@Slf4j
public class TradeMatchingEgressDAO {

//	@Value("${DYNAMODB_TABLE_NAME}")
//	private String dynamoDBTableName="egress_table";
	@Autowired
	private AwsProperties awsProperties;
	private DynamoDbEnhancedClient enhancedClient;
	private DynamoDbEnhancedClient enhancedClientSettlement;
	private DynamoDbTable<EgressStoreRecord> egressSafeStoreTable;
	private DynamoDbTable<SettlementMessage> egressSettlementSafeStoreTable;


//	public TradeMatchingEgressDAO() {
//		enhancedClient = DynamoDbEnhancedClient.create();
//
//		egressSafeStoreTable = enhancedClient.table(dynamoDBTableName, TableSchema.fromImmutableClass(EgressStoreRecord.class));
//	}

	@PostConstruct
	public void buildClient() {
		enhancedClient = DynamoDbEnhancedClient
				.builder()
				.dynamoDbClient(getDynamoDbClient())
				.build();

		enhancedClientSettlement= DynamoDbEnhancedClient
				.builder()
				.dynamoDbClient(getDynamoDbClient())
				.build();

		egressSafeStoreTable = enhancedClient.table(awsProperties.getSafeStoreTable(), TableSchema.fromImmutableClass(EgressStoreRecord.class));
		egressSettlementSafeStoreTable = enhancedClientSettlement.table(awsProperties.getSettlementSafeStoreTable(), TableSchema.fromImmutableClass(SettlementMessage.class));
	}

	private DynamoDbClient getDynamoDbClient() {
		ClientOverrideConfiguration.Builder overrideConfig =
				ClientOverrideConfiguration.builder();

		return DynamoDbClient.builder()
				.overrideConfiguration(overrideConfig.build())
				.httpClient(ApacheHttpClient.create())
				.build();
	}

	public void persistTrades(List<EgressStoreRecord> records){
		for (EgressStoreRecord r : records){
			try {
				Map<String, String> expressionNames = new HashMap<>();
				expressionNames.put("#s", "status");
				Map<String, AttributeValue> expressionValues = new HashMap<>();
				expressionValues.put(":status", AttributeValue.builder().s(r.getStatus()).build());
				Expression putExpression = Expression.builder()
						.expressionNames(expressionNames)
						.expressionValues(expressionValues)
						.expression("#s <> :status or attribute_not_exists(id)").build();
				PutItemEnhancedRequest<EgressStoreRecord> request = PutItemEnhancedRequest.<EgressStoreRecord>builder(EgressStoreRecord.class)
						.conditionExpression(putExpression)
						.item(r)
						.build();
				egressSafeStoreTable.putItem(request);
			} catch (ConditionalCheckFailedException e){
				log.error("Record already exists in table");
			} catch (Exception e)
			{
				log.error("Exception in persistTrades", e);
			}

		}
//		try {
//			log.info("Yooooooooooooooooooo");
//			Builder<EgressStoreRecord> recordBuilder = WriteBatch.builder(EgressStoreRecord.class).mappedTableResource(egressSafeStoreTable);
//			for (int i = 0; i < records.size(); i++)
//			{
//				recordBuilder.addPutItem(records.get(i));
//				if (i % 24 == 0 || i == records.size() - 1) {
//					Builder<EgressStoreRecord> finalRecordBuilder = recordBuilder;
//					BatchWriteResult result = enhancedClient.batchWriteItem(r -> r.addWriteBatch(finalRecordBuilder.build()));
//					log.info(result.toString());
//					recordBuilder = WriteBatch.builder(EgressStoreRecord.class).mappedTableResource(egressSafeStoreTable);
//				}
//			}
//
//
////			log.info(records.get(0).toString());
////			records.forEach(r -> recordBuilder.addPutItem(r));
//
//
//		} catch (Exception e)
//		{
//			log.error("Exception in persistTrades", e);
//		}


	}

	public void persistSettlements(List<SettlementMessage> records){
		for (SettlementMessage r : records){
			try {
				Expression putExpression = Expression.builder().expression("attribute_not_exists(id)").build();
				PutItemEnhancedRequest<SettlementMessage> request = PutItemEnhancedRequest.<SettlementMessage>builder(SettlementMessage.class)
						.conditionExpression(putExpression)
						.item(r)
						.build();
				egressSettlementSafeStoreTable.putItem(request);
			} catch (ConditionalCheckFailedException e){
				log.error("Record already exists in table");
			} catch (Exception e)
			{
				log.error("Exception in persistSettlements", e);
			}

		}
//		try {
//			log.info("Whooooooooooooooooooo");
//			Builder<SettlementMessage> recordBuilder = WriteBatch.builder(SettlementMessage.class).mappedTableResource(egressSettlementSafeStoreTable);
//			for (int i = 0; i < records.size(); i++)
//			{
//				recordBuilder.addPutItem(records.get(i));
//				if (i % 24 == 0 || i == records.size() - 1) {
//					Builder<SettlementMessage> finalRecordBuilder = recordBuilder;
//					BatchWriteResult result = enhancedClientSettlement.batchWriteItem(r -> r.addWriteBatch(finalRecordBuilder.build()));
//					log.info(result.toString());
//					recordBuilder = WriteBatch.builder(SettlementMessage.class).mappedTableResource(egressSettlementSafeStoreTable);
//				}
//			}
//
//		} catch (Exception e)
//		{
//			log.error("Exception in persistSettlements", e);
//		}
	}


}
