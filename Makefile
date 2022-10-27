REGION=us-east-1
.DEFAULT_GOAL := deploy-all
MAKE=/usr/bin/make
ACCOUNT=690047714878
REGIONS="us-east-1 us-west-2"
ROLE=deployment-admin-role

deploy-infra:
	@echo "Deploying Infrastructure"
	sh auth.sh $(ACCOUNT) $(ROLE) $(REGIONS) infrastructure prerequisites;
	sh auth.sh $(ACCOUNT) $(ROLE) $(REGIONS) infrastructure deploy-all;
	@echo "Finished Deploying Infrastructure"

destroy-infra:
	@echo "Destroying Infrastructure"
	sh auth.sh $(ACCOUNT) $(ROLE) $(REGIONS) infrastructure destroy-all;
	@echo "Finished Destroying Infrastructure"

deploy-apps:
	@echo "Deploying Applications"
	sh auth.sh $(ACCOUNT) $(ROLE) $(REGIONS) apps deploy-all;
	@echo "Finished Deploying Applications"

create-role:
	@echo "Creating role for account $(ACCOUNT)"
	(aws iam create-role --role-name $(ROLE) --assume-role-policy-document file://trust-policy.json; \
	aws iam attach-role-policy --role-name $(ROLE) --policy-arn arn:aws:iam::aws:policy/AdministratorAccess;)
	@echo "Finished creating role for account $(ACCOUNT)"

test-creds:
	sh auth.sh $(ACCOUNT) $(ROLE) $(REGIONS);

deploy-all: deploy-infra deploy-apps