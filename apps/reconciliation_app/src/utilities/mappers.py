# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

import json
import logging
import random

from utilities.util import convert_db_date


def inbound_ingress_mapper(item):
    record = {
        "id": item["id"]["S"],
        "currentTime": item["currentTime"]["S"],
        "currentDate": item["currentDate"]["S"],
        "rawMessage": item["rawMessage"]["S"],
        "timestamp": int(item["timestamp"]["N"])
    }
    return record


def inbound_ingress_settlement_mapper(item):
    record = {
        "id": item["id"]["S"],
        "currentDate": item["currentDate"]["S"],
        "currentTime": item["currentTime"]["S"],
        "timestamp": int(item["timestamp"]["N"]),
        "senderID": item["senderID"]["S"],
        "imID": item["imID"]["S"],
        "brokerID": item["brokerID"]["S"],
        "tradeID": item["tradeID"]["S"],
        "allocationID": int(item["allocationID"]["N"]),
        "quantity": int(item["quantity"]["N"]),
        "security": item["security"]["S"],
        "transactionIndicator": item["transactionIndicator"]["S"],
        "price": float(item["price"]["N"]),
        "tradeDate": item["tradeDate"]["S"],
        "settlementDate": item["settlementDate"]["S"],
        "deliveryInstructions": item["deliveryInstructions"]["S"],
        "status": item["status"]["S"],
        "account": item["account"]["S"],
    }
    return record


def ingress_core_mapper(item):
    # logging.info(item)
    allocations = []
    for allo in item["allocations"]["L"]:
        allocations.append({
            "allocationID": allo["M"]["allocationID"]["N"],
            "quantity": allo["M"]["quantity"]["N"],
            "account": allo["M"]["account"]["S"],
            "status": allo["M"]["status"]["S"]
        })
    record = {
        "id": item["id"]["S"],
        "currentTime": item["currentTime"]["S"],
        "currentDate": item["currentDate"]["S"],
        "imID": item["imID"]["S"],
        "timestamp": int(item["timestamp"]["N"]),
        "tradeID": item["tradeID"]["S"],
        "price": item["price"]["N"],
        "senderID": item["senderID"]["S"],
        "security": item["security"]["S"],
        "deliveryInstructions": item["deliveryInstructions"]["S"],
        "tradeDate": item["tradeDate"]["S"],
        "settlementDate": item["settlementDate"]["S"],
        "brokerID": item["brokerID"]["S"],
        "status": item["status"]["S"],
        "transactionIndicator": item["transactionIndicator"]["S"],
        "quantity": item["quantity"]["N"],
        "allocations": allocations
    }
    return record


def ingress_core_settlement_mapper(item):
    record = {
        "id": item["id"]["S"],
        "currentDate": item["currentDate"]["S"],
        "currentTime": item["currentTime"]["S"],
        "timestamp": int(item["timestamp"]["N"]),
        "senderID": item["senderID"]["S"],
        "imID": item["imID"]["S"],
        "brokerID": item["brokerID"]["S"],
        "tradeID": item["tradeID"]["S"],
        "allocationID": int(item["allocationID"]["N"]),
        "quantity": int(item["quantity"]["N"]),
        "security": item["security"]["S"],
        "transactionIndicator": item["transactionIndicator"]["S"],
        "price": float(item["price"]["N"]),
        "tradeDate": item["tradeDate"]["S"],
        "settlementDate": item["settlementDate"]["S"],
        "deliveryInstructions": item["deliveryInstructions"]["S"],
        "status": item["status"]["S"],
        "account": item["account"]["S"],
    }
    return record


def core_db_trades_mapper(items: []):
    results = {}

    for item in items:
        # logging.info(item)
        rec_id = item["uuid"]
        record = {
            # "db_id": item['tm.id'],
            "id": rec_id,
            "uuid": item["uuid"],
            "curr_date": item["curr_date"],
            "curr_time": item["curr_time"],
            "sender_id": item["sender_id"],
            "im_id": item["im_id"],
            "broker_id": item["broker_id"],
            "trade_id": item["trade_id"],
            "security": item["security"],
            "transaction_indicator": item["transaction_indicator"],
            "price": str(item["price"]),
            "quantity": item["quantity"],
            "trade_date": convert_db_date(item["trade_date"]),
            "settlement_date": convert_db_date(item["settlement_date"]),
            "delivery_instructions": item["delivery_instructions"],
            "status": item["status"],
            "timestamp": str(item["timestamp"])
            # "allocations": []
        }

        single_allocation = {
            'id': item["id"],
            "tradeAllocationID": item["trade_allocation_id"],
            "allocationQuantity": item["allocation_quantity"],
            "allocationAccount": item["allocation_account"],
            "allocationStatus": item["allocation_status"]
        }

        if rec_id in results:
            existing_record = results[rec_id]
            existing_record["allocations"].append(single_allocation)
        else:
            allocation_collection = [single_allocation]
            record["allocations"] = allocation_collection
            results[rec_id] = record

    return list(results.values())


def core_settlement_db_trades_mapper(items: []):
    results = []
    # logging.info(items[0])
    # breakpoint()
    #
    for item in items:
        # logging.info(item)
        record = {
            "id": item["id"],
            "currentDate": item["curr_date"],
            "currentTime": item["curr_time"],
            "timestamp": '',
            "senderID": item["sender_id"],
            "imID": item["im_id"],
            "brokerID": item["broker_id"],
            "tradeID": item["trade_id"],
            "allocationID": int(item["allocation_id"]),
            "quantity": int(item["quantity"]),
            "security": item["security"],
            "transactionIndicator": item["transaction_indicator"],
            "price": float(item["price"]),
            "tradeDate": convert_db_date(item["trade_date"]),
            "settlementDate": convert_db_date(item["settlement_date"]),
            "deliveryInstructions": item["delivery_instructions"],
            "status": item["status"],
            "account": item["account"],
        }
        results.append(record)

    return results


def core_egress_mapper(item):
    # breakpoint()
    item["tradeUUID"] = item.pop("uuid")
    item["senderID"] = item.pop('sender_id')
    item["imID"] = item.pop('im_id')
    item["brokerID"] = item.pop('broker_id')
    item['price'] = float(item.pop('price'))
    item['timestamp'] = int(item.pop('timestamp'))
    item["tradeID"] = item.pop('trade_id')
    item["transactionIndicator"] = item.pop('transaction_indicator')
    item["tradeDate"] = item.pop('trade_date')
    item["settlementDate"] = item.pop('settlement_date')
    item["deliveryInstructions"] = item.pop('delivery_instructions')
    item["currentDate"] = item.pop('curr_date')
    item["currentTime"] = item.pop('curr_time')

    # a_dict[new_key] = a_dict.pop(old_key)
    # logging.info(item)
    return item


def egress_outbound_mapper(item):
    # logging.info(item)
    # breakpoint()
    record = {
        "id": item["id"]["S"],
        # "currentTime": item["currentTime"]["S"],
        # "currentDate": item["currentDate"]["S"],
        "message": item["tradeMessage"]["S"],
        # "timestamp": int(item["timestamp"]["N"]),
        "status": item["status"]["S"],
        "description": item["description"]["S"],
        "destination": "N/A"
    }
    return record


def egress_outbound_settlement_mapper(item):
    # logging.info(item)
    # breakpoint()
    record = {
        "id": item["id"]["S"],
        "imID": item["imID"]["S"],
        "tradeID": item["tradeID"]["S"],
        "price": float(item["price"]["N"]),
        "account": item["account"]["S"],
        "security": item["security"]["S"],
        "senderID": item["senderID"]["S"],
        "deliveryInstructions": item["deliveryInstructions"]["S"],
        "tradeDate": item["tradeDate"]["S"],
        "settlementDate": item["settlementDate"]["S"],
        "brokerID": item["brokerID"]["S"],
        "allocationID": int(item["allocationID"]["N"]),
        "timestamp": int(item["timestamp"]["N"]),
        "status": item["status"]["S"],
        "currentDate": item["currentDate"]["S"],
        "transactionIndicator": item["transactionIndicator"]["S"],
        "currentTime": item["currentTime"]["S"],
        "quantity": int(item["quantity"]["N"])
    }
    return record


def settlement_inbound_ingress_mapper(item):
    # logging.info(item)
    # breakpoint()
    record = {
        "id": item["id"]["S"],
        "timestamp": int(item["timestamp"]["N"]),
        "rawMessage": item["rawMessage"]["S"],
        "currentDate": item["currentDate"]["S"],
        "currentTime": item["currentTime"]["S"]
    }
    return record


def settlement_ingress_core_mapper(item):
    # logging.info(item)
    # breakpoint()
    record = {
        "id": item["id"]["S"],
        "currentDate": item["currentDate"]["S"],
        "currentTime": item["currentTime"]["S"],
        "timestamp": int(item["timestamp"]["N"]),
        "senderID": item["senderID"]["S"],
        "imID": item["imID"]["S"],
        "brokerID": item["brokerID"]["S"],
        "tradeID": item["tradeID"]["S"],
        "allocationID": int(item["allocationID"]["N"]),
        "quantity": int(item["quantity"]["N"]),
        "security": item["security"]["S"],
        "transactionIndicator": item["transactionIndicator"]["S"],
        "price": float(item["price"]["N"]),
        "tradeDate": item["tradeDate"]["S"],
        "settlementDate": item["settlementDate"]["S"],
        "deliveryInstructions": item["deliveryInstructions"]["S"],
        "status": item["status"]["S"],
        "account": item["account"]["S"],
    }
    return record


def settlement_core_egress_mapper(item):
    # logging.info(item)
    # breakpoint()
    return item


def settlement_egress_outbound_mapper(item):
    # logging.info(item)
    # breakpoint()
    record = {
        "id": item["id"]["S"],
        "currentDate": item["currentDate"]["S"],
        "currentTime": item["currentTime"]["S"],
        "timestamp": int(item["timestamp"]["N"]),
        "senderID": item["senderID"]["S"],
        "imID": item["imID"]["S"],
        "brokerID": item["brokerID"]["S"],
        "tradeID": item["tradeID"]["S"],
        "allocationID": int(item["allocationID"]["N"]),
        "quantity": int(item["quantity"]["N"]),
        "security": item["security"]["S"],
        "transactionIndicator": item["transactionIndicator"]["S"],
        "price": float(item["price"]["N"]),
        "tradeDate": item["tradeDate"]["S"],
        "settlementDate": item["settlementDate"]["S"],
        "deliveryInstructions": item["deliveryInstructions"]["S"],
        "status": item["status"]["S"],
        "account": item["account"]["S"],
    }
    return record


def trade_matching_settlement_outbound_inbound_settlement_mapper(item):
    # logging.info(item)
    record_mod = {
        "quantity": item["quantity"]["N"],
        "currentTime": item["currentTime"]["S"],
        "transactionIndicator": item["transactionIndicator"]["S"],
        "currentDate": item["currentDate"]["S"],
        "status": item["status"]["S"],
        "timestamp": int(item["timestamp"]["N"]),
        "allocationID": int(item["allocationID"]["N"]),
        "brokerID": item["brokerID"]["S"],
        "settlementDate": item["settlementDate"]["S"],
        "tradeDate": item["tradeDate"]["S"],
        "deliveryInstructions": item["deliveryInstructions"]["S"],
        "senderID": item["senderID"]["S"],
        "security": item["security"]["S"],
        "account": item["account"]["S"],
        "price": float(item["price"]["N"]),
        "tradeID": item["tradeID"]["S"],
        "id": item["id"]["S"],
        "imID": item["imID"]["S"]
    }
    record = {
        "id": item["id"]["S"],
        "currentDate": item["currentDate"]["S"],
        "currentTime": record_mod["currentTime"],
        "timestamp": record_mod["timestamp"],
        "rawMessage": json.dumps(record_mod)

    }
    return record


def settlement_outbound_trade_matching_inbound_settlement_mapper(item):
    # logging.info(item)
    record = {
        "id": item["id"]["S"],
        "currentDate": item["currentDate"]["S"],
        "currentTime": item["currentTime"]["S"],
        "timestamp": int(item["timestamp"]["N"]),
        "senderID": item["senderID"]["S"],
        "imID": item["imID"]["S"],
        "brokerID": item["brokerID"]["S"],
        "tradeID": item["tradeID"]["S"],
        "allocationID": int(item["allocationID"]["N"]),
        "quantity": int(item["quantity"]["N"]),
        "security": item["security"]["S"],
        "transactionIndicator": item["transactionIndicator"]["S"],
        "price": float(item["price"]["N"]),
        "tradeDate": item["tradeDate"]["S"],
        "settlementDate": item["settlementDate"]["S"],
        "deliveryInstructions": item["deliveryInstructions"]["S"],
        "status": item["status"]["S"],
        "account": item["account"]["S"],
    }
    return record
