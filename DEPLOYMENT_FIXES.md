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

## 10. Known remaining work (intentionally out of scope here)

- **Dashboard** (`infrastructure/dashboard`): UI has hardcoded API endpoints
  and API keys from the original environment; `api/src/api.py` and its IAM
  policy still reference the removed Recovery Readiness APIs; the Lambdas
  import `psycopg2`, which needs a layer/vendored build for the new runtime.
- **dbrotation** (`apps/common/dbrotation`): nodejs12.x runtime (EOL), AWS
  SDK v2, hardcoded original-account ARNs and ARC cluster endpoints, and no
  trigger wired to it. The SSM rotation runbooks perform Aurora failover
  independently of it.
- `apps/common/cicd` module has undeclared variables/undefined resources and
  does not plan; it is not part of the deploy chain.
- `apps/common/cloudwatch` hardcodes us-east-1 stream names; not part of the
  deploy chain.
