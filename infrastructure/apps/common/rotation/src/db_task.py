import logging
import boto3

logging.basicConfig(format='%(asctime)s %(message)s', level=logging.INFO)


def execute_db_task(event, context):

    aws_region = event['AWS_REGION']
    action = event['ACTION']
    task_list = [
        {
            "cluster": 'trade-matching-core-ingestion-ecs-cluster',
            "task": 'trade-matching-core-ingestion',
            "instance": '9f63154090c7467eb836d8cdf583ed38'
        },
        {
            "cluster": 'trade-matching-core-matching-ecs-cluster',
            "task": 'trade-matching-core-matching',
            "instance": '17c9c168421a46a6982b79bb65a3b55f'
        }
    ]

    try:
        client = boto3.client("ecs", region_name=aws_region)

        if action.lower() == "start":
            for task in task_list:
                response = client.start_task(
                    cluster=task['cluster'],
                    containerInstances=[task['instance']],
                    taskDefinition=task['task']
                )
                logging.info(response)
        elif action.lower() == "stop":
            clusters = list_tasks(aws_region)
            for task in task_list:
                logging.info("Stopping task {0} on cluster {1}".format(task['task'], task['cluster']))
                task_id = find_task_id(clusters, task['cluster'])
                logging.info("task_id: " + task_id)
                response = client.stop_task(
                    cluster=task['cluster'],
                    task=task_id,
                    reason='Manuel stop'
                )
    except Exception as e:
        logging.error("Exception in execute_db_task", e)


def find_task_id(clusters: [], cluster):
    for c in clusters:
        if cluster in c['cluster']:
            return c['task']
    return None


def list_tasks(region):
    client = boto3.client("ecs", region_name=region)
    task_list = []
    response = client.list_clusters(
        maxResults=100
    )
    clusters = response['clusterArns']
    for cluster in clusters:
        # logging.info("*******Tasks for cluster: " + cluster)
        task_response = client.list_tasks(
            cluster=cluster,
        )
        for task in task_response["taskArns"]:
            logging.info(task)
            task_list.append({
                "cluster": cluster,
                "task": task
            })
    return task_list


if __name__ == "__main__":
    event = dict()
    event["AWS_REGION"] = "us-east-1"
    event["ACTION"] = "stop"
    # event["ACTION"] = "start"

    execute_db_task(event, None)
    