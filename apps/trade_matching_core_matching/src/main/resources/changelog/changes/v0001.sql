-- // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
-- // SPDX-License-Identifier: MIT-0
create table "trade_message" (
  id serial primary key,
  uuid varchar(50) not null,
  curr_date varchar(40) not null,
  curr_time varchar(40) not null,
  sender_id varchar(20) not null,
  im_id varchar(20) not null,
  broker_id varchar(20) not null,
  trade_id varchar(10) not null,
  security varchar(10) not null,
  transaction_indicator char(1) not null,
  price numeric(10,2) not null,
  quantity integer not null,
  trade_date timestamp not null,
  settlement_date timestamp not null,
  delivery_instructions varchar(50) not null,
  status varchar(20) not null
);


create table "trade_allocation" (
  id serial primary key,
  trade_allocation_id bigint not null,
  trade_message_id bigint not null,
  allocation_quantity integer not null,
  allocation_account varchar(20) not null,
  allocation_status varchar(20) not null,
  constraint fk_trade_message
        foreign key(trade_message_id)
  	  references trade_message(id)
);
--
--    private String id;
--    private String senderID;
--    private String imID;
--    private String brokerID;
--    private String tradeID;
--    private String security;
--    private String transactionIndicator;    //  Can be ‘B’ for Buy or ‘S’ for Sell.
--    private double price;
--    private int quantity;
--    private Instant tradeDate;
--    private Instant settlementDate;
--    private String deliveryInstructions;
--    private String status;                  // Valid values are ‘Unmatched’, ‘Mismatched’, ‘Matched’, ‘Cancelled’, and ‘Settled’
--    private int allocationID;  // A counter beginning at 1, incrementing for each allocation associated with the block
--    private int allocationQuantity;         // Will be a value up to 100% of the Block quantity. For 1 allocation, this quantity will be equal to the Block quantity.
--    private String allocationAccount;       // an account for whom the IM made the trade
--    private String allocationStatus;
--