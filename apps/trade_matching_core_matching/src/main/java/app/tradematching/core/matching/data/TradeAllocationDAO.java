// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.core.matching.data;

import app.tradematching.core.matching.pojo.LookupTrade;
import app.tradematching.core.matching.pojo.TradeMessage;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.jdbc.core.namedparam.SqlParameterSource;
import org.springframework.stereotype.Repository;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.sql.Types;

@Repository
@Slf4j
public class TradeAllocationDAO {
	@Autowired
	private JdbcTemplate jdbcTemplate;

	private NamedParameterJdbcTemplate namedParameterJdbcTemplate;

	private final String MATCH_SQL = """
			select a.id as id
			from trade_message a
			where a.sender_id != :sender_id
			and a.im_id= :im_id
			and a.broker_id= :broker_id
			and a.trade_id= :trade_id 
			and a.transaction_indicator= :transaction_indicator
			and a.trade_date= :trade_date
			and a.settlement_date = :settlement_date
			and a.security= :security
			and a.price= :price
			and a.quantity= :quantity
			and a.status = 'UNMATCHED'
			limit 10
			""";

	private final String UPDATE_MATCHED_TRADE = """
				update trade_message
				set status = 'MATCHED'
				where id = :id
			""";

	private final String MISMATCH_SQL = """
			select a.id as id
			from trade_message a
			where a.sender_id != :sender_id
			and a.im_id= :im_id
			and a.broker_id= :broker_id
			and a.trade_id= :trade_id 
			and a.transaction_indicator= :transaction_indicator
			and a.trade_date= :trade_date
			and a.settlement_date = :settlement_date
			and (a.security != :security or a.price != :price or a.quantity != :quantity)
			and a.status = 'UNMATCHED'
			limit 10
			""";

	private final String UPDATE_MISMATCHED_TRADE = """
				update trade_message
				set status = 'MISMATCHED'
				where id = :id
			""";

	// TODO implement optimistic locking
	public LookupTrade doMatching(TradeMessage message) {
		LookupTrade result=null;
		try {
			 SqlParameterSource parameters = new MapSqlParameterSource()
				.addValue("sender_id", message.getSenderID())
				.addValue("im_id", message.getImID())
				.addValue("broker_id", message.getBrokerID())
				.addValue("trade_id", message.getTradeID())
				.addValue("transaction_indicator", message.getTransactionIndicator())
				.addValue("trade_date", Timestamp.from(message.getTradeDate()), Types.TIMESTAMP)
				.addValue("settlement_date", Timestamp.from(message.getSettlementDate()), Types.TIMESTAMP)
				.addValue("security", message.getSecurity())
				.addValue("price", message.getPrice())
				.addValue("quantity", message.getQuantity());
				namedParameterJdbcTemplate = new NamedParameterJdbcTemplate(jdbcTemplate);

				LookupTrade db_result = namedParameterJdbcTemplate.queryForObject( MATCH_SQL,parameters, new LookupTradeMapper());

		if (db_result != null) {
			result = db_result;
			// Update matched trade status
			SqlParameterSource updateParameters = new MapSqlParameterSource("id", result.getId());
			int status = namedParameterJdbcTemplate.update(UPDATE_MATCHED_TRADE, updateParameters);

			if (status == 1) {
				log.debug("Successfully updated MATCHED status: " + result.getId());
			} else {
				// somehow update failed.
				log.error("found MATCHED record but can't update the state: " + result.getId());
			}
		}
		} catch (EmptyResultDataAccessException e) { // result.size() == 0;
			log.info("No Match found - return null");
			return null;
		}
		return result;
	}

	public LookupTrade doMisMatching(TradeMessage message) {
		LookupTrade result=null;
		try {
				SqlParameterSource parameters = new MapSqlParameterSource()
					.addValue("sender_id", message.getSenderID())
					.addValue("im_id", message.getImID())
					.addValue("broker_id", message.getBrokerID())
					.addValue("trade_id", message.getTradeID())
					.addValue("transaction_indicator", message.getTransactionIndicator())
					.addValue("trade_date", Timestamp.from(message.getTradeDate()), Types.TIMESTAMP)
					.addValue("settlement_date", Timestamp.from(message.getSettlementDate()), Types.TIMESTAMP)
					.addValue("security", message.getSecurity())
					.addValue("price", message.getPrice())
					.addValue("quantity", message.getQuantity());
			namedParameterJdbcTemplate = new NamedParameterJdbcTemplate(jdbcTemplate);
			LookupTrade db_result = namedParameterJdbcTemplate.queryForObject(MISMATCH_SQL, parameters, new LookupTradeMapper());
		if (db_result != null) {
			result = db_result;

			SqlParameterSource updateParameters = new MapSqlParameterSource("id", result.getId());
			int status = namedParameterJdbcTemplate.update(UPDATE_MISMATCHED_TRADE, updateParameters);

			if (status == 1) {
				log.debug("Successfully updated MISMATCHED status: " + result.getId());
			} else {
				// somehow update failed.
				log.error("found MISMATCHED record but can't update the state: " + result.getId());
			}
		}
		}
		catch (EmptyResultDataAccessException e) { // result.size() == 0;
			log.info("No MisMatch found - return null");
			return null;
		}
		return result;
	}

	class LookupTradeMapper implements RowMapper<LookupTrade> {

		@Override
		public LookupTrade mapRow(ResultSet rs, int rowNum) throws SQLException {
			LookupTrade lookupTrade = new LookupTrade();
			lookupTrade.setId(rs.getLong("id"));
			return lookupTrade;
		}

	}
}
