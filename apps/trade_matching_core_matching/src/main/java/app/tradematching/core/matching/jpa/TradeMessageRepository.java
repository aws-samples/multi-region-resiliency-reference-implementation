// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.core.matching.jpa;

import org.springframework.data.jpa.repository.JpaRepository;
import app.tradematching.core.matching.pojo.TradeMessage;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface TradeMessageRepository extends JpaRepository<TradeMessage, Long> {
    @Query("select t from TradeMessage t where t.id= :uuid")
    TradeMessage getTradeByUUID(@Param("uuid") String uuid);

    @Query("select t from TradeMessage t where t.dbID= :dbId")
    TradeMessage getTradeByDBID(@Param("dbId") long dbId);
}
