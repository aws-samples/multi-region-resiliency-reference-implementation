
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.settlement.matching.dao;

import app.settlement.matching.interfaces.SettlementRepository;
import app.settlement.matching.pojo.Settlement;
import lombok.extern.slf4j.Slf4j;
import org.springframework.retry.annotation.Backoff;
import org.springframework.retry.annotation.EnableRetry;
import org.springframework.retry.annotation.Retryable;
import org.springframework.stereotype.Repository;

import javax.transaction.Transactional;
import java.util.List;

@EnableRetry
@Repository
@Slf4j
public class SettlementDAO {
    private SettlementRepository repo;

	SettlementDAO(SettlementRepository settlementRepository) {
        this.repo = settlementRepository;
    }

	@Retryable(backoff = @Backoff(delay = 2000))
	@Transactional
    public Settlement persistSettlement(Settlement settlement){
        return repo.save(settlement);
    }

	@Retryable(backoff = @Backoff(delay = 2000))
	@Transactional
    public Settlement findSettlementPair(Settlement settlement){
		return repo.findSettlementPair(
				settlement.getImID(),
				settlement.getBrokerID(),
				settlement.getTradeID(),
				settlement.getAllocationID(),
				settlement.getId()
		);
	}

	@Retryable(backoff = @Backoff(delay = 2000))
	@Transactional
	public List<Settlement> updateSettlements(List<Settlement> settlementList){
		return repo.saveAll(settlementList);
	}
}
