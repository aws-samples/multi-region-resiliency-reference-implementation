#!/bin/bash
date
search='awsd1'
replace=$1
sed -i '' "s/$search/$replace/g" ./apps/common/remote-store/stores/backend.tf
sed -i '' "s/$search/$replace/g" ./apps/common/remote-store/stores/terraform.tfvars
sed -i '' "s/$search/$replace/g" ./apps/common/arc/backend.tf
sed -i '' "s/$search/$replace/g" ./apps/common/arccluster/backend.tf
sed -i '' "s/$search/$replace/g" ./apps/common/dbrotation/backend.tf
sed -i '' "s/$search/$replace/g" ./apps/common/chaos/backend.tf
sed -i '' "s/$search/$replace/g" ./apps/common/chaos/variables.tf
sed -i '' "s/$search/$replace/g" ./apps/common/ecsrole/backend.tf
sed -i '' "s/$search/$replace/g" ./apps/common/hub/backend.tf
sed -i '' "s/$search/$replace/g" ./apps/common/initialization/backend.tf
sed -i '' "s/$search/$replace/g" ./apps/common/lambda-layer/backend.tf
sed -i '' "s/$search/$replace/g" ./apps/common/mqdns/backend.tf
sed -i '' "s/$search/$replace/g" ./apps/common/mqreplication/backend.tf
sed -i '' "s/$search/$replace/g" ./apps/common/recon/backend.tf
sed -i '' "s/$search/$replace/g" ./apps/common/rotation/backend.tf
sed -i '' "s/$search/$replace/g" ./apps/common/rotation/variables.tf
sed -i '' "s/$search/$replace/g" ./apps/common/test/backend.tf
sed -i '' "s/$search/$replace/g" ./apps/common/vpcpeering/backend.tf
sed -i '' "s/$search/$replace/g" ./apps/trading/initialization/backend.tf
sed -i '' "s/$search/$replace/g" ./apps/trading/primary/backend.tf
sed -i '' "s/$search/$replace/g" ./apps/trading/primary/terraform.tfvars
sed -i '' "s/$search/$replace/g" ./apps/trading/secondary/backend.tf
sed -i '' "s/$search/$replace/g" ./apps/trading/secondary/terraform.tfvars
sed -i '' "s/$search/$replace/g" ./apps/trading/global/backend.tf
sed -i '' "s/$search/$replace/g" ./apps/settlement/initialization/backend.tf
sed -i '' "s/$search/$replace/g" ./apps/settlement/primary/backend.tf
sed -i '' "s/$search/$replace/g" ./apps/settlement/primary/terraform.tfvars
sed -i '' "s/$search/$replace/g" ./apps/settlement/secondary/backend.tf
sed -i '' "s/$search/$replace/g" ./apps/settlement/secondary/terraform.tfvars
sed -i '' "s/$search/$replace/g" ./apps/settlement/global/backend.tf
sed -i '' "s/$search/$replace/g" ./dashboard/api/backend.tf
sed -i '' "s/$search/$replace/g" ./dashboard/api/variables.tf
sed -i '' "s/$search/$replace/g" ./dashboard/infra/backend.tf
sed -i '' "s/$search/$replace/g" ./dashboard/infra/variables.tf

