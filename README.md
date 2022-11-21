# Reference for Multi-Region Resiliency for Trade and Settlement Application
This solution demonstrates resiliency for a multi micro-service application(Trade and settlement matching).

The workload can be operated from two regions(possibly more) by rotating the workload from one to the another. This rotation meets RTO < 2 hours and RPO < 30 seconds.

This solution was built for exprimenting with reseiliency in the AWS Cloud for complex applications consisting of multiple services and technlogies across multiple regions.

## **Introduction**

The solution consist of the following artifacts:
1. Infrastructure
2. Applications
3. Data Generator
4. Dashboard

The `/infrastructure` directory holds terraform modules that create the envinroment in an AWS Account. See [Infrastructure](#infrastructure) section for more details.

The `/apps` directory contains the applications(micro-services) that runs in the envinronment and performs trades and settlements matching.

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
3. Failover orechestration runbook(Figure 6)

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

### Prerequisites
1. Create a Cloud 9 IAM role, that the users will assume to deploy the application
2. Give permission to assume the Cloud9 role to AWS and customer users that will deploy the application
3. Update the `trust-policy.json` file used by the deployment admin role that gives the Cloud9 role permission to assume the deployment role created in the next step
4. Create a deployment admin role by invoking the target "create-role" mentioned below that uses trust-policy.json file. Make sure the role used has proper permissions to create the resources and deploy the application.
5. Update the Destination ACCOUNT, ROLE, and REGIONS in
   * `Makefile`
   * `infrastructure/Makefile`
   * `apps/Makefile`

6.  Update the Terraform modules store environment in `infrastructure/Makefile` -> INFRA_ENV_ID parameter.

### Software Prerequisites
1. Make sure you have [Docker installed]( https://docs.docker.com/engine/install/)
2. [Terraform]( https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) version v1.1.7 or higher
3. [jq]( https://stedolan.github.io/jq/) is installed on terminal


### Installation
Run the make file command:
```shell
make deploy-all
```

#### To Deploy only the Infrastructure
```shell
make deploy-infra
```

#### To Deploy only the Applications
```shell
make deploy-apps
```

#### To Create a role in the account
1. edit trust-policy and update the account ID
2. run the command
```shell
make create-role
```

#### To test your credentials can assume the role configured
```shell
make test-creds
```

#### Cleanup
To remove all resources run the command
```shell
make destroy-infra
```

#### Troubleshooting

* If you encounter the error "error creating Route53 Recovery Readiness Cell: ServiceQuotaExceededException"
You will need to raise a Service Quotas request or engage the AWS customer support team to increase it manually.

* If you encounter an error similar to "error creating ELBv2 Listener (arn:aws:elasticloadbalancing:us-east-1:123412341234:loadbalancer/net/tm-out-us-east-1-mq-nlb/c56a765d0f972c7a): CertificateNotFound: Certificate 'arn:aws:acm:us-east-1:123412341234:certificate/732eb8a4-4be8-41ab-9f40-f25b911f1339' not found"  
Install the certificate through the AWS console: **ACM Service -> Private ACM -> click Actions -> Install CA Certificate**

## Contact Us
Looking for more information? reach out to: [aws-gfs-acceleration-amer@amazon.com](mailto:aws-gfs-acceleration-amer@amazon.com) 
