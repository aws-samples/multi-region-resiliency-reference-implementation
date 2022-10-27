# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0
import logging
import logging

import click

from reconciliation import inbound_ingress_reconciliation, ingress_core_reconciliation, core_egress_reconciliation, \
    egress_outbound_reconciliation, outbound_settlement_inbound_reconciliation, \
    settlement_inbound_ingress_reconciliation, settlement_ingress_core_reconciliation, \
    settlement_core_egress_reconciliation, settlement_egress_outbound_reconciliation, \
    settlement_outbound_trade_inbound_reconciliation
from utilities.util import enable_logging, get_params


@click.command()
@click.option('--region', default="us-east-1", help='The region to fetch parameters and execute the app')
@click.option('--reconciliation', help='The type of reconciliation: InboundIngress')
def cli(region, reconciliation):
    enable_logging()
    logging.info("REGION: " + region)
    logging.info("RECONCILIATION: " + reconciliation)
    try:
        logging.info("Loading configurations")
        parameters = get_params(region)
        logging.info("Finished loading configurations")
        if reconciliation == "InboundIngress":
            inbound_ingress_reconciliation(region, parameters)
        elif reconciliation == "IngressCore":
            ingress_core_reconciliation(region, parameters)
        elif reconciliation == "CoreEgress":
            core_egress_reconciliation(region, parameters)
        elif reconciliation == "EgressOutbound":
            egress_outbound_reconciliation(region, parameters)
        elif reconciliation == "OutboundSettlementInbound":
            outbound_settlement_inbound_reconciliation(region, parameters)
        elif reconciliation == "SettlementInboundIngress":
            settlement_inbound_ingress_reconciliation(region, parameters)
        elif reconciliation == "SettlementIngressCore":
            settlement_ingress_core_reconciliation(region, parameters)
        elif reconciliation == "SettlementCoreEgress":
            settlement_core_egress_reconciliation(region, parameters)
        elif reconciliation == "SettlementEgressOutbound":
            settlement_egress_outbound_reconciliation(region, parameters)
        elif reconciliation == "SettlementOutboundSettlementInbound":
            settlement_outbound_trade_inbound_reconciliation(region, parameters)
        else:
            raise ValueError("Illegal reconciliation:" + reconciliation)
    except Exception as e:
        logging.error("Error in reconciliation application", e)


if __name__ == '__main__':
    cli()
