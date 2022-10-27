// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import { RouterState } from 'connected-react-router';

export interface IAppState {
  app_name?: string;
  app_region?: string;
  dns_arc_control_state?: string;
  queue_arc_control_state?: string;
  app_arc_control_state?: string;
  inbound_gateway_trade_store_count?: string;
  inbound_gateway_settlement_store_count?: string;
  ingestion_trade_store_count?: string;
  ingestion_settlement_store_count?: string;
  matching_store_count?: string;
  matching_settled_store_count?: string;
  matching_matched_store_count?: string;
  matching_mismatched_store_count?: string;
  matching_unmatched_store_count?: string;
  egress_trade_store_count?: string;
  egress_settlement_store_count?: string;
  outbound_gateway_trade_store_count?: string;
  outbound_gateway_settlement_store_count?: string;
}

export interface IAppControls {
  app_name?: string;
  app_region?: string;
  dns_arc_control_state?: string;
  queue_arc_control_state?: string;
  app_arc_control_state?: string;
}

export interface IAppRecon {
  app_name?: string;
  app_region?: string;
  inbound_ingress_trade_recon?: string;
  inbound_ingress_settlement_recon?: string;
  ingestion_core_trade_recon?: string;
  ingestion_core_settlement_recon?: string;
  core_egress_trade_recon?: string;
  core_egress_settlement_recon?: string;
  egress_outbound_trade_recon?: string;
  egress_outbound_settlement_recon?: string;
  outbound_other_inbound_trade_recon?: string;
  outbound_other_inbound_settlement_recon?: string;
}

export interface IAppReady {
  app_name?: string;
  summary?: string;
  control_dns?: string;
  control_queue?: string;
  control_app?: string;
  inbound_dynamodb_trade?: string;
  inbound_dynamodb_settlement?: string;
  inbound_ecs_primary?: string;
  inbound_ecs_secondary?: string;
  ingestion_dynamodb_trade?: string;
  ingestion_dynamodb_settlement?: string;
  ingestion_ecs_primary?: string;
  ingestion_ecs_secondary?: string;
  matching_rds?: string;
  matching_ecs_ingestion_primary?: string;
  matching_ecs_ingestion_secondary?: string;
  matching_ecs_matching_primary?: string;
  matching_ecs_matching_secondary?: string;
  egress_dynamodb_trade?: string;
  egress_dynamodb_settlement?: string;
  egress_ecs_primary?: string;
  egress_ecs_secondary?: string;
  outbound_dynamodb_trade?: string;
  outbound_dynamodb_settlement?: string;
  outbound_ecs_primary?: string;
  outbound_ecs_secondary?: string;
}

export interface IAppHealth {
  summary?: string;
  mq?: string;
  kinesis?: string;
  dynamodb?: string;
  rds?: string;
  ecs?: string;
}

export interface IAppReplication {
  summary?: string;
  app_name?: string;
  inbound_dynamodb_trade?: string;
  inbound_dynamodb_settlement?: string;
  ingestion_dynamodb_trade?: string;
  ingestion_dynamodb_settlement?: string;
  matching_rds?: string;
  egress_dynamodb_trade?: string;
  egress_dynamodb_settlement?: string;
  outbound_dynamodb_trade?: string;
  outbound_dynamodb_settlement?: string;
}

export interface IExecution {
  automation_execution_id?: string;
  document_name?: string;
  document_version?: string;
  automation_execution_status?: string;
  execution_start_time?: string;
  execution_end_time?: string;
  outputs?: string;
  mode?: string;
  current_step_name?: string;
  current_action?: string;
  automation_type?: string;
}

export interface IExecutionDetail {
  automation_execution_id?: string;
  document_name?: string;
  document_version?: string;
  automation_execution_status?: string;
  execution_start_time?: string;
  execution_end_time?: string;
  parameters?: string;
  outputs?: string;
  mode?: string;
  steps?: IExecutionStepDetail[];
}

export interface IExecutionStepDetail {
  step_number?: string;
  step_name?: string;
  action?: string;
  execution_start_time?: string;
  execution_end_time?: string;
  step_status?: string;
  input_payload?: string;
  output_payload?: string;
  execution_log?: string;
  step_execution_id?: string;
}

export interface IRequest {
  id?: string;
  requester?: string;
  request_account?: string;
  request_role?: string;
  request_duration?: string;
  request_justification?: string;
  request_status?: string;
  request_time?: string;
  expiration_time?: string;
  review_time?: string;
  reviewer?: string;
  request_url?: string;
}

export interface ICredential {
  accessKeyId: string;
  secretAccessKey: string;
  sessionToken: string;
}

export interface IError {
  Code?: string;
  Message?: string;
}

export interface IUserInfo {
  token: string;
  user: string;

  requester: boolean;
  reviewer: boolean;
  auditor: boolean;

  accountMap: Map<any, any>;
}

export interface ReduxState {
  executionId: string;
}

export interface ReduxRoot {
  router: RouterState;
  approtationReducerState: ReduxState;
}