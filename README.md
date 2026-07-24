# Reference for Multi-Region Resiliency for Trade and Settlement Application
This solution demonstrates resiliency for a multi micro-service application(Trade and settlement matching).

The workload can be operated from two regions(possibly more) by rotating the workload from one to the another. This rotation meets RTO < 2 hours and RPO < 30 seconds.

This solution was built for experimenting with resiliency in the AWS Cloud for complex applications consisting of multiple services and technologies across multiple regions.

## **Introduction**

The solution consist of the following artifacts:
1. Infrastructure
2. Applications
3. Data Generator
4. Dashboard

The `/infrastructure` directory holds terraform modules that create the environment in an AWS Account. See [Infrastructure](#infrastructure) section for more details.

The `/apps` directory contains the applications(micro-services) that runs in the environment and performs trades and settlements matching.

The Data Generator exists under the `/apps/trade_matching_generator` directory.  It is designed to generate trades in order to see how the system processes transactions between the multiple micro services.

The UI Dashboard exists under the `infrastructure/dashboard` directory.  It provides the user with a high level view of the application components (in both regions) as well as transaction counts, health statuses, and DNS Routing controls. 

If you wish to jump directly to the setup click on [Getting Started](#getting-started)


### **1. Infrastructure**
The architecture for this solution is designed to support two applications - Trade Matching and Settlement. Each application runs in both regions

![trade and settlement matching architecture](/images/image2.png)
>**_FIGURE 1_** Multi-region trade and settlement matching application architecture

Each application has its own dedicated Incoming/Outgoing Amazon MQ message broker to support incoming and outgoing transaction queuing. In addition, every application service is backed by an ECS Cluster to execute its task, scale as needed, and to provide an additional layer of resiliency.

The micro-services for each application are sending messages through Amazon Kinesis stream. Each message is processed and a copy of the transaction is stored in an Amazon DynamoDB global table or Amazon Aurora PostgreSQL DB. Both persistence storage resources are automatically configured to replicate the data (for each state) to the secondary region.

![application micro-service architecture](/images/image3.png)
>**_FIGURE 2_** Application micro-service architecture

### **2. Applications**

In addition to the environment, this solution also provides demo applications to show how transaction processing would behave during a resiliency event - DR/Rotation. The apps available in this solution:
1. Trade Matching
   1. Inbound Gateway – receives incoming raw transactions before processing.
   2. Ingestion - parses trade messages and save them as proper transactions.
   3. Matching - performs matching of trades and sends resultant Matched/ Mismatched to Egress. Unmatched trades remain in the DB for future potential match.
   4. Egress - processes matched transactions. It creates appropriate settlements from trade allocations.
   5. Outbound Gateway - processes outgoing messages to the Settlement application
2. Settlement Matching
   1. Inbound Gateway - receives incoming settlements before processing.
   2. Ingestion - parses settlement messages and saves them as proper transactions.
   3. Matching - performs settlement matching and sends matched settlements to Egress.
   4. Egress - processes matched settlements before sending them back to the Trade Matching application for finalizing settled trades.
   5. Outbound Gateway - sends settlements back to Trade Matching application to create settled trades.
3. Trade Generator – a random trade transaction generator - creates pairs of random trades with equal probability of Matched, Mismatch, Unmatched trades.
4. Reconciliation and Replay application - an application that is designed to compare transactions to persistance storage, determine any inconsistencies, and replay the missing trades to the appropriate next application.

The Trade Matching and Settlement Apps communicate in the following order:

![Trade Matching and Settlement Apps  ](/images/image1.png)
>**_FIGURE 3_** Trade Matching and Settlement Apps 

### **3. Data Generator**
The Data Generator works as a trade generator service which can be started/stopped by using AWS ARC routing control. The generator uses pre-defined values (configurable) for some trade transaction properties as well as random values to create an endless number of transactions. 
For more information see the internal [README](/apps/trade_matching_generator/README.md).

### **4. Dashboard**
The Dashboard provide the user with a realtime view of the application and infrastructure.
The view consists of:
1. Application transaction flow(Figure 4)
2. Resource health monitoring (Figure 5)
3. Failover orchestration runbook(Figure 6)

It also provides the user with a Route53 DNS routing control view so it is easier to see which app runs in which region.

Lastly, the dashboard provides actionable buttons to start/stop generating transactions and execute Rotation/DR for each individual Application.

Transaction flow UI
![Real-time Dashboard - transaction processing and propagation](/images/image4.png)
>**_FIGURE 4_** Real-time Dashboard - transaction processing and propagation


Monitoring UI
![Real-time Health monitoring Dashboard ](/images/image5.png)
>**_FIGURE 5_** Real-time Resource health monitoring

Failover Orchestration runbook
![DR Failure Orchestration runbook execution ](/images/image6.png)
>**_FIGURE 6_** DR/Rotation Failure orchestration runbook execution
## Getting started

> A catalog of the changes that restored this repository to a deployable
> state (with root causes) is in [DEPLOYMENT_FIXES.md](DEPLOYMENT_FIXES.md).

### Prerequisites

Software on the machine you deploy from:

1. [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.3
2. [Docker](https://docs.docker.com/engine/install/) (running; images are built for linux/amd64)
3. [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
4. [jq](https://jqlang.github.io/jq/) and `openssl`
5. Node.js >= 18 and npm (dashboard UI)
6. Python 3.9+ with pip (dashboard Lambda layer)

AWS account requirements:

* Two regions (defaults: `us-east-1` primary, `us-west-2` secondary).
* Default service quotas are sufficient. Each of the four VPCs uses a single
  NAT gateway (4 Elastic IPs total across both regions).
* **Cost warning:** the solution runs 8 Amazon MQ brokers (active/standby,
  `mq.m5.large`), 2 Aurora global databases, ~34 EC2 instances, 24
  provisioned Kinesis shards, and more. Expect meaningful hourly cost while
  deployed; tear down when not in use.

### One-time account setup

1. Edit `trust-policy.json` and replace `<ACCOUNT_ID>` with your AWS account
   ID (this allows principals in your account to assume the deployment role).
2. With administrator credentials, create the deployment role:

   ```shell
   make create-role
   ```

### Configuration

1. Set `ACCOUNT` (your account ID) in `Makefile`, `infrastructure/Makefile`,
   and `apps/Makefile`.
2. Set `INFRA_ENV_ID` in `infrastructure/Makefile` to a short, globally
   unique identifier (it is embedded in S3 bucket names). The first
   `make deploy-infra` run rewrites the Terraform backend files from the
   default `awsd1` to your identifier via `infrastructure/replace.sh`.

> **Session length note:** `auth.sh` assumes the deployment role for 12
> hours. If your own credentials are an assumed role (for example AWS SSO),
> AWS caps role-chained sessions at 1 hour, which is shorter than the full
> deployment. In that case run the stage targets in `infrastructure/`
> directly with your credentials instead of the top-level
> `make deploy-infra`.

### 1. Deploy the infrastructure

```shell
make deploy-infra
```

This runs, in order: `prerequisites` (Terraform state buckets),
`deploy-before` (KMS keys, IAM roles, the Route 53 ARC cluster and control
panels), the trading and settlement application stacks (initialization,
primary region, secondary region, global), and `deploy-after` (VPC peering,
MQ DNS and replication, rotation runbooks, chaos experiments, resource
groups). Allow roughly 2 hours; Amazon MQ brokers and Aurora clusters
dominate the wait.

### 2. Generate the TLS certificates

The container images embed certificates issued by the private CAs created in
step 1:

```shell
(cd apps/container_scripts && ./generate_certs.sh)
```

### 3. Build and deploy the applications

With Docker running:

```shell
make deploy-apps
```

This builds all 12 services (Gradle builds run inside the Docker builds) and
pushes them to ECR in both regions. The ECS services pull `:latest` and start
automatically; within about 10 minutes every cluster reports its desired
task count.

### 4. Deploy the dashboard

```shell
cd infrastructure/dashboard

# 4a. API: build the psycopg2 Lambda layer, then apply
./api/build_layer.sh
(cd api && terraform init && terraform apply -auto-approve)

# 4b. Generate the UI configuration from the deployed APIs
./generate_ui_config.sh   # writes ui/src/config/index.ts - do not commit it

# 4c. Build the UI
(cd ui && npm install --legacy-peer-deps && npm run build)

# 4d. Hosting: allowlist your IPs in infra/terraform.tfvars, then apply
#     ALLOWED_IP_CIDRS   = ["<your IPv4>/32"]
#     ALLOWED_IPV6_CIDRS = ["<your IPv6 /64 prefix>"]  (omit if no IPv6)
(cd infra && terraform init && terraform apply -auto-approve)
```

The dashboard URL is the CloudFront `domain_name` shown in the apply output.
Access is blocked by AWS WAF except for the CIDRs you allowlist. Browsers
often prefer IPv6 — allowlist your network's /64 prefix rather than a /128,
because client privacy extensions rotate the host bits of the address.

### 5. Start the demo

All Route 53 ARC routing controls start **Off**, so the system is idle.
From the dashboard, use the DNS/Queue/App toggles to activate a region for
each application and the generator control to start trade generation — or
flip them with the CLI (`aws route53-recovery-cluster
update-routing-control-state` against your ARC cluster endpoints). Within a
few minutes the transaction flow view shows trades moving through both
applications.

### Cleanup

Destroy the dashboard first (`terraform destroy` in
`infrastructure/dashboard/infra`, then `infrastructure/dashboard/api`), then:

```shell
make destroy-infra
```

Notes:

* If the demo failed over an application, switch the Aurora global database
  writer back to the primary region first
  (`aws rds switchover-global-cluster`), or the destroy order will not match
  the cluster topology.
* The Kinesis Client Library creates DynamoDB lease tables at runtime (named
  `*-kinesis-stream`) that Terraform does not manage; delete them manually
  after destroy.
* Terraform state buckets and lock tables are kept. Empty and delete the
  `*-terraform-store*` buckets and tables manually for a fully clean account.

### Troubleshooting

* `Error creating Route53 Recovery Readiness Cell ... unavailable for new
  accounts`: you are deploying an old revision; the current code no longer
  uses the readiness APIs.
* `VpcEndpoint modify operation in progress` during apply or destroy: a
  transient race between parallel endpoint changes — rerun the same target.
* `secret with this name is already scheduled for deletion` on redeploy:
  force-delete the leftover secret (`aws secretsmanager delete-secret
  --force-delete-without-recovery`).
* Docker builds fail with `403 Forbidden` from `public.ecr.aws`: stale
  anonymous token — run `docker logout public.ecr.aws`.
* Dashboard shows a blank page or 403: confirm your IP is in the WAF
  allowlist ("Request blocked" means it is not) and that you regenerated the
  UI config after the API apply.
