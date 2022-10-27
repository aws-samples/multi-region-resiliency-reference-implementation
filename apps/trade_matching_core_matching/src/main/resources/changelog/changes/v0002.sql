-- // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
-- // SPDX-License-Identifier: MIT-0
alter table trade_message 
add constraint unique_trademessage unique (uuid);
