# App-rotation Prototype Infrastructure

## Prerequisites
1. Terraform installed
2. AWS CLI
3. Update the Destination ACCOUNT, ROLE, REGIONS in
   * Makefile
   * infrastructure/Makefile
   * apps/Makefile

## Installation
Execute the following commands in the directories in the order given below:

Commands: 

- terraform init
- terraform apply

# Directories: 
tree -d -L 2

- infrastructure/apps/common/remote-store/stores
- infrastructure/apps/trading/primary
- infrastructure/apps/trading/secondary
- infrastructure/apps/trading/global
- infrastructure/apps/settlement/primary
- infrastructure/apps/settlement/secondary
- infrastructure/apps/settlement/global


## Dashboard
* Install the api using deploy-dashboard-api
* Navigate to infrastructure/dahsboard/ui/src/config/index.ts
* Update API Endpoint with the deployed infrastructure API endpoint.
* now deploy build-dashboard-ui deploy-dashboard-infra

