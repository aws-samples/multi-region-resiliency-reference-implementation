# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

import logging
from unittest import result
import boto3
from datetime import datetime, timedelta
import time

from utilities.util import find_diff, distribute_messages_to_kinesis, query_rds, query_rds_realdict, \
    check_table_exist, create_table, add_reconciliation_record, distribute_message_activemq
from utilities.mappers import inbound_ingress_mapper, ingress_core_mapper, core_db_trades_mapper, core_egress_mapper, \
    egress_outbound_mapper, egress_outbound_settlement_mapper, settlement_inbound_ingress_mapper, \
    settlement_ingress_core_mapper, settlement_core_egress_mapper, settlement_egress_outbound_mapper, \
    core_settlement_db_trades_mapper, trade_matching_settlement_outbound_inbound_settlement_mapper, \
    settlement_outbound_trade_matching_inbound_settlement_mapper, inbound_ingress_settlement_mapper, \
    ingress_core_settlement_mapper


def inbound_ingress_reconciliation(region, params):
    logging.info("Starting InboundIngress Reconciliation")
    try:
        if not handle_audit_table(params, region):
            raise Exception("Error creating audit table")

        add_reconciliation_record(params["reconciliation_table"], region, "InboundIngress", "Trades", "Started")
        inbound_items = query_source_dynamodb_trades(
            params["rollback_time_in_sec"],
            params["dynamodb_tm_inbound_t_table"],
            region)

        # logging.info(inbound_items)
        logging.info("Checking for {0} records".format(len(inbound_items)))

        missing_items = query_destination_dynamodb_trades(
            inbound_items,
            params["rollback_time_in_sec"],
            params["dynamodb_tm_ingress_t_table"],
            region)

        # trade_to_reconcile = find_diff(inbound_items, ingress_items)
        logging.info("Found {0} Messages to Reconcile".format(len(missing_items)))

        #pull full records for missing items
        source_full_records = query_source_dynamodb_full_records(missing_items,
                                                                 params["rollback_time_in_sec"],
                                                                 params["dynamodb_tm_inbound_t_table"],
                                                                 region)
        logging.info("Recovered {0} Messages from Origin".format(len(source_full_records)))
        distribute_messages_to_kinesis(stream_name=params["kinesis_stream_ingress_t"],
                                       region=region,
                                       records=missing_items,
                                       source=source_full_records,
                                       mapping_func=inbound_ingress_mapper)
        add_reconciliation_record(params["reconciliation_table"],
                                  region, "InboundIngress",
                                  "Trades",
                                  "Finished",
                                  len(inbound_items),
                                  len(missing_items),
                                  "Processed {0} Trades".format(len(missing_items)))
    except Exception as e:
        logging.error("Error in inbound_ingress_reconciliation", e)
    logging.info("Finished InboundIngress Reconciliation")
    # Calling settlement recon
    inbound_ingress_settlement_reconciliation(region, params)


def inbound_ingress_settlement_reconciliation(region, params):
    logging.info("Starting InboundIngress Settlement Reconciliation")
    try:
        if not handle_audit_table(params, region):
            raise Exception("Error creating audit table")

        add_reconciliation_record(params["reconciliation_table"], region, "InboundIngress", "Settlements", "Started")
        inbound_items = query_source_dynamodb_trades(
            params["rollback_time_in_sec"],
            params["dynamodb_tm_inbound_st_table"],
            region)

        # logging.info(inbound_items)
        logging.info("Checking for {0} records".format(len(inbound_items)))

        missing_items = query_destination_dynamodb_trades(
            inbound_items,
            params["rollback_time_in_sec"],
            params["dynamodb_tm_ingress_st_table"],
            region)

        # trade_to_reconcile = find_diff(inbound_items, ingress_items)
        logging.info("Found {0} Messages to Reconcile".format(len(missing_items)))

        #pull full records for missing items

        source_full_records = query_source_dynamodb_full_records(missing_items,
                                                                 params["rollback_time_in_sec"],
                                                                 params["dynamodb_tm_inbound_st_table"],
                                                                 region)

        distribute_messages_to_kinesis(stream_name=params["kinesis_stream_ingress_st"],
                                       region=region,
                                       records=missing_items,
                                       source=source_full_records,
                                       mapping_func=inbound_ingress_settlement_mapper)
        add_reconciliation_record(params["reconciliation_table"],
                                  region, "InboundIngress",
                                  "Settlements",
                                  "Finished",
                                  len(inbound_items),
                                  len(missing_items),
                                  "Processed {0} Settlements".format(len(missing_items)))
    except Exception as e:
        logging.error("Error in inbound_ingress_settlement_reconciliation", e)
    logging.info("Finished InboundIngress Settlement Reconciliation")


def ingress_core_reconciliation(region, params):
    logging.info("Starting ingress_core Reconciliation")
    try:
        if not handle_audit_table(params, region):
            raise Exception("Error creating audit table")
        add_reconciliation_record(params["reconciliation_table"], region, "IngressCore", "Trades", "Started")

        ingress_items = query_source_dynamodb_trades(params["rollback_time_in_sec"],
                                                     params["dynamodb_tm_ingress_t_table"],
                                                     region)

        logging.info("Checking for {0} records".format(len(ingress_items)))

        missing_items = query_destination_rds_trades(ingress_items, params["trade_matching_core_database"], region)

        logging.info("Found {0} Messages to Reconcile".format(len(missing_items)))

        source_full_records = query_source_dynamodb_full_records(missing_items,
                                                                 params["rollback_time_in_sec"],
                                                                 params["dynamodb_tm_ingress_t_table"],
                                                                 region)

        distribute_messages_to_kinesis(stream_name=params["kinesis_stream_core_t"],
                                       region=region,
                                       records=missing_items,
                                       source=source_full_records,
                                       mapping_func=ingress_core_mapper)

        add_reconciliation_record(params["reconciliation_table"],
                                  region, "IngressCore",
                                  "Trades",
                                  "Finished",
                                  len(ingress_items),
                                  len(missing_items),
                                  "Processed {0} Trades".format(len(missing_items)))
    except Exception as e:
        logging.error("Error in ingress_core_reconciliation", e)
    logging.info("Finished ingress_core Reconciliation")
    # ingress_core_settlement_reconciliation(region, params)


# def ingress_core_settlement_reconciliation(region, params):
#     logging.info("Starting ingress_core Settlement Reconciliation")
#     try:
#         if not handle_audit_table(params, region):
#             raise Exception("Error creating audit table")
#         add_reconciliation_record(params["reconciliation_table"], region, "IngressCore", "Settlements", "Started")
#
#         ingress_items = query_source_dynamodb_trades(params["rollback_time_in_sec"],
#                                                      params["dynamodb_tm_ingress_st_table"],
#                                                      region)
#
#         logging.info("Checking for {0} records".format(len(ingress_items)))
#
#         missing_items = query_settlement_destination_rds_trades(ingress_items, params["settlement_core_database"], region)
#
#         logging.info("Found {0} Messages to Reconcile".format(len(missing_items)))
#
#         source_full_records = query_source_dynamodb_full_records(missing_items,
#                                                                  params["rollback_time_in_sec"],
#                                                                  params["dynamodb_tm_ingress_st_table"],
#                                                                  region)
#
#         distribute_messages_to_kinesis(stream_name=params["kinesis_stream_core_st"],
#                                        region=region,
#                                        records=missing_items,
#                                        source=source_full_records,
#                                        mapping_func=ingress_core_settlement_mapper)
#
#         add_reconciliation_record(params["reconciliation_table"],
#                                   region, "IngressCore",
#                                   "Settlements",
#                                   "Finished",
#                                   len(ingress_items),
#                                   len(missing_items),
#                                   "Processed {0} Settlements".format(len(missing_items)))
#     except Exception as e:
#         logging.error("Error in ingress_core_settlement_reconciliation", e)
#     logging.info("Finished ingress_core Settlement Reconciliation")


def core_egress_reconciliation(region, params):
    logging.info("Starting CoreEgress Reconciliation")
    try:
        if not handle_audit_table(params, region):
            raise Exception("Error creating audit table")
        add_reconciliation_record(params["reconciliation_table"], region, "CoreEgress", "Trades", "Started")

        core_items = query_source_rds_trades(params["rollback_time_in_sec"], params["trade_matching_core_database"],
                                             region)
        # logging.info(core_items)
        logging.info("Checking for {0} records".format(len(core_items)))
        ids = []
        for item in core_items:
            ids.append(item["uuid"])

        missing_items = query_destination_dynamodb_trades(
            ids,
            params["rollback_time_in_sec"],
            params["dynamodb_tm_egress_t_table"],
            region)

        logging.info("Found {0} Messages to Reconcile".format(len(missing_items)))

        distribute_messages_to_kinesis(stream_name=params["kinesis_stream_egress_t"],
                                       region=region,
                                       records=missing_items,
                                       source=core_items,
                                       mapping_func=core_egress_mapper,
                                       override_partition_key=True)

        add_reconciliation_record(params["reconciliation_table"],
                                  region, "CoreEgress",
                                  "Trades",
                                  "Finished",
                                  len(ids),
                                  len(missing_items),
                                  "Processed {0} Trades".format(len(missing_items)))
    except Exception as e:
        logging.error("Error in core_egress_reconciliation", e)
    logging.info("Finished CoreEgress Reconciliation")


def egress_outbound_reconciliation(region, params):
    logging.info("Starting EgressOutbound Reconciliation")
    try:
        if not handle_audit_table(params, region):
            raise Exception("Error creating audit table")
        add_reconciliation_record(params["reconciliation_table"], region, "EgressOutbound", "Trades", "Started")
        add_reconciliation_record(params["reconciliation_table"], region, "EgressOutbound", "Settlement", "Started")

        egress_items = query_source_dynamodb_trades(params["rollback_time_in_sec"], params["dynamodb_tm_egress_t_table"],
                                                    region)
        egress_settlement_items = query_source_dynamodb_trades(params["rollback_time_in_sec"],
                                                               params["dynamodb_tm_egress_st_table"], region)

        logging.info("Checking for {0} Trades records".format(len(egress_items)))
        logging.info("Checking for {0} Settlement records".format(len(egress_settlement_items)))
        # logging.info(inbound_items)

        missing_items = query_destination_dynamodb_trades(
            egress_items,
            params["rollback_time_in_sec"],
            params["dynamodb_tm_outbound_t_table"],
            region)

        missing_settlement_items = query_destination_dynamodb_trades(
            egress_settlement_items,
            params["rollback_time_in_sec"],
            params["dynamodb_tm_outbound_st_table"],
            region)

        logging.info("Found {0} Trades Messages to Reconcile".format(len(missing_items)))
        logging.info("Found {0} Settlements Messages to Reconcile".format(len(missing_settlement_items)))

        source_full_records = query_source_dynamodb_full_records(missing_items,
                                                                 params["rollback_time_in_sec"],
                                                                 params["dynamodb_tm_egress_t_table"],
                                                                 region)

        source_full_settlements_records = query_source_dynamodb_full_records(missing_settlement_items,
                                                                 params["rollback_time_in_sec"],
                                                                 params["dynamodb_tm_egress_st_table"],
                                                                 region)

        distribute_messages_to_kinesis(stream_name=params["kinesis_stream_outbound_t"],
                                       region=region,
                                       records=missing_items,
                                       source=source_full_records,
                                       mapping_func=egress_outbound_mapper)

        distribute_messages_to_kinesis(stream_name=params["kinesis_stream_outbound_st"],
                                       region=region,
                                       records=missing_settlement_items,
                                       source=source_full_settlements_records,
                                       mapping_func=egress_outbound_settlement_mapper)

        add_reconciliation_record(params["reconciliation_table"],
                                  region, "EgressOutbound",
                                  "Trades",
                                  "Finished",
                                  len(egress_items),
                                  len(missing_items),
                                  "Processed {0} Trades".format(len(missing_items)))

        add_reconciliation_record(params["reconciliation_table"],
                                  region, "EgressOutbound",
                                  "Settlement",
                                  "Finished",
                                  len(egress_settlement_items),
                                  len(missing_settlement_items),
                                  "Processed {0} Settlements".format(len(missing_settlement_items)))

    except Exception as e:
        logging.error("Error in egress_outbound_reconciliation", e)
    logging.info("Finished EgressOutbound Reconciliation")


def outbound_settlement_inbound_reconciliation(region, params):
    logging.info("Starting Outbound Settlement Inbound Reconciliation")
    try:
        if not handle_audit_table(params, region):
            raise Exception("Error creating audit table")
        add_reconciliation_record(params["reconciliation_table"], region, "OutboundSettlementInbound", "Settlements",
                                  "Started")

        outbound_items = query_source_dynamodb_trades(params["rollback_time_in_sec"],
                                                      params["dynamodb_tm_outbound_st_table"],
                                                      region)
        # logging.info(core_items)
        logging.info("Checking for {0} records".format(len(outbound_items)))

        missing_items = query_destination_dynamodb_trades(
            outbound_items,
            params["rollback_time_in_sec"],
            params["dynamodb_st_inbound_st_table"],
            region)

        logging.info("Found {0} Messages to Reconcile".format(len(missing_items)))

        source_full_records = query_source_dynamodb_full_records(missing_items,
                                                                 params["rollback_time_in_sec"],
                                                                 params["dynamodb_tm_outbound_st_table"],
                                                                 region)

        distribute_message_activemq(source=source_full_records,
                                    records=missing_items,
                                    activemq_params=params["settlement_in_gateway_mq"],
                                    region=region,
                                    mapping_func=trade_matching_settlement_outbound_inbound_settlement_mapper)

        add_reconciliation_record(params["reconciliation_table"],
                                  region, "OutboundSettlementInbound",
                                  "Settlements",
                                  "Finished",
                                  len(outbound_items),
                                  len(missing_items),
                                  "Processed {0} Settlements".format(len(missing_items)))

    except Exception as e:
        logging.error("Error in outbound_settlement_inbound_reconciliation", e)
    logging.info("Finished Outbound Settlement Inbound Reconciliation")


def settlement_inbound_ingress_reconciliation(region, params):
    logging.info("Starting SettlementInboundIngress Reconciliation")
    try:
        if not handle_audit_table(params, region):
            raise Exception("Error creating audit table")
        add_reconciliation_record(params["reconciliation_table"], region,
                                  "SettlementInboundIngress",
                                  "Settlements", "Started")
        inbound_items = query_source_dynamodb_trades(params["rollback_time_in_sec"],
                                                     params["dynamodb_st_inbound_st_table"],
                                                     region)

        logging.info("Checking for {0} records".format(len(inbound_items)))

        missing_items = query_destination_dynamodb_trades(
            inbound_items,
            params["rollback_time_in_sec"],
            params["dynamodb_st_ingress_st_table"],
            region)

        logging.info("Found {0} Messages to Reconcile".format(len(missing_items)))

        source_full_records = query_source_dynamodb_full_records(missing_items,
                                                                 params["rollback_time_in_sec"],
                                                                 params["dynamodb_st_inbound_st_table"],
                                                                 region)

        distribute_messages_to_kinesis(stream_name=params["kinesis_settlement_stream_ingress"],
                                       region=region,
                                       records=missing_items,
                                       source=source_full_records,
                                       mapping_func=settlement_inbound_ingress_mapper)

        add_reconciliation_record(params["reconciliation_table"],
                                  region, "SettlementInboundIngress",
                                  "Settlements",
                                  "Finished",
                                  len(inbound_items),
                                  len(missing_items),
                                  "Processed {0} Settlements".format(len(missing_items)))
    except Exception as e:
        logging.error("Error in settlement_inbound_ingress_reconciliation", e)
    logging.info("Finished SettlementInboundIngress Reconciliation")


def settlement_ingress_core_reconciliation(region, params):
    logging.info("Starting SettlementIngressCore Reconciliation")
    try:
        if not handle_audit_table(params, region):
            raise Exception("Error creating audit table")
        add_reconciliation_record(params["reconciliation_table"], region, "SettlementIngressCore",
                                  "Settlements", "Started")

        ingress_items = query_source_dynamodb_trades(params["rollback_time_in_sec"],
                                                     params["dynamodb_st_ingress_st_table"],
                                                     region)

        logging.info("Checking for {0} records".format(len(ingress_items)))

        missing_items = query_settlement_destination_rds_trades(ingress_items, params["settlement_core_database"], region)

        logging.info("Found {0} Messages to Reconcile".format(len(missing_items)))

        source_full_records = query_source_dynamodb_full_records(missing_items,
                                                                 params["rollback_time_in_sec"],
                                                                 params["dynamodb_st_ingress_st_table"],
                                                                 region)

        distribute_messages_to_kinesis(stream_name=params["kinesis_settlement_stream_core"],
                                       region=region,
                                       records=missing_items,
                                       source=source_full_records,
                                       mapping_func=settlement_ingress_core_mapper)

        add_reconciliation_record(params["reconciliation_table"],
                                  region, "SettlementIngressCore",
                                  "Settlements",
                                  "Finished",
                                  len(ingress_items),
                                  len(missing_items),
                                  "Processed {0} Settlements".format(len(missing_items)))
    except Exception as e:
        logging.error("Error in settlement_ingress_core_reconciliation", e)
    logging.info("Finished SettlementIngressCore Reconciliation")


def settlement_core_egress_reconciliation(region, params):
    logging.info("Starting SettlementCoreEgress Reconciliation")
    try:
        if not handle_audit_table(params, region):
            raise Exception("Error creating audit table")
        add_reconciliation_record(params["reconciliation_table"], region, "SettlementCoreEgress",
                                  "Settlements", "Started")

        core_items = query_settlement_source_rds_trades(params["rollback_time_in_sec"],
                                                        params["settlement_core_database"],
                                                        region)
        # logging.info(core_items)
        logging.info("Checking for {0} records".format(len(core_items)))
        ids = []
        for item in core_items:
            ids.append(item["id"])

        missing_items = query_destination_dynamodb_trades(
            ids,
            params["rollback_time_in_sec"],
            params["dynamodb_st_egress_st_table"],
            region)

        logging.info("Found {0} Messages to Reconcile".format(len(missing_items)))

        distribute_messages_to_kinesis(stream_name=params["kinesis_settlement_stream_egress"],
                                       region=region,
                                       records=missing_items,
                                       source=core_items,
                                       mapping_func=settlement_core_egress_mapper)

        add_reconciliation_record(params["reconciliation_table"],
                                  region, "SettlementCoreEgress",
                                  "Settlements",
                                  "Finished",
                                  len(core_items),
                                  len(missing_items),
                                  "Processed {0} Settlements".format(len(missing_items)))

    except Exception as e:
        logging.error("Error in settlement_core_egress_reconciliation", e)
    logging.info("Finished SettlementCoreEgress Reconciliation")


def settlement_egress_outbound_reconciliation(region, params):
    logging.info("Starting SettlementEgressOutbound Reconciliation")
    try:
        if not handle_audit_table(params, region):
            raise Exception("Error creating audit table")
        add_reconciliation_record(params["reconciliation_table"], region, "SettlementEgressOutbound",
                                  "Settlement", "Started")

        egress_settlement_items = query_source_dynamodb_trades(params["rollback_time_in_sec"],
                                                               params["dynamodb_st_egress_st_table"], region)

        logging.info("Checking for {0} Settlement records".format(len(egress_settlement_items)))

        missing_settlement_items = query_destination_dynamodb_trades(
            egress_settlement_items,
            params["rollback_time_in_sec"],
            params["dynamodb_st_outbound_st_table"],
            region)

        logging.info("Found {0} Settlements Messages to Reconcile".format(len(missing_settlement_items)))

        source_full_records = query_source_dynamodb_full_records(missing_settlement_items,
                                                                 params["rollback_time_in_sec"],
                                                                 params["dynamodb_st_ingress_st_table"],
                                                                 region)

        distribute_messages_to_kinesis(stream_name=params["kinesis_settlement_stream_outbound"],
                                       region=region,
                                       records=missing_settlement_items,
                                       source=source_full_records,
                                       mapping_func=settlement_egress_outbound_mapper)

        add_reconciliation_record(params["reconciliation_table"],
                                  region, "SettlementEgressOutbound",
                                  "Settlements",
                                  "Finished",
                                  len(egress_settlement_items),
                                  len(missing_settlement_items),
                                  "Processed {0} Settlements".format(len(missing_settlement_items)))

    except Exception as e:
        logging.error("Error in settlement_egress_outbound_reconciliation", e)
    logging.info("Finished SettlementEgressOutbound Reconciliation")


def settlement_outbound_trade_inbound_reconciliation(region, params):
    logging.info("Starting SettlementOutboundTradeInbound Reconciliation")
    try:
        if not handle_audit_table(params, region):
            raise Exception("Error creating audit table")

        add_reconciliation_record(params["reconciliation_table"], region, "SettlementOutboundTradeInbound",
                                  "Settlement", "Started")

        outbound_settlement_items = query_source_dynamodb_trades(params["rollback_time_in_sec"],
                                                                 params["dynamodb_st_outbound_st_table"], region)

        logging.info("Checking for {0} Settlement records".format(len(outbound_settlement_items)))

        missing_settlement_items = query_destination_dynamodb_trades(
            outbound_settlement_items,
            params["rollback_time_in_sec"],
            params["dynamodb_tm_inbound_st_table"],
            region)

        logging.info("Found {0} Settlements Messages to Reconcile".format(len(missing_settlement_items)))

        source_full_records = query_source_dynamodb_full_records(missing_settlement_items,
                                                                 params["rollback_time_in_sec"],
                                                                 params["dynamodb_st_outbound_st_table"],
                                                                 region)

        distribute_message_activemq(source=source_full_records,
                                    records=missing_settlement_items,
                                    activemq_params=params["trade_matching_in_gateway_mq"],
                                    region=region,
                                    mapping_func=settlement_outbound_trade_matching_inbound_settlement_mapper,
                                    queue_name="settlements")

        add_reconciliation_record(params["reconciliation_table"],
                                  region, "SettlementOutboundTradeInbound",
                                  "Settlements",
                                  "Finished",
                                  len(outbound_settlement_items),
                                  len(missing_settlement_items),
                                  "Processed {0} Settlements".format(len(missing_settlement_items)))
    except Exception as e:
        logging.error("Error in settlement_outbound_trade_inbound_reconciliation", e)
    logging.info("Finished SettlementOutboundTradeInbound Reconciliation")


def get_partition_dates(rollback_time_in_sec: str) -> []:
    # logging.info(rollback_time_in_sec)
    partition_dates = []
    delta = timedelta(days=1)
    now = datetime.now()
    end_date = now.date()
    diff = now - timedelta(seconds=int(rollback_time_in_sec))
    start_date = diff.date()

    while start_date <= end_date:
        partition_dates.append(start_date.strftime("%Y-%m-%d"))
        start_date += delta
    logging.info(partition_dates)
    return partition_dates


def dynamodb_query_with_paging(dynamodb_client,params):
    results = []
    response = dynamodb_client.query(**params)
    if response["Count"] > 0:
        # extract current response results
        results.extend(response['Items'])
        while 'LastEvaluatedKey' in response:
            key = response['LastEvaluatedKey']
            params["ExclusiveStartKey"] = key
            response = dynamodb_client.query(**params) #,ExclusiveStartKey=key    
            if response["Count"] > 0:
                # extract current response results
                results.extend(response['Items'])
    return results


def query_source_dynamodb_trades(rollback_time_in_sec: str, table_name: str, region: str):
    partition_dates = get_partition_dates(rollback_time_in_sec)
    dynamodb_client = boto3.client("dynamodb", region_name=region)
    start_time = str(int(time.time() - int(rollback_time_in_sec)))
    for day in partition_dates:
        logging.info("Querying {0} for : {1}".format(table_name, day))
        params = {
            "TableName": table_name,
            "IndexName": "currentDate",
            "KeyConditionExpression":"#currentDate = :currentDate and #timestamp > :timestamp",
            "ExpressionAttributeNames":{
                "#currentDate": "currentDate", "#timestamp": "timestamp"
                },
            "ExpressionAttributeValues":{
                ':currentDate': {'S': day},
                ":timestamp": {"N": start_time}
            },
            "ProjectionExpression":"id",
            "ScanIndexForward": False
        }
        #logging.info(params)
        response = dynamodb_query_with_paging(dynamodb_client, params)
        
    ids = []
    for item in response:
        ids.append(item["id"]["S"])
    return ids


def query_source_dynamodb_full_records(ids: [], rollback_time_in_sec: str, table_name: str, region: str):
    results = []
    dynamodb_client = boto3.client("dynamodb", region_name=region)
    for trx_id in ids:
        params = {
            "TableName": table_name,
            "KeyConditionExpression":'id = :id',
            "ExpressionAttributeValues":{
                ":id": {"S": trx_id }},
            "ScanIndexForward": False
        }
        
        #logging.info(params)
        response = dynamodb_query_with_paging(dynamodb_client, params)
        if len(response) == 1:
            results.append(response[0])
    return results


def query_destination_dynamodb_trades(source_ids: [], rollback_time_in_sec: str, table_name: str, region: str):
    results = []
    partition_dates = get_partition_dates(rollback_time_in_sec)
    dynamodb_client = boto3.client("dynamodb", region_name=region)
    start_time = str(int(time.time() - int(rollback_time_in_sec)))
    for day in partition_dates:
        logging.info("Querying Destination {0} for : {1}".format(table_name, day))
        params = {
            "TableName": table_name,
            "IndexName": "currentDate",
            "KeyConditionExpression":"#currentDate = :currentDate and #timestamp > :timestamp",
            "ExpressionAttributeNames":{
                "#currentDate": "currentDate", "#timestamp": "timestamp"
                },
            "ExpressionAttributeValues":{
                ':currentDate': {'S': day},
                ":timestamp": {"N": start_time}
            },
            "ProjectionExpression":"id",
            "ScanIndexForward": False
        }
        #logging.info(params)
        response = dynamodb_query_with_paging(dynamodb_client, params)
        for item in response:
            if item["id"]["S"] in source_ids:
                results.append(item["id"]["S"])

    return find_diff(source_ids, results)


def query_destination_rds_trades(source_trades: [], db_params: dict, region: str):
    results = []
    if len(source_trades) == 0:
        return results
    ids = str(",".join("'{0}'".format(i) for i in source_trades))
    query = "Select uuid from trade_message where uuid IN ({0})".format(ids)
    query_results = query_rds(db_params=db_params, query=query)

    if len(query_results) > 0:
        for item in query_results:
            results.append(item[0])
    diff = find_diff(source_trades, results)
    return diff


def query_settlement_destination_rds_trades(source_trades: [], db_params: dict, region: str):
    results = []
    if len(source_trades) == 0:
        return results
    ids = str(",".join("'{0}'".format(i) for i in source_trades))
    query = "Select id from settlement_message where id IN ({0})".format(ids)
    query_results = query_rds(db_params=db_params, query=query)

    if len(query_results) > 0:
        for item in query_results:
            results.append(item[0])
    diff = find_diff(source_trades, results)
    return diff


def query_source_rds_trades(rollback_time_in_sec: str, db_params: dict, region: str):
    results = []
    allocations = {}
    start_time = str(int(time.time() - int(rollback_time_in_sec)))
    logging.info(start_time)
    query = "Select * from trade_message tm " \
            "join trade_allocation ta on tm.id = ta.trade_message_id " \
            "where tm.timestamp >{0} and (tm.status='MATCHED' or tm.status='MISMATCHED' or tm.status='SETTLED')".format(start_time)
    query_results = query_rds_realdict(db_params=db_params, query=query)
    if len(query_results) > 0:
        results = core_db_trades_mapper(query_results)

    return results


def query_settlement_source_rds_trades(rollback_time_in_sec: str, db_params: dict, region: str):
    results = []
    allocations = {}
    start_time = str(int(time.time() - int(rollback_time_in_sec)))
    logging.info(start_time)
    query = "Select * from settlement_message where status='Settled'"
    query_results = query_rds_realdict(db_params=db_params, query=query)
    if len(query_results) > 0:
        results = core_settlement_db_trades_mapper(query_results)

    return results


def handle_audit_table(params, region):
    if check_table_exist(params["reconciliation_table"], region):
        return True
    else:
        logging.info("Reconciliation jobs table not found, creating...")
        return create_table(params["reconciliation_table"], region)
