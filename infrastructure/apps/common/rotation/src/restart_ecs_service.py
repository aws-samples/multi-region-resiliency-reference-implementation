import boto3
from datetime import datetime
import json
import logging


def restart_ecs_service(event, context):

    print(datetime.now().strftime("%m/%d/%Y, %H:%M:%S") + " restart_ecs_service Invoked")
    app = event['APP']
    aws_region = event['AWS_REGION']
    component = event['COMPONENT']

    client = boto3.client('ecs', region_name=aws_region)
    prefix = app + "-core"
    # get the running tasks on the region
    running_tasks = list_running_tasks(aws_region, prefix)

    print("Total running apps {0}".format(len(running_tasks)))

    # stop running tasks
    for run_task in running_tasks:
        stop_task(aws_region,run_task['cluster'], run_task['task'])

    # get task details
    tasks = list_task_definition(aws_region, prefix)
    # rerun the tasks
    start_trade_matching(aws_region, tasks)

    # restart_ecs_service_activity(client, app, component, "ingestion")
    # restart_ecs_service_activity(client, app, component, "matching")


def list_running_tasks(region, prefix):
    client = boto3.client("ecs", region_name=region)
    task_list = []
    response = client.list_clusters(
        maxResults=100
    )
    clusters = response['clusterArns']
    for cluster in clusters:
        task_response = client.list_tasks(
            cluster=cluster,
        )

        for task in task_response["taskArns"]:
            if prefix in task:
                logging.info(task)
                task_list.append({
                    "cluster": cluster,
                    "task": task
                })
    return task_list


def list_task_definition(region, prefix):
    client = boto3.client("ecs", region_name=region)
    task_list = []
    response = client.list_clusters(
        maxResults=100
    )

    task_response = client.list_task_definitions()

    clusters = response['clusterArns']
    tasks = task_response["taskDefinitionArns"]
    for task in tasks:
        if prefix in task:
            task_list.append({
                "cluster": match_cluster_to_task(clusters, task, prefix),
                "task": task
            })

    return task_list


def match_cluster_to_task(clusters, task, prefix):
    task_name = task[task.rindex(prefix):].split(':')[0]
    for cluster in clusters:
        if task_name in cluster:
            return cluster

    return ""


def start_trade_matching(region, tasks):
    client = boto3.client("ecs", region_name=region)
    prefix = "trade-matching"
    # make sure all tasks are off.
    for t in tasks:
        # logging.info("Starting task {0} on cluster {1} ".format(t['task'], t["cluster"]))
        print("Starting task {0} on cluster {1} ".format(t['task'], t["cluster"]))
        # check task is not runningn already
        #stop_task(region, t["cluster"], t["task"])
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
            taskDefinition=t['task']
        )
        logging.info(response)


def stop_task(region, cluster, task):
    client = boto3.client("ecs", region_name=region)
    logging.info("Stopping task {0} on cluster {1}".format(task, cluster))
    response = client.stop_task(
        cluster=cluster,
        task=task,
        reason='Manuel stop'
    )
    return True
# def restart_ecs_service_activity(client, app, component, activity):
#
#     cluster = app + "-" + component + "-" + activity + "-ecs-cluster"
#     task_definition = app + "-" + component + "-" + activity
#     tasks_response = client.list_tasks(cluster=cluster)
#     tasks_arns = tasks_response["taskArns"]
#     for task_arn in tasks_arns:
#         client.stop_task(cluster=cluster, task=task_arn, reason='database endpoint changed')
#     container_instances_response = client.list_container_instances(cluster=cluster)
#     container_instances_arns = container_instances_response["containerInstanceArns"]
#     client.start_task(cluster=cluster, containerInstances=container_instances_arns, taskDefinition=task_definition)


if __name__ == "__main__":
    event = dict()
    event["APP"] = "settlement"
    event["AWS_REGION"] = "us-east-1"
    event["COMPONENT"] = "core"
    restart_ecs_service(event, None)