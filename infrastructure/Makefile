.DEFAULT_GOAL := deploy-all
ACCOUNT=690047714878
REGIONS="us-east-1 us-west-2"
ROLE=deployment-admin-role
INFRA_ENV_ID=awsd2
TERRAFORM_MODULES_STORE=app-rotation-common-terraform-store-$(INFRA_ENV_ID)

escape-hatch-target:
	@echo "Running Escape hatch target"
	sh ../auth.sh $(ACCOUNT) $(ROLE) $(REGIONS) . deploy-settlement-primary;
	@echo "Finished Running Escape hatch target"

deploy-dashboard-api:
	@echo "Deploying Dashboard API"
	(cd dashboard/api; \
		terraform init; \
		terraform apply -auto-approve;)
	@echo "Finished Deploying Dashboard API"

destroy-dashboard-api:
	@echo "Destroying Dashboard API"
	(cd dashboard/api; \
		terraform init; \
		terraform destroy -auto-approve;)
	@echo "Finished Destroying Dashboard API"

build-dashboard-ui:
	@echo "Building Dashboard UI"
	(cd dashboard/ui; \
		npm run build;)
	@echo "Finished Building Dashboard UI"

deploy-dashboard-infra:
	@echo "Deploying Dashboard Infrastructure"
	(cd dashboard/infra; \
		terraform init; \
		terraform apply -auto-approve;)
	@echo "Finished Deploying Dashboard Infrastructure"

destroy-dashboard-infra:
	@echo "Destroying Dashboard Infrastructure"
	(cd dashboard/infra; \
		terraform init; \
		terraform destroy -auto-approve;)
	@echo "Finished Destroying Dashboard Infrastructure"

update-infra-env:
	@echo "Updating Infrastructure Environment ID"
	sh ./replace.sh $(INFRA_ENV_ID)
	@echo "Finished Updating Infrastructure Environment ID"

create-infra-store-bucket:
	@echo "Creating Infrastructure Store S3 Bucket"
	(aws s3api create-bucket --bucket $(TERRAFORM_MODULES_STORE) --region us-east-1;)
	@echo "Finished Creating Infrastructure S3 Bucket"

deploy-common-stores:
	@echo "Deploying Infrastructure Common Stores"
	(cd apps/common/remote-store/stores; \
		terraform init; \
		terraform apply -auto-approve;)
	@echo "Finished Deploying Infrastructure Common Stores"

destroy-common-stores:
	@echo "Destroying Infrastructure Common Stores"
	(cd apps/common/remote-store/stores; \
		terraform init; \
		terraform destroy -auto-approve;)
	@echo "Finished Destorying Infrastructure Common Stores"

deploy-common-initialization:
	@echo "Deploying Infrastructure Common Initialization"
	(cd apps/common/initialization; \
		terraform init; \
		terraform apply -auto-approve;)
	@echo "Finished Deploying Infrastructure Common Initialization"

destroy-common-initialization:
	@echo "Destroying Infrastructure Common Initialization"
	(cd apps/common/initialization; \
		terraform init; \
		terraform destroy -auto-approve;)
	@echo "Finished Destroying Infrastructure Common Initialization"

deploy-common-ecs-role:
	@echo "Deploying Infrastructure Common ECS Role"
	(cd apps/common/ecsrole; \
		terraform init; \
		terraform apply -auto-approve;)
	@echo "Finished Deploying Infrastructure Common ECS Role"

destroy-common-ecs-role:
	@echo "Destroying Infrastructure Common ECS Role"
	(cd apps/common/ecsrole; \
		terraform init; \
		terraform destroy -auto-approve;)
	@echo "Finished Destroying Infrastructure Common ECS Role"

deploy-common-arc-cluster:
	@echo "Deploying Infrastructure Common ARC Cluster"
	(cd apps/common/arccluster; \
		terraform init; \
		terraform apply -auto-approve;)
	@echo "Finished Deploying Infrastructure Common ARC Cluster"

destroy-common-arc-cluster:
	@echo "Destroying Infrastructure Common ARC Cluster"
	(cd apps/common/arccluster; \
		terraform init; \
		terraform destroy -auto-approve;)
	@echo "Finished Destroying Infrastructure Common ARC Cluster"

deploy-trading-initialization:
	@echo "Deploying Infrastructure Trading Initialization"
	(cd apps/trading/initialization; \
		terraform init; \
		terraform apply -auto-approve;)
	@echo "Finished Deploying Infrastructure Trading Initialization"

destroy-trading-initialization:
	@echo "Destroying Infrastructure Trading Initialization"
	(cd apps/trading/primary; \
	terraform init; \
	terraform destroy -auto-approve;)
	@echo "Finished Destroying Infrastructure Trading Initialization"

deploy-trading-primary:
	@echo "Deploying Infrastructure Trading Primary"
	(cd apps/trading/primary; \
		terraform init; \
		terraform apply -auto-approve;)
	@echo "Finished Deploying Infrastructure Trading Primary"

destroy-trading-primary:
	@echo "Destroying Infrastructure Trading Primary"
	(cd apps/trading/primary; \
		terraform init; \
		terraform destroy -auto-approve;)
	@echo "Finished Destroying Infrastructure Trading Primary"

deploy-trading-secondary:
	@echo "Deploying Infrastructure Trading Secondary"
	(cd apps/trading/secondary; \
		terraform init; \
		terraform apply -auto-approve;)
	@echo "Finished Deploying Infrastructure Trading Secondary"

destroy-trading-secondary:
	@echo "Destroying Infrastructure Trading Secondary"
	(cd apps/trading/secondary; \
		terraform init; \
		terraform destroy -auto-approve;)
	@echo "Finished Destroying Infrastructure Trading Secondary"

deploy-trading-global:
	@echo "Deploying Infrastructure Trading Global"
	(cd apps/trading/global; \
		terraform init; \
		terraform apply -auto-approve;)
	@echo "Finished Deploying Infrastructure Trading Global"

destroy-trading-global:
	@echo "Destroying Infrastructure Trading Global"
	(cd apps/trading/global; \
		terraform init; \
		terraform destroy -auto-approve;)
	@echo "Finished Destroying Infrastructure Trading Global"

deploy-settlement-initialization:
	@echo "Deploying Infrastructure Settlement Initialization"
	(cd apps/settlement/initialization; \
		terraform init; \
		terraform apply -auto-approve;)
	@echo "Finished Deploying Infrastructure Settlement Initialization"

destroy-settlement-initialization:
	@echo "Destroying Infrastructure Settlement Initialization"
	(cd apps/settlement/primary; \
	terraform init; \
	terraform destroy -auto-approve;)
	@echo "Finished Destroying Infrastructure Settlement Initialization"

deploy-settlement-primary:
	@echo "Deploying Infrastructure Settlement Primary"
	(cd apps/settlement/primary; \
		terraform init; \
		terraform apply -auto-approve;)
	@echo "Finished Deploying Infrastructure Settlement Primary"

destroy-settlement-primary:
	@echo "Destroying Infrastructure Settlement Primary"
	(cd apps/settlement/primary; \
		terraform init; \
		terraform destroy -auto-approve;)
	@echo "Finished Destroying Infrastructure Settlement Primary"

deploy-settlement-secondary:
	@echo "Deploying Infrastructure Settlement Secondary"
	(cd apps/settlement/secondary; \
		terraform init; \
		terraform apply -auto-approve;)
	@echo "Deploying Infrastructure Settlement Secondary"

destroy-settlement-secondary:
	@echo "Destroying Infrastructure Settlement Secondary"
	(cd apps/settlement/secondary; \
		terraform init; \
		terraform destroy -auto-approve;)
	@echo "Finished Destroying Infrastructure Settlement Secondary"

deploy-settlement-global:
	@echo "Deploying Infrastructure Settlement Global"
	(cd apps/settlement/global; \
		terraform init; \
		terraform apply -auto-approve;)
	@echo "Finished Deploying Infrastructure Settlement Global"

destroy-settlement-global:
	@echo "Destroying Infrastructure Settlement Global"
	(cd apps/settlement/global; \
		terraform init; \
		terraform destroy -auto-approve;)
	@echo "Finished Destroying Infrastructure Settlement Global"

deploy-common-vpc-peering:
	@echo "Deploying Infrastructure Common VPC Peering"
	(cd apps/common/vpcpeering; \
		terraform init; \
		terraform apply -auto-approve;)
	@echo "Finished Deploying Infrastructure Common VPC Peering"

destroy-common-vpc-peering:
	@echo "Destroying Infrastructure Common VPC Peering"
	(cd apps/common/vpcpeering; \
		terraform init; \
		terraform destroy -auto-approve;)
	@echo "Finished Destroying Infrastructure Common VPC Peering"

deploy-common-arc:
	@echo "Deploying Infrastructure Common ARC"
	(cd apps/common/arc; \
		terraform init; \
		terraform apply -auto-approve;)
	@echo "Finished Deploying Infrastructure Common ARC"

destroy-common-arc:
	@echo "Destroying Infrastructure Common ARC"
	(cd apps/common/arc; \
		terraform init; \
		terraform destroy -auto-approve;)
	@echo "Finished Destroying Infrastructure Common ARC"

deploy-common-chaos:
	@echo "Deploying Infrastructure Common Chaos"
	(cd apps/common/chaos; \
		terraform init; \
		terraform apply -auto-approve;)
	@echo "Finished Deploying Infrastructure Common Chaos"

destroy-common-chaos:
	@echo "Destroying Infrastructure Common Chaos"
	(cd apps/common/chaos; \
		terraform init; \
		terraform destroy -auto-approve;)
	@echo "Finished Destroying Infrastructure Common Chaos"

deploy-common-hub:
	@echo "Deploying Infrastructure Common Hub"
	(cd apps/common/hub; \
		terraform init; \
		terraform apply -auto-approve;)
	@echo "Finished Deploying Infrastructure Common Hub"

destroy-common-hub:
	@echo "Destroying Infrastructure Common Hub"
	(cd apps/common/hub; \
		terraform init; \
		terraform destroy -auto-approve;)
	@echo "Finished Destroying Infrastructure Common Hub"

deploy-common-mq-dns:
	@echo "Deploying Infrastructure Common MQ DNS"
	(cd apps/common/mqdns; \
		terraform init; \
		terraform apply -auto-approve;)
	@echo "Finished Deploying Infrastructure Common MQ DNS"

destroy-common-mq-dns:
	@echo "Destroying Infrastructure Common MQ DNS"
	(cd apps/common/mqdns; \
		terraform init; \
		terraform destroy -auto-approve;)
	@echo "Finished Destroying Infrastructure Common MQ DNS"

deploy-common-mq-replication:
	@echo "Deploying Infrastructure Common MQ Replication"
	(cd apps/common/mqreplication; \
		terraform init; \
		terraform apply -auto-approve;)
	@echo "Finished Deploying Infrastructure MQ Replication"

destroy-common-mq-replication:
	@echo "Destroying Infrastructure Common MQ Replication"
	(cd apps/common/mqreplication; \
		terraform init; \
		terraform destroy -auto-approve;)
	@echo "Finished Destroying Infrastructure Common MQ Replication"

deploy-common-rotation:
	@echo "Deploying Infrastructure Common Rotation"
	(cd apps/common/rotation; \
		terraform init; \
		terraform apply -auto-approve;)
	@echo "Finished Deploying Infrastructure Common Rotation"

destroy-common-rotation:
	@echo "Destroying Infrastructure Common Rotation"
	(cd apps/common/rotation; \
		terraform init; \
		terraform destroy -auto-approve;)
	@echo "Finished Destroying Infrastructure Common Rotation"

destroy-trading: destroy-trading-primary destroy-trading-secondary destroy-trading-global
destroy-settlement: destroy-settlement-primary destroy-settlement-secondary destroy-settlement-global
destroy-all: destroy-trading destroy-settlement

destroy-dashboard: destroy-dashboard-api destroy-dashboard-infra
prerequisites: update-infra-env create-infra-store-bucket deploy-common-stores
deploy-before: deploy-common-initialization deploy-common-ecs-role deploy-common-arc-cluster
deploy-trading: deploy-trading-initialization deploy-trading-primary deploy-trading-secondary deploy-trading-global
deploy-settlement: deploy-settlement-initialization deploy-settlement-primary deploy-settlement-secondary deploy-settlement-global
deploy-after: deploy-common-vpc-peering deploy-common-arc deploy-common-mq-dns deploy-common-mq-replication deploy-common-rotation deploy-common-chaos deploy-common-hub
deploy-all: deploy-before deploy-trading deploy-settlement deploy-after

help:
	@echo "Please use \`make <target>' where <target> is one of"
