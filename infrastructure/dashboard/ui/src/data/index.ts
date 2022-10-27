// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

// @ts-ignore
import ApiHandler, {ApiMethod} from '../common/api'
import {
  IAppState,
  IAppControls,
  IAppRecon,
  IAppReady,
  IAppReplication,
  IAppHealth,
  IExecution, IExecutionDetail
} from '../interfaces/index'
import {
  APP_CONTROLS_ENDPOINTS,
  APP_HEALTH_ENDPOINTS,
  APP_READY_ENDPOINTS,
  APP_RECON_STEP_ENDPOINTS,
  APP_RECONS_ENDPOINTS,
  APP_REPLICATION_ENDPOINTS,
  APP_STATE_ENDPOINTS,
  APP_STATES_ENDPOINTS,
  ARC_CONTROL_ENDPOINTS,
  CLEAN_DATABASES_ENDPOINTS, ENABLE_VPC_ENDPOINTS,
  EXECUTION_DETAIL_ENDPOINTS,
  EXECUTIONS_ENDPOINTS,
  EXPERIMENT_ENDPOINTS,
  RUNBOOK_ENDPOINTS, START_APP_COMPONENT_ENDPOINTS,
  START_APP_ENDPOINTS,
  STOP_APPS_ENDPOINTS
} from '../config/index'

export const app_state_api = new ApiHandler(
    APP_STATE_ENDPOINTS.Endpoint,
    APP_STATE_ENDPOINTS.ApiKey,
    APP_STATE_ENDPOINTS.Resources
);

export const app_states_api = new ApiHandler(
    APP_STATES_ENDPOINTS.Endpoint,
    APP_STATES_ENDPOINTS.ApiKey,
    APP_STATES_ENDPOINTS.Resources
);

export const app_controls_api = new ApiHandler(
    APP_CONTROLS_ENDPOINTS.Endpoint,
    APP_CONTROLS_ENDPOINTS.ApiKey,
    APP_CONTROLS_ENDPOINTS.Resources
);

export const arc_control_api = new ApiHandler(
    ARC_CONTROL_ENDPOINTS.Endpoint,
    ARC_CONTROL_ENDPOINTS.ApiKey,
    ARC_CONTROL_ENDPOINTS.Resources
);

export const runbook_api = new ApiHandler(
    RUNBOOK_ENDPOINTS.Endpoint,
    RUNBOOK_ENDPOINTS.ApiKey,
    RUNBOOK_ENDPOINTS.Resources
);

export const app_recons_api = new ApiHandler(
    APP_RECONS_ENDPOINTS.Endpoint,
    APP_RECONS_ENDPOINTS.ApiKey,
    APP_RECONS_ENDPOINTS.Resources
);

export const app_recon_step_api = new ApiHandler(
    APP_RECON_STEP_ENDPOINTS.Endpoint,
    APP_RECON_STEP_ENDPOINTS.ApiKey,
    APP_RECON_STEP_ENDPOINTS.Resources
);

export const app_ready_api = new ApiHandler(
    APP_READY_ENDPOINTS.Endpoint,
    APP_READY_ENDPOINTS.ApiKey,
    APP_READY_ENDPOINTS.Resources
);

export const app_health_api = new ApiHandler(
    APP_HEALTH_ENDPOINTS.Endpoint,
    APP_HEALTH_ENDPOINTS.ApiKey,
    APP_HEALTH_ENDPOINTS.Resources
);

export const app_replication_api = new ApiHandler(
    APP_REPLICATION_ENDPOINTS.Endpoint,
    APP_REPLICATION_ENDPOINTS.ApiKey,
    APP_REPLICATION_ENDPOINTS.Resources
);

export const start_app_api = new ApiHandler(
    START_APP_ENDPOINTS.Endpoint,
    START_APP_ENDPOINTS.ApiKey,
    START_APP_ENDPOINTS.Resources
);

export const stop_apps_api = new ApiHandler(
    STOP_APPS_ENDPOINTS.Endpoint,
    STOP_APPS_ENDPOINTS.ApiKey,
    STOP_APPS_ENDPOINTS.Resources
);

export const clean_databases_api = new ApiHandler(
    CLEAN_DATABASES_ENDPOINTS.Endpoint,
    CLEAN_DATABASES_ENDPOINTS.ApiKey,
    CLEAN_DATABASES_ENDPOINTS.Resources
);

export const executions_api = new ApiHandler(
    EXECUTIONS_ENDPOINTS.Endpoint,
    EXECUTIONS_ENDPOINTS.ApiKey,
    EXECUTIONS_ENDPOINTS.Resources
);

export const execution_detail_api = new ApiHandler(
    EXECUTION_DETAIL_ENDPOINTS.Endpoint,
    EXECUTION_DETAIL_ENDPOINTS.ApiKey,
    EXECUTION_DETAIL_ENDPOINTS.Resources
);

export const experiment_api = new ApiHandler(
    EXPERIMENT_ENDPOINTS.Endpoint,
    EXPERIMENT_ENDPOINTS.ApiKey,
    EXPERIMENT_ENDPOINTS.Resources
);

export const start_app_component_api = new ApiHandler(
    START_APP_COMPONENT_ENDPOINTS.Endpoint,
    START_APP_COMPONENT_ENDPOINTS.ApiKey,
    START_APP_COMPONENT_ENDPOINTS.Resources
);

export const enable_vpc_endpoint_api = new ApiHandler(
    ENABLE_VPC_ENDPOINTS.Endpoint,
    ENABLE_VPC_ENDPOINTS.ApiKey,
    ENABLE_VPC_ENDPOINTS.Resources
);

export const getAppState = (app: string, region:string, user_params?:any) => app_state_api.get_resource<IAppState>(
    "app_state", ApiMethod.GET, null, [{key:"app", value:app}, {key:"region", value:region}])

export const getAppStates = (app: string, user_params?:any) => app_states_api.get_resource<IAppState[]>(
    "app_states", ApiMethod.GET, null, [{key:"app", value:app}])

export const getAppControls = (app: string, region:string, user_params?:any) => app_controls_api.get_resource<IAppControls>(
    "app_controls", ApiMethod.GET, null, [{key:"app", value:app}, {key:"region", value:region}])

export const updateArcControl = (app: string, scope:string, region:string, state:string, user_params?:any) => arc_control_api.get_resource<any>(
    "arc_control", ApiMethod.POST, {app: app, scope: scope, region: region, state: state}, [])

export const executeRunbook = (region: string, document:string, app:string, type:string, mode:string, user_params?:any) => runbook_api.get_resource<any>(
    "runbook", ApiMethod.POST, {region: region, document: document, app: app, type: type, mode: mode}, [])

export const getAppRecons = (app: string, user_params?:any) => app_recons_api.get_resource<IAppRecon[]>(
    "app_recons", ApiMethod.GET, null, [{key:"app", value:app}])

export const getAppReconStep = (recon: string, user_params?:any) => app_recon_step_api.get_resource<string>(
    "app_recon_step", ApiMethod.GET, null, [{key:"recon", value:recon}])

export const getAppReady = (app: string, user_params?:any) => app_ready_api.get_resource<IAppReady>(
    "app_ready", ApiMethod.GET, null, [{key:"app", value:app}])

export const getAppHealth = (user_params?:any) => app_health_api.get_resource<IAppHealth>(
    "app_health", ApiMethod.GET, null, [])

export const getAppReplication = (app: string, user_params?:any) => app_replication_api.get_resource<IAppReplication>(
    "app_replication", ApiMethod.GET, null, [{key:"app", value:app}])

export const startApplication = (app: string, region:string, user_params?:any) => start_app_api.get_resource<any>(
    "start_app", ApiMethod.POST, {app: app, region: region}, [])

export const stopApplications = (region:string, user_params?:any) => stop_apps_api.get_resource<any>(
    "stop_apps", ApiMethod.POST, {region: region}, [])

export const cleanDatabases = (user_params?:any) => clean_databases_api.get_resource<any>(
    "clean_databases", ApiMethod.POST, null, [])

export const getExecutions = (user_params?:any) => executions_api.get_resource<IExecution[]>(
    "executions", ApiMethod.GET, null, [])

export const getExecutionDetails = (id: string, user_params?:any) => execution_detail_api.get_resource<IExecutionDetail>(
    "execution_detail", ApiMethod.GET, null, [{key:"id", value:id}])

export const runExperiment = (region: string, name:string, user_params?:any) => experiment_api.get_resource<any>(
    "experiment", ApiMethod.POST, {region: region, name: name}, [])

export const startAppComponent = (region:string, app: string, component:string,  user_params?:any) => start_app_component_api.get_resource<any>(
    "start_app_component", ApiMethod.POST, {region: region, app: app, component: component}, [])

export const enableVPCEndpoint = (region:string, app: string, service:string,  user_params?:any) => enable_vpc_endpoint_api.get_resource<any>(
    "enable_vpc_endpoint", ApiMethod.POST, {region: region, app: app, service: service}, [])

//export const getAppState = (user_params?:any) => api.get_resource<IAppState[]>(ApiMethod.GET,null,[])

// export const getAppState = (app: string, region:string, user_params?:any) => api.get_authorized_resource<IAppState>(
//     "state", ApiMethod.GET, {app: app, region: region}, [])

// export const getRequests = (token: string, user_params?:any) => api.get_authorized_resource<IRequest[]>(
//     "get_requests", token, ApiMethod.GET,null,[])
//
// export const getPendingRequests = (token: string, user_params?:any) => api.get_authorized_resource<IRequest[]>(
//     "get_pending_requests", token, ApiMethod.GET,null,[])
//
// export const getProcessedRequests = (token: string, user_params?:any) => api.get_authorized_resource<IRequest[]>(
//     "get_processed_requests", token, ApiMethod.GET,null,[])
//
// export const getAllRequests = (token: string, user_params?:any) => api.get_authorized_resource<IRequest[]>(
//     "get_all_requests", token, ApiMethod.GET,null,[])
//
// export const createRequest = (token: string, request_account:any, request_role:any, request_duration:any, request_justification:any, user_params?:any) => api.get_authorized_resource<any>(
//     "create_request", token, ApiMethod.POST, {request_account: request_account, request_role: request_role, request_duration: request_duration, request_justification: request_justification}, [])
//
// export const deleteRequest = (token: string, id:any, request_time:any, user_params?:any) => api.get_authorized_resource<any>(
//     "delete_request", token, ApiMethod.POST, {id: id, request_time: request_time}, [])
//
// export const approveRequest = (token: string, id:any, request_time:any, request_duration:any, reviewer:any, user_params?:any) => api.get_authorized_resource<any>(
//     "approve_request", token, ApiMethod.POST, {id: id, request_time: request_time, request_duration: request_duration, reviewer: reviewer}, [])
//
// export const rejectRequest = (token: string, id:any, request_time:any, reviewer:any, user_params?:any) => api.get_authorized_resource<any>(
//     "reject_request", token, ApiMethod.POST, {id: id, request_time: request_time, reviewer: reviewer}, [])
//
// export const updateRequestURL = (token: string, id:any, request_time:any, request_url:any, user_params?:any) => api.get_authorized_resource<any>(
//     "update_request_url", token, ApiMethod.POST, {id: id, request_time: request_time, request_url: request_url}, [])
//
// export const invokeFederateConsole = (token: string, account:any, role:any, user_params?:any) => api.get_authorized_resource<any>(
//     "federate_console", token, ApiMethod.GET,null,[{key:"account", value:account}, {key:"role", value:role}])
//
// export const invokeFederateCli = (token: string, account:any, role:any, user_params?:any) => api.get_authorized_resource<ICredential>(
//     "federate_cli", token, ApiMethod.GET,null,[{key:"account", value:account}, {key:"role", value:role}])
