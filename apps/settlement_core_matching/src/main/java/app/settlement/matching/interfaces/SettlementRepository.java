// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.settlement.matching.interfaces;

import app.settlement.matching.pojo.Settlement;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface SettlementRepository extends JpaRepository<Settlement, String> {
    @Query("select s from Settlement s where s.imID = :imID and s.brokerID = :brokerID and s.tradeID = :tradeID and s.allocationID = :allocationID and s.id <> :settlementID and s.status <> 'Settled'")
    Settlement findSettlementPair(@Param("imID") String imId,
                                  @Param("brokerID") String brokerId,
                                  @Param("tradeID") String tradeId,
                                  @Param("allocationID") long allocationId,
                                  @Param("settlementID") String settlementId);
}
