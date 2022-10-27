// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.core.matching.jpa;

import app.tradematching.core.matching.pojo.TradeAllocation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.transaction.annotation.Transactional;

public interface SettlingRepository extends JpaRepository<TradeAllocation, Long> {
    @Modifying
    @Transactional
    @Query("update TradeAllocation ta set ta.status = :status where ta.allocationID = :allocationId and ta.account = :account and ta.quantity = :quantity and ta.tradeMessage.dbID = (select tm.dbID from TradeMessage tm where tm.id = :tradeUuid)")
    int updateTradeAllocationStatus(@Param("status") String status,
                                    @Param("allocationId") long allocationId,
                                    @Param("tradeUuid") String tradeUuid,
                                    @Param("account") String account,
                                    @Param("quantity") int quantity);
}
