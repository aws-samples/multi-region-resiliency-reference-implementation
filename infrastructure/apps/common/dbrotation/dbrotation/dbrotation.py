# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0
"""
On-demand database state reset for the multi-region reference implementation.

The Route 53 ARC routing controls declare which region *should* be active,
but flipping them (dashboard toggles, CLI) does not move the Aurora Global
Database writer. If the controls and the writer disagree, the newly active
region's matching services write against a read-only replica and fail.

Invoke this function to reconcile the two:

    aws lambda invoke --function-name dbrotation \
        --cli-binary-format raw-in-base64-out \
        --payload '{"app": "trade-matching"}' out.json

Payload:
    app      (required)  "trade-matching" | "settlement"
    dry_run  (optional)  true = report drift without acting

Behavior: if exactly one region's <app>-app-* routing control is On and the
Aurora global cluster writer is in the other region, a managed switchover
(zero data loss) is started to move the writer to the intended region. If
neither or both regions are On (e.g. mid-runbook drain), no action is taken.
"""

import json
import os

import boto3

CONTROL_PLANE_REGION = os.environ.get("CONTROL_PLANE_REGION", "us-west-2")
SECRETS_REGION = os.environ.get("SECRETS_REGION", "us-east-1")

VALID_APPS = ("trade-matching", "settlement")


def handler(event, context):
    app = (event or {}).get("app")
    dry_run = bool((event or {}).get("dry_run", False))

    if app not in VALID_APPS:
        return _response(400, {"error": f"payload must include app: one of {VALID_APPS}"})

    try:
        intent_region = get_intended_region(app)
        writer_region, writer_arn, members = get_writer(app)
        in_sync = intent_region is None or intent_region == writer_region

        result = {
            "app": app,
            "intent_region": intent_region,
            "writer_region": writer_region,
            "in_sync": in_sync,
            "dry_run": dry_run,
            "action": "none",
        }

        if intent_region is None:
            result["detail"] = ("routing controls do not declare exactly one active "
                                "region; nothing to reconcile")
            return _response(200, result)

        if in_sync:
            result["detail"] = "Aurora writer already matches the routing controls"
            return _response(200, result)

        target_arn = members.get(intent_region)
        if not target_arn:
            result["detail"] = f"no global cluster member found in {intent_region}"
            return _response(500, result)

        result["action"] = f"switchover writer {writer_region} -> {intent_region}"
        if dry_run:
            result["detail"] = "dry run: switchover NOT started"
            return _response(200, result)

        rds = boto3.client("rds", region_name=writer_region)
        resp = rds.switchover_global_cluster(
            GlobalClusterIdentifier=f"{app}-core-global-cluster",
            TargetDbClusterIdentifier=target_arn,
        )
        result["detail"] = ("switchover started (status: "
                            f"{resp['GlobalCluster']['Status']}); the writer will move "
                            "within a few minutes")
        return _response(200, result)

    except Exception as error:  # noqa: BLE001 - report any failure to the invoker
        print(f"Error reconciling {app}: {error}")
        return _response(500, {"app": app, "error": str(error)})


def get_intended_region(app):
    """Return the region whose <app>-app-* routing control is On, or None
    unless exactly one region is On."""
    secrets = boto3.client("secretsmanager", region_name=SECRETS_REGION)
    panel_arn = secrets.get_secret_value(SecretId=f"{app}-control-panel")["SecretString"]
    cluster_arn = secrets.get_secret_value(SecretId="approtation-cluster")["SecretString"]

    config = boto3.client("route53-recovery-control-config", region_name=CONTROL_PLANE_REGION)
    controls = {}
    paginator = config.get_paginator("list_routing_controls")
    for page in paginator.paginate(ControlPanelArn=panel_arn):
        for rc in page["RoutingControls"]:
            controls[rc["Name"]] = rc["RoutingControlArn"]

    endpoints = config.describe_cluster(ClusterArn=cluster_arn)["Cluster"]["ClusterEndpoints"]

    on_regions = []
    for region in ("us-east-1", "us-west-2"):
        arn = controls.get(f"{app}-app-{region}")
        if not arn:
            raise RuntimeError(f"routing control {app}-app-{region} not found")
        if get_control_state(arn, endpoints) == "On":
            on_regions.append(region)

    return on_regions[0] if len(on_regions) == 1 else None


def get_control_state(control_arn, endpoints):
    """Read a routing control state from the ARC data plane, trying each
    cluster endpoint until one responds (recommended ARC access pattern)."""
    last_error = None
    for ep in endpoints:
        try:
            client = boto3.client("route53-recovery-cluster",
                                  region_name=ep["Region"], endpoint_url=ep["Endpoint"])
            return client.get_routing_control_state(
                RoutingControlArn=control_arn)["RoutingControlState"]
        except Exception as error:  # noqa: BLE001 - try the next endpoint
            last_error = error
    raise RuntimeError(f"all ARC cluster endpoints failed: {last_error}")


def get_writer(app):
    """Return (writer_region, writer_arn, {region: member_arn}) for the
    app's Aurora global cluster."""
    rds = boto3.client("rds", region_name=SECRETS_REGION)
    gc = rds.describe_global_clusters(
        GlobalClusterIdentifier=f"{app}-core-global-cluster")["GlobalClusters"][0]

    members = {}
    writer_region = None
    writer_arn = None
    for member in gc["GlobalClusterMembers"]:
        arn = member["DBClusterArn"]
        region = arn.split(":")[3]
        members[region] = arn
        if member.get("IsWriter"):
            writer_region = region
            writer_arn = arn
    return writer_region, writer_arn, members


def _response(status_code, body):
    print(json.dumps(body, default=str))
    return {"statusCode": status_code, "body": body}
