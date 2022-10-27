# Application Container Deployment Automation
This automation script will build and deploy the application container from the sourcecode in this directory.

## Prerequisites
Default region is set for both us-east-1 us-west-2. if you wish to change it, edit the Makefile and change to desire region/s
Make sure you have the below installed:
1. AWS CLI
2. Docker Demon running
3. Update the Destination ACCOUNT, ROLE, REGIONS in
   * Makefile
   * infrastructure/Makefile
   * apps/Makefile

## To deploy all containers
Set the region on the top of makefile parameter (us-east-1, us-west-2)
```shell
make deploy-all
```

## Deploy only trade matching applications
```shell
make deploy-tm
```

## Deploy only settlement applications
```shell
make deploy-st
```

## To deploy individual app
```shell
make deploy-generator
make deploy-inbound
make deploy-ingress
make deploy-core-ingestion
make deploy-core-matching
make deploy-egress
make deploy-outbound
make deploy-reconciliation-app
make deploy-settlement-inbound
make deploy-settlement-ingestion
make deploy-settlement-core
make deploy-settlement-egress
make deploy-settlement-outbound
```
