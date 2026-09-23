# Deployment Fixes — July 2026

This document describes every change made to restore this repository to a
deployable state on current AWS APIs, current Terraform/provider versions, and
a fresh AWS account. Changes are grouped by category, each with the failure it
addresses.

The deployment was verified end to end in a fresh account across us-east-1
(primary) and us-west-2 (secondary): all Terraform stacks apply cleanly, all
26 ECS services reach their desired count, and with the ARC routing controls
enabled a full round trip was observed — trade generator → trade-matching
in-gateway → ingestion → core matching (Aurora) → egress → outbound gateway →
settlement application (in-gateway → ingestion → matching → egress → outbound
gateway) → back to trade matching as settled trades — with DynamoDB global
table replication confirmed in the secondary region.

---

## 1. Terraform version and provider pinning

**Problem:** No stack pinned the AWS provider (`required_version = ">= 0.12"`
only). A fresh `terraform init` in 2026 resolves to AWS provider v6, which has
removed the syntax this codebase relies on. Two stacks (`dashboard/api`,
`common/dbrotation`) pinned `aws ~> 3.48.0` (July 2021), which conflicts with
current module requirements.

**Fixes:**
- Added a `versions.tf` to all 25 root stacks pinning `terraform >= 1.3` and
  `hashicorp/aws ~> 5.0`.
- Removed the inline `~> 3.48.0` provider blocks from `dashboard/api/main.tf`
  and `apps/common/dbrotation/main.tf` so the stack-level pin governs.
- Pinned the public registry modules, which were unpinned and had floated to
  major versions requiring AWS provider v6:
  - `terraform-aws-modules/vpc/aws` → `~> 5.0`
  - `terraform-aws-modules/dynamodb-table/aws` → `~> 4.0`
  - `terraform-aws-modules/s3-bucket/aws` → `~> 4.0`

## 2. Deprecated/removed Terraform syntax (fails on AWS provider v4+)

**Problem:** The codebase used resource arguments removed in AWS provider
v4/v5.

**Fixes:**
- `aws_s3_bucket` inline `acl`, `versioning`, `server_side_encryption_configuration`
  and `policy` blocks split into `aws_s3_bucket_versioning`,
  `aws_s3_bucket_server_side_encryption_configuration` and
  `aws_s3_bucket_policy` resources in: `modules/ecs`, `modules/amazonmq`,
  `apps/common/remote-store/stores/template`, `apps/common/chaos`,
  `apps/common/rotation`.
- `aws_s3_bucket_object` (removed) → `aws_s3_object` in `chaos`, `rotation`,
  `dbrotation`, `dashboard/api`.
- `skip_get_ec2_platforms` (removed provider argument) deleted from
  `modules/bucket`.
- `random_string`/`random_password` deprecated `number` argument → `numeric`
  (`modules/aurora`, `modules/api-gateway`, `apps/template/initialization`).

## 3. Route 53 Application Recovery Controller readiness — removed

**Problem:** Every `aws_route53recoveryreadiness_*` API call fails with
`AccessDeniedException: This operation is currently unavailable for new
accounts`. AWS has closed the ARC *readiness* feature set to new accounts, so
no fresh deployment can ever succeed with these resources.

**Fixes:**
- Deleted `apps/template/regional/route53-readiness-checks.tf` and
  `apps/template/global/route53-readiness-checks.tf` (cells, resource sets,
  readiness checks).
- Deleted the `apps/common/arc` stack entirely (it only created readiness
  recovery groups) and removed its Makefile targets and `replace.sh` entry.
- The ARC **routing controls and cluster** (`route53-recovery-control-config`
  / `route53-recovery-cluster`) are unaffected and remain — they are what the
  applications and failover runbooks actually use.

## 4. ECS on EC2 — launch configuration and AMIs

**Problem:** `aws_launch_configuration` cannot be created in accounts created
after Oct 2023 (AWS disabled launch configuration creation for new accounts).
The ECS AMIs were hardcoded 2022 image IDs that no longer exist.

**Fixes (`modules/ecs`):**
- Replaced the launch configuration with an `aws_launch_template` (IMDSv2
  required, encrypted EBS).
- AMI now resolved at deploy time from the public SSM parameter
  `/aws/service/ecs/optimized-ami/amazon-linux-2023/recommended/image_id`;
  removed the `ECS_AMIS` variable.
- ASG health check type changed `ELB` → `EC2` (no load balancer is attached
  to the ASG; the ELB resources were already commented out upstream).
- Default instance type `t2.large` → `t3.large` (current generation).

## 5. End-of-life engines and runtimes

| Component | Was | Now | Reason |
|---|---|---|---|
| Amazon MQ broker (`modules/amazonmq`) | ActiveMQ 5.16.4 | 5.18 | 5.16 end of support Nov 2024; new brokers cannot be created on it |
| MQ replication configuration (`common/mqreplication`) | ActiveMQ 5.15.0 | 5.18 | 5.15 end of support Sep 2024; must match broker version |
| Aurora (`modules/aurora`) | PostgreSQL 11.9, `db.r4.large`, `aurora-postgresql11` family | PostgreSQL 16.13, `db.r6g.large`, `aurora-postgresql16` family | PG 11 EOL Feb 2024; r4 previous generation; verified orderable in both regions |
| Lambda (`modules/api-gateway`, `common/lambda-layer`) | python3.8 | python3.12 | python3.8 Lambda runtime EOL Oct 2024; creation blocked |
| SSM Automation runbooks (`common/rotation`, `common/chaos` YAML) | python3.8 | python3.11 | current supported `aws:executeScript` runtime |
| NLB TLS listeners | `ELBSecurityPolicy-2016-08` | `ELBSecurityPolicy-TLS13-1-2-2021-06` | outdated TLS policy |

## 6. Account portability

**Problem:** Artifacts from the original development account were hardcoded
and cannot work anywhere else.

**Fixes:**
- Removed "AWS Corp" prefix-list ingress rules (`pl-4e2ece27`, `pl-5aa44133`)
  from `apps/template/regional/securitygroup.tf`. These prefix lists exist
  only in Amazon-internal accounts; VPC/peer CIDR rules already cover the
  workload's traffic.
- SSM runbook YAML (`common/rotation`, `common/chaos`): the hardcoded
  automation role ARN account `285719923712` replaced with an `<account_id>`
  placeholder substituted at apply time from `aws_caller_identity`.
- `common/rotation` attachment URL pointed at a bucket from a different
  environment (`approtation-rotation-proto`); now points at the bucket the
  stack itself creates.
- Attachment checksums were read from a committed `checksum.txt` generated by
  a `null_resource` provisioner; a stale/missing file broke SSM document
  creation (checksums must match the uploaded zip). Now computed directly
  from `archive_file.output_sha256`; `checksum.txt` and the `null_resource`
  removed.
- `trust-policy.json` (referenced by `make create-role` and the README but
  missing from the repo) added with an `<ACCOUNT_ID>` placeholder.

## 7. Service quotas and API validation

- **NAT gateways:** each of the 4 VPCs created 3 NAT gateways = 12 EIPs,
  exceeding the default quota of 5 EIPs/region. `modules/vpc` now sets
  `single_nat_gateway = true` (1 per VPC). Consequence: private subnets share
  one route table, so `modules/vpc-peering` was rewritten to deduplicate
  route-table IDs with `for_each` (wrapped in `nonsensitive()` because the
  IDs are read from Secrets Manager).
- **ELB access logs:** ELB log delivery does not support SSE-KMS buckets. The
  NLB/ELB log buckets in `modules/amazonmq` and `modules/ecs` now use SSE-S3
  (AES256), and the NLB depends on the bucket *policy* (now a separate
  resource) so log-delivery validation passes at create time.
- **Private CA validity chain (`modules/private-ca`):** ACM issues private
  certificates valid 13 months, but the subordinate CA certificate was only
  valid 10 months (and the trading root CA 1 year), so every certificate
  issuance failed with `PCA_INVALID_DURATION`. Subordinate CA validity is now
  5 years, the trading initialization root CA validity 10 years (matching
  settlement), and the subordinate CA certificate now `depends_on` the
  installed root CA certificate to avoid a race where it is signed by the
  not-yet-activated root.

## 8. Application containers

- **Dockerfile comment syntax:** files began with `//` comments, which Docker
  rejects as an unknown instruction. Changed to `#`.
- **Gradle build moved from container startup into the image build.**
  Previously every ECS task ran `gradle build` at startup; ~30 concurrent
  tasks behind one NAT IP were rate-limited by Maven Central (HTTP 429),
  builds failed, the missing jar caused an immediate exit, and every service
  crash-looped indefinitely. Jars are now compiled once per image
  (`RUN gradle build -x test`), which also removes multi-minute cold starts.
  `ARG`/`ENV` lines moved after the build layer so the second region's build
  is a cache hit.
- **`settings.gradle` added to all 11 Java services.** Without it, Gradle
  names the jar after the build directory, while every `start.sh` expects the
  original internal project names (e.g. `app.inbound.gateway-0.0.1-SNAPSHOT.jar`).
  No task could ever find its jar. The added files pin the expected
  `rootProject.name` per service.
- **Deleted dead class** `trade_matching_inbound_gateway/.../InboundGatewayService.java`:
  it imports `ConsumerMessageListener`, a class that was never included in the
  open-source snapshot, so the service could not compile. Nothing references
  the class; message consumption is handled by the Spring `@JmsListener`
  `Receiver`.
- **Added `liquibase-core` to `trade_matching_core_matching`.** The service
  ships Liquibase changelogs that create its Aurora schema (`trade_message`,
  `trade_allocation`), but the dependency was missing (the settlement
  counterpart has it), so the schema was never created and the service
  crash-looped on `relation "trade_message" does not exist`.
- **Reconciliation image modernized:** base image `amazonlinux:2` (EOL June
  2025) that compiled Python 3.9 from source on every build replaced with
  `python:3.9-slim` + AWS CLI v2; Python dependencies installed at image
  build instead of container startup.
- **`archive.sh` scripts:** `DOCKER_BUILDKIT=0` replaced with
  `DOCKER_DEFAULT_PLATFORM=linux/amd64` so images built on Apple Silicon
  match the x86_64 ECS instances. The reconciliation script now also tags and
  pushes `settlement-reconciliation-ecr` (the ECR repo existed but nothing
  ever pushed to it).
- **TLS certificates for the gateways:** the containers import
  per-app/direction/region certificates from a `container_scripts/certs/`
  directory that was never shipped. Added
  `apps/container_scripts/generate_certs.sh`, which exports the deployed ACM
  private certificates (leaf PEM/DER, issuing-CA DER, decrypted private key)
  into the expected layout. Run it after the infrastructure deploy and before
  building images. The directory is gitignored (it contains private keys).
  Also fixed a missing `.der` extension in
  `settlement_outbound_gateway/start.sh`.
- **`apps/Makefile`:** removed the `deploy-core-ingestion` target — it
  referenced `container_scripts/trade_matching_core_ingestion`, a directory
  that does not exist and never has in this repository.
- **`apps/tasks/requirements.txt`:** added `click` (imported by
  `ecs_tasks.py` but not declared) and repaired missing-newline corruption.

## 9. State store bootstrap cleanup

`apps/common/remote-store/stores/main.tf` instantiated two generations of
bucket templates. The legacy generation (21 modules, `approtation-*` bucket
names with random suffixes) is referenced by no `backend.tf` in the repo and
used removed provider syntax. Legacy modules and the `remote-store/template`
directory were deleted; only the buckets the backends actually use remain.

## 10. Dashboard

The dashboard (API, hosting infrastructure, and React UI) was not deployable
or usable from the open-source snapshot. It is now deployed and verified,
including a full managed-failover of the trade-matching application executed
through the dashboard's runbook API (all 29 runbook steps succeeded; the
Aurora global database writer moved to the standby region and processing
resumed there).

### 10.1 API (`infrastructure/dashboard/api`)

- **psycopg2 Lambda layer.** `api.py` imports `psycopg2` at module level, so
  every one of the 18 Lambdas failed at init — the dependency was never
  provided by the repo. Added `build_layer.sh`, which packages the
  `psycopg2-binary` manylinux wheel for the python3.12 x86_64 runtime into
  `psycopg2_layer.zip`, an `aws_lambda_layer_version` resource, and a
  `LAYERS` input on the api-gateway module (attached to all 18 APIs). Run
  `build_layer.sh` before `terraform apply`.
- **`get_app_ready` rewritten.** It called the Route 53 ARC *readiness* APIs,
  which are closed to new AWS accounts (see section 3). Readiness is now
  derived from the live resources themselves: DynamoDB global-table replica
  status, Aurora global database member availability, and ECS cluster
  capacity in both regions. The response shape and the summary logic are
  unchanged, so the UI works as before. The
  `route53-recovery-readiness:*` IAM permission was removed.
- **`get_app_recons` implemented.** The handler was wired to API Gateway but
  the function did not exist in the snapshot (only a commented-out draft), so
  the Lambda failed with `Runtime.HandlerNotFound`. A minimal implementation
  returning the aggregate object shape was added; the UI performs per-step
  reconciliation through `get_app_recon_step`, which is intact.
- **Log group creation race.** The module created each function's log group
  named from the function resource, but provisioned concurrency initializes
  the Lambda immediately, auto-creating the log group first and failing the
  apply with `ResourceAlreadyExistsException`. Log groups are now named from
  the input variable and the Lambdas `depends_on` them.
- **v5 provider syntax** for the Lambda-code bucket (split versioning/SSE),
  as elsewhere.
- **UI config outputs.** The stack now exposes a sensitive `ui_config` output
  (endpoint, API key, and resource path for each of the 18 APIs) consumed by
  `../generate_ui_config.sh`.

### 10.2 Hosting (`infrastructure/dashboard/infra`)

- **SSE-KMS + Origin Access Identity = broken site.** The website bucket
  defaulted to SSE-KMS while CloudFront used a legacy OAI, which cannot
  decrypt KMS-encrypted objects — S3 returned 400 for every asset and the
  dashboard rendered a blank page. This was broken upstream as well. The
  website bucket was temporarily downgraded to SSE-S3, and the distribution
  has since been migrated to an origin access control (OAC), restoring
  SSE-KMS with a customer-managed key and pinning bucket access to the
  distribution ARN.
- **WAF allowlist parameterized, dual-stack.** The allowlist was a hardcoded
  IPv4 address from the original developer's home network. It is now driven
  by `ALLOWED_IP_CIDRS` (IPv4) and `ALLOWED_IPV6_CIDRS` (IPv6) variables —
  both default to an empty list, which blocks all access until the deployer
  supplies their CIDRs (e.g. via `terraform.tfvars`, which is gitignored).
  A second WAF rule with an IPv6 IP set was added because the distribution
  is dual-stack: IPv6 visitors were evaluated only against the IPv4 set and
  blocked. For IPv6, allow your network's /64 prefix — client privacy
  extensions rotate the host portion of the address.
- **Content types corrected** for uploaded assets (`png`, `ico`, `txt`, `map`
  were served as `text/html`), with a fallback for unknown extensions.
- **v5 provider syntax**: split bucket versioning/SSE; removed the standalone
  `aws_s3_bucket_acl` (new buckets enforce bucket-owner ownership and reject
  ACLs).

### 10.3 UI (`infrastructure/dashboard/ui`)

- **Hardcoded endpoints and API keys removed.** `src/config/index.ts`
  contained 18 API Gateway URLs and plaintext API keys from the original
  environment. The committed file is now a placeholder;
  `infrastructure/dashboard/generate_ui_config.sh` generates the real file
  from the deployed API stack's Terraform outputs. Do not commit the
  generated file — it contains live API keys.
- **Build fixes** (the app did not compile from the snapshot):
  - Removed an import of `@okta/okta-react`, a dependency not present in
    `package.json`; all other Okta code was already commented out upstream.
  - Added `src/components/home/approtation.png` (imported by the home page
    but missing from the repo) using the repository's architecture diagram.
  - Pinned dev dependencies `ajv@^8` and `@types/react@^17` — with npm's
    legacy peer resolution the hoisted versions (ajv 6 / React 19 types)
    break react-scripts 5 and the React 17 component typings.
  - Set `useUnknownInCatchVariables: false` in `tsconfig.json`; the code
    predates TypeScript 4.4's stricter catch-variable typing.
- Install with `npm install --legacy-peer-deps` (React 17-era peer
  dependency tree), then `npm run build`.

### 10.4 Dashboard deployment order

1. `infrastructure/dashboard/api`: `./build_layer.sh`, then
   `terraform init && terraform apply`
2. `infrastructure/dashboard/generate_ui_config.sh`
3. `infrastructure/dashboard/ui`: `npm install --legacy-peer-deps && npm run build`
4. `infrastructure/dashboard/infra`: set `ALLOWED_IP_CIDRS` /
   `ALLOWED_IPV6_CIDRS` in `terraform.tfvars`, then
   `terraform init && terraform apply`

## 11. Teardown and redeployment (verified with a full destroy/redeploy cycle)

- **`destroy-trading-initialization` / `destroy-settlement-initialization`
  destroyed the wrong stacks** — both changed into the `primary` directory
  instead of `initialization`. Fixed.
- **Destroy order was inverted.** `destroy-trading`/`destroy-settlement` ran
  primary → secondary → global, but the global stack's Aurora clusters live
  inside the regional VPCs, so regional destroys fail while the databases
  exist. Order is now global → secondary → primary → initialization, and
  `destroy-all` covers the full chain (`destroy-after` → apps →
  `destroy-before`), mirroring `deploy-all` in reverse.
- **AWS Backup vaults blocked destroy** once a daily backup had run (vaults
  cannot be deleted while they contain recovery points, and Terraform cannot
  empty them). Added `infrastructure/empty_backup_vaults.sh`, invoked
  automatically by the app destroy targets.
- **ECR repositories blocked destroy** because they contain images; added
  `force_delete = true` to the repository in `modules/ecs`.
- **Deletion protection on the MQ NLBs and Aurora clusters blocked destroy.**
  Both are now disabled with a comment recommending enabling them in
  production — a sample must be tear-down-able with `make destroy-all`.
- **Redeploy after destroy collided with secrets scheduled for deletion**:
  the `arc-health-check` secret was created inline without
  `recovery_window_in_days = 0` (everything else goes through
  `modules/secret`, which already sets it). Fixed, with
  `force_overwrite_replica_secret` for the cross-region replica.
- **`auth.sh` sessions were limited to 1 hour** (STS default), far shorter
  than the deployment. `make create-role` now sets a 12-hour maximum session
  and `auth.sh` requests it, falling back to 1 hour when the caller is
  itself an assumed role (AWS caps role-chained sessions). `auth.sh` also no
  longer echoes the temporary credentials to stdout.
- Operational notes captured in the README troubleshooting section: Aurora
  writer must be in the primary region before destroy (switch back with
  `aws rds switchover-global-cluster` after failover demos), KCL lease
  tables are created at runtime outside Terraform, and transient
  `VpcEndpoint modify operation in progress` errors resolve on rerun.

## 12. Known remaining work (intentionally out of scope here)

- ~~**dbrotation**~~: rewritten (python 3.12, dynamic resource resolution,
  both applications, on-demand invocation with dry-run) as the database
  state reset tool; the dashboard readiness view now surfaces
  writer-vs-controls drift. See the README "Operations" section.
- `apps/common/cicd` module has undeclared variables/undefined resources and
  does not plan; it is not part of the deploy chain.
- `apps/common/cloudwatch` hardcodes us-east-1 stream names; not part of the
  deploy chain.
