#!/bin/bash
.DEFAULT_GOAL=deploy-all
ACCOUNT=690047714878
REGIONS="us-east-1 us-west-2"
ROLE=deployment-admin-role

escape-hatch-target:
	@echo "Running Escape hatch target"
	sh ../auth.sh $(ACCOUNT) $(ROLE) $(REGIONS) . your-target-here;
	@echo "Finished Running Escape hatch target"

deploy-generator:
	@echo "Deploying Data Generator";
	for i in $(AWS_REGIONS); \
	do \
	  echo "Deploy Trade Generator to $$i"; \
	  export REGION=$$i; \
	  export ACCOUNT_ID=$(ACCOUNT_ID); \
	  cd container_scripts/trade_matching_generator; \
	  sh archive.sh; \
	done
	echo "Finished Deploying Data Generator."

deploy-inbound:
	@echo "Deploying Inbound Gateway";
	for i in $(AWS_REGIONS); \
	do \
	  echo "Deploy Inbound Gateway to $$i"; \
	  export REGION=$$i; \
	  export ACCOUNT_ID=$(ACCOUNT_ID); \
	  cd container_scripts/trade_matching_inbound_gateway; \
	  sh archive.sh; \
	done
	echo "Finished Deploying Inbound Gateway."

deploy-ingress:
	@echo "Deploying Ingress";
	for i in $(AWS_REGIONS); \
	do \
	  echo "Deploy Ingress to $$i"; \
	  export REGION=$$i; \
	  export ACCOUNT_ID=$(ACCOUNT_ID); \
	  cd container_scripts/trade_matching_ingestion; \
	  sh archive.sh; \
	done
	echo "Finished Deploying Ingress."

deploy-core-ingestion:
	@echo "Deploying Core Ingestion";
	for i in $(AWS_REGIONS); \
	do \
	  echo "Deploy Core Ingestion to $$i"; \
	  export REGION=$$i; \
	  export ACCOUNT_ID=$(ACCOUNT_ID); \
	  cd container_scripts/trade_matching_core_ingestion; \
	  sh archive.sh; \
	done
	echo "Finished Deploying Core Ingestion."

deploy-core-matching:
	@echo "Deploying Core Matching";
	for i in $(AWS_REGIONS); \
	do \
	  echo "Deploy Core Matching to $$i"; \
	  export REGION=$$i; \
	  export ACCOUNT_ID=$(ACCOUNT_ID); \
	  cd container_scripts/trade_matching_core_matching; \
	  sh archive.sh; \
	done
	echo "Finished Deploying Core Matching."

deploy-egress:
	@echo "Deploying Egress";
	for i in $(AWS_REGIONS); \
	do \
	  echo "Deploy Egress to $$i"; \
	  export REGION=$$i; \
	  export ACCOUNT_ID=$(ACCOUNT_ID); \
	  cd container_scripts/trade_matching_egress; \
	  sh archive.sh; \
	done
	echo "Finished Deploying Egress."

deploy-outbound:
	@echo "Deploying Outbound gateway";
	for i in $(AWS_REGIONS); \
	do \
	  echo "Deploy Outbound gateway to $$i"; \
	  export REGION=$$i; \
	  export ACCOUNT_ID=$(ACCOUNT_ID); \
	  cd container_scripts/trade_matching_outbound_gateway; \
	  sh archive.sh; \
	done
	echo "Finished Deploying Outbound gateway."

deploy-reconciliation-app:
	@echo "Deploying Reconciliation";
	for i in $(AWS_REGIONS); \
	do \
	  echo "Deploy Reconciliation App to $$i"; \
	  export REGION=$$i; \
	  export ACCOUNT_ID=$(ACCOUNT_ID); \
	  cd container_scripts/reconciliation_app; \
	  sh archive.sh; \
	done
	echo "Finished Deploying Reconciliation."

deploy-settlement-inbound:
	@echo "Deploying Settlement Inbound Gateway";
	for i in $(AWS_REGIONS); \
	do \
	  echo "Deploy Settlement Inbound Gateway to $$i"; \
	  export REGION=$$i; \
	  export ACCOUNT_ID=$(ACCOUNT_ID); \
	  cd container_scripts/settlement_inbound_gateway; \
	  sh archive.sh; \
	done
	echo "Finished Deploying Settlement Inbound Gateway."

deploy-settlement-ingestion:
	@echo "Deploying Settlement Ingestion";
	for i in $(AWS_REGIONS); \
    do \
      echo "Deploy Settlement Ingestion to $$i"; \
      export REGION=$$i; \
      export ACCOUNT_ID=$(ACCOUNT_ID); \
      cd container_scripts/settlement_ingestion; \
      sh archive.sh; \
    done
	echo "Finished Deploying Settlement Ingestion."

deploy-settlement-core:
	@echo "Deploying Settlement Core Matching";
	for i in $(AWS_REGIONS); \
    do \
    	echo "Deploy Settlement Core matching to $$i"; \
      	export REGION=$$i; \
      	export ACCOUNT_ID=$(ACCOUNT_ID); \
      	cd container_scripts/settlement_core_matching; \
      	sh archive.sh; \
    done
	echo "Finished Deploying Settlement Core Matching."

deploy-settlement-egress:
	@echo "Deploying Settlement Egress";
	for i in $(AWS_REGIONS); \
    do \
      echo "Deploy Settlement Egress to $$i"; \
      export REGION=$$i; \
      export ACCOUNT_ID=$(ACCOUNT_ID); \
      cd container_scripts/settlement_egress; \
      sh archive.sh; \
    done
	echo "Finished Deploying Settlement Egress."

deploy-settlement-outbound:
	@echo "Deploying Settlement Outbound";
	for i in $(AWS_REGIONS); \
	do \
	  echo "Deploy Settlement Outbound to $$i"; \
	  export REGION=$$i; \
	  export ACCOUNT_ID=$(ACCOUNT_ID); \
	 cd container_scripts/settlement_outbound_gateway; \
	  sh archive.sh; \
	done
	echo "Finished Deploying Settlement Outbound."

deploy-tm: deploy-generator deploy-inbound deploy-ingress deploy-core-ingestion deploy-core-matching deploy-egress deploy-outbound deploy-reconciliation-app
deploy-st: deploy-settlement-inbound deploy-settlement-ingestion deploy-settlement-core deploy-settlement-egress deploy-settlement-outbound
deploy-all: deploy-tm deploy-st