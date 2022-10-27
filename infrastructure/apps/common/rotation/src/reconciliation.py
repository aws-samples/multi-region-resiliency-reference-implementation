import logging
import boto3

logging.basicConfig(format='%(asctime)s %(message)s', level=logging.INFO)


def execute_reconciliation(event, context):

    aws_region = event['AWS_REGION']
    reconciliation = event['RECONCILIATION']
    if event["APP"] == "settlement":
        reconciliation = "Settlement" + reconciliation
        # valid component:
        #InboundIngress
        #IngressCore
        #CoreEgress
        #EgressOutbound
        #OutboundSettlementInbound

    tasks = [{
            "cluster": 'trade-matching-reconciliation-ecs-cluster',
            "task": 'trade-matching-reconciliation'
        }]

    try:
        client = boto3.client("ecs", region_name=aws_region)
        start_trade_matching(aws_region, tasks, reconciliation)

    except Exception as e:
        logging.error("Exception in execute_reconciliation", e)


def start_trade_matching(region, tasks, reconciliation):
    client = boto3.client("ecs", region_name=region)
    prefix = "trade-matching"
    # make sure all tasks are off.
    for t in tasks:
        print("Starting task {0} on cluster {1} ".format(t['task'], t["cluster"]))

        # get cluster instances
        response = client.list_container_instances(
            cluster=t["cluster"],
            status='ACTIVE'
        )
        instances = response['containerInstanceArns']

        # start the task
        response = client.start_task(
            cluster=t["cluster"],
            containerInstances=[instances[0]],
            taskDefinition=t['task'],
            overrides={
                'containerOverrides': [
                    {
                        'name': 'trade-matching-reconciliation',
                        'environment': [
                            {
                                'name': 'REGION',
                                'value': region
                            },
                            {
                                'name': 'RECONCILIATION',
                                'value': reconciliation
                            }
                        ]
                    },
                ],
            }
        )
        print(response)


if __name__ == "__main__":
    event = dict()
    event["AWS_REGION"] = "us-east-1"
    event["APP"] = "trade-matching"
    event["APP"] = "settlement"
    component = event["COMPONENT"]
    if event["APP"] == "trade-matching":
        event["RECONCILIATION"] = component
        # valid component:
        #InboundIngress
        #IngressCore
        #CoreEgress
        #EgressOutbound
        #OutboundSettlementInbound
    else:
        event["RECONCILIATION"] = "Settlement" + component
        #valud component for settlement
        #InboundIngress
        #IngressCore
        #CoreEgress
        #EgressOutbound
        #OutboundSettlementInbound

    # event["RECONCILIATION"] = "InboundIngress"
    # event["RECONCILIATION"] = "IngressCore"
    # event["RECONCILIATION"] = "CoreEgress"
    # InboundIngress IngressCore CoreEgress EgressOutbound
    execute_reconciliation(event, None)









