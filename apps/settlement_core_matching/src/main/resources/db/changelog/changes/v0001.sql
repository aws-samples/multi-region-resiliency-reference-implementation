-- // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
-- // SPDX-License-Identifier: MIT-0
create table "settlement_message" (
  db_id serial primary key,
  id varchar(50) not null unique,
  curr_date varchar(40) not null,
  curr_time varchar(40) not null,
  timestamp bigint not null,
  sender_id varchar(20) not null,
  im_id varchar(20) not null,
  broker_id varchar(20) not null,
  trade_id varchar(10) not null,
  allocation_id bigint not null,
  quantity integer not null,
  security varchar(10) not null,
  transaction_indicator char(1) not null,
  price numeric(10,2) not null,
  trade_date timestamp not null,
  settlement_date timestamp not null,
  delivery_instructions varchar(50) not null,
  status varchar(20) not null,
  account varchar(20) not null
);
CREATE INDEX IF NOT EXISTS timestamp_idx ON settlement_message (timestamp);
