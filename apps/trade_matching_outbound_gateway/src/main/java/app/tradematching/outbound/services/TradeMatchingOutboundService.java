// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.outbound.services;

import java.text.SimpleDateFormat;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.stream.Collector;
import java.util.stream.Collectors;

import app.tradematching.outbound.pojo.SafeStoreResponseMessage;
import app.tradematching.outbound.stream.OutboundStream;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import com.google.protobuf.Message;

import org.checkerframework.checker.units.qual.A;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import app.tradematching.outbound.dao.TradeMatchingOutboundDAO;
import app.tradematching.outbound.pojo.ResponseMessage;
import lombok.extern.slf4j.Slf4j;
import scala.collection.parallel.ParIterableLike.Collect;

@Service
@Slf4j
public class TradeMatchingOutboundService {

	@Autowired
	private TradeMatchingOutboundDAO dao;

	@Autowired
	private OutboundStream outboundStream;

	private ObjectMapper mapper = new ObjectMapper();

	public TradeMatchingOutboundService() {
		mapper.registerModule(new JavaTimeModule());
	}

	private SafeStoreResponseMessage safeStoreResponseMessageFromMessage(ResponseMessage message){
		return SafeStoreResponseMessage.builder()
				.id(message.getId()).currentDate(new SimpleDateFormat("yyyy-MM-dd").format(new Date()))
				.currentTime(new SimpleDateFormat("HH:mm:ss").format(new Date())).timestamp(message.getTimestamp())
				.status(message.getStatus()).description(message.getDescription())
				.destination(message.getDestination()).message(message.getMessage())
				.build();
	}

	public void processOutboundMessages(List<ResponseMessage> responseMessages) {
		List<SafeStoreResponseMessage> safeStoreResponseMessages =
				responseMessages.stream().map(this::safeStoreResponseMessageFromMessage).collect(Collectors.toList());
		dao.persistMessages(safeStoreResponseMessages);
		outboundStream.sendMessages(responseMessages);
	}
}