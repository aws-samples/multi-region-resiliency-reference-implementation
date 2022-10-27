// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.egress;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import app.tradematching.egress.dao.TradeMatchingEgressDAO;
import app.tradematching.egress.pojo.EgressStoreRecord;

@SpringBootTest
public class TradeMatchingEgressDAOTest {
	
	@Autowired
	private TradeMatchingEgressDAO dao;

	@Test
	public void testPersistence(){
		List<EgressStoreRecord> records = new ArrayList<EgressStoreRecord>();
		records.add(getEgressStoreRecord());
		records.add(getEgressStoreRecord());
		dao.persistTrades(records);
	}	
	private EgressStoreRecord getEgressStoreRecord(){
		return EgressStoreRecord.builder().id(UUID.randomUUID().toString()).timestamp(System.currentTimeMillis()).status("MATCHED").tradeMessage("hello").build();
	}
}
