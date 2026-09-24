// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

output "lambda_bucket_name" {

  description = "Name of the S3 bucket used to store function code."

  value = aws_s3_bucket.lambda_bucket.id
}

output "ui_config" {

  description = "Endpoint/key map used to generate the dashboard UI config (see ../generate_ui_config.sh)"
  sensitive   = true

  value = {
    APP_STATE_ENDPOINTS           = { Endpoint = module.app_state.invoke_url, ApiKey = module.app_state.api_key_value, Resource = "app_state" }
    APP_STATES_ENDPOINTS          = { Endpoint = module.app_states.invoke_url, ApiKey = module.app_states.api_key_value, Resource = "app_states" }
    APP_CONTROLS_ENDPOINTS        = { Endpoint = module.app_controls.invoke_url, ApiKey = module.app_controls.api_key_value, Resource = "app_controls" }
    ARC_CONTROL_ENDPOINTS         = { Endpoint = module.arc_control.invoke_url, ApiKey = module.arc_control.api_key_value, Resource = "arc_control" }
    RUNBOOK_ENDPOINTS             = { Endpoint = module.execute_run_book.invoke_url, ApiKey = module.execute_run_book.api_key_value, Resource = "runbook" }
    APP_RECONS_ENDPOINTS          = { Endpoint = module.app_recons.invoke_url, ApiKey = module.app_recons.api_key_value, Resource = "app_recons" }
    APP_RECON_STEP_ENDPOINTS      = { Endpoint = module.app_recon_step.invoke_url, ApiKey = module.app_recon_step.api_key_value, Resource = "app_recon_step" }
    APP_READY_ENDPOINTS           = { Endpoint = module.app_ready.invoke_url, ApiKey = module.app_ready.api_key_value, Resource = "app_ready" }
    APP_HEALTH_ENDPOINTS          = { Endpoint = module.app_health.invoke_url, ApiKey = module.app_health.api_key_value, Resource = "app_health" }
    APP_REPLICATION_ENDPOINTS     = { Endpoint = module.app_replication.invoke_url, ApiKey = module.app_replication.api_key_value, Resource = "app_replication" }
    START_APP_ENDPOINTS           = { Endpoint = module.start_app.invoke_url, ApiKey = module.start_app.api_key_value, Resource = "start_app" }
    STOP_APPS_ENDPOINTS           = { Endpoint = module.stop_apps.invoke_url, ApiKey = module.stop_apps.api_key_value, Resource = "stop_apps" }
    CLEAN_DATABASES_ENDPOINTS     = { Endpoint = module.clean_databases.invoke_url, ApiKey = module.clean_databases.api_key_value, Resource = "clean_databases" }
    EXECUTIONS_ENDPOINTS          = { Endpoint = module.executions.invoke_url, ApiKey = module.executions.api_key_value, Resource = "executions" }
    EXECUTION_DETAIL_ENDPOINTS    = { Endpoint = module.execution_detail.invoke_url, ApiKey = module.execution_detail.api_key_value, Resource = "execution_detail" }
    EXPERIMENT_ENDPOINTS          = { Endpoint = module.experiment.invoke_url, ApiKey = module.experiment.api_key_value, Resource = "experiment" }
    START_APP_COMPONENT_ENDPOINTS = { Endpoint = module.start_app_component.invoke_url, ApiKey = module.start_app_component.api_key_value, Resource = "start_app_component" }
    ENABLE_VPC_ENDPOINTS          = { Endpoint = module.enable_vpc_endpoint.invoke_url, ApiKey = module.enable_vpc_endpoint.api_key_value, Resource = "enable_vpc_endpoint" }
  }
}

