# App Rotation Prototype


## Prerequisites
1. Create a cloud 9 role, that the users will assume to deploy the application
2. Give AWS and customer users that will deploy the application permission to assume the cloud 9 role
3. Update trust-policy.json file used by deployment admin role that gives the cloud 9 role permission to assume the deployment role created in next step
4. Create a deployment admin role by invoking the target "create-role" mentioned below that uses trust-policy.json file. Make sure the role used have proper permissions to create the resources and deploy the application.
5. Update the Destination ACCOUNT, ROLE, REGIONS in
   * Makefile
   * infrastructure/Makefile
   * apps/Makefile
6. Update Terraform modules store environment in infrastructure/Makefile -> INFRA_ENV_ID parameter.

## Software Prerequisites
1. Make sure you have Docker installed
2. Use Terraform version  v1.1.7
3. jq is installed on terminal

## Installation
Run the make file command:
```shell
make deploy-all
```

### To Deploy only the Infrastructure
```shell
make deploy-infra
```

### To Deploy only the Applications
```shell
make deploy-apps
```

### To Create a role in the account
1. edit trust-policy and update the account ID
2. run the command
```shell
make create-role
```

### To test your credentials can assume the role configured
```shell
make test-creds
```

### Cleanup
To remove all resources run the command
```shell
make destroy-infra
```

### Q.A

* if you get this error "error creating Route53 Recovery Readiness Cell: ServiceQuotaExceededException"
You will need to raise a Service Quotas request or call customer support team to increase it manually.

* if you encounter - error creating ELBv2 Listener (arn:aws:elasticloadbalancing:us-east-1:690047714878:loadbalancer/net/tm-out-us-east-1-mq-nlb/c56a765d0f972c7a): CertificateNotFound: Certificate 'arn:aws:acm:us-east-1:690047714878:certificate/732eb8a4-4be8-41ab-9f40-f25b911f1339' not found
Go to the console to ACM Service -> Private ACM -> click Actions -> Install CA Certificate