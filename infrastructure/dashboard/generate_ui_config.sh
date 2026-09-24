#!/bin/bash
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0
#
# Generates ui/src/config/index.ts from the deployed dashboard API stack.
# Run after `terraform apply` in ./api and before building the UI.
set -euo pipefail
cd "$(dirname "$0")"

JSON_FILE=$(mktemp)
trap 'rm -f "$JSON_FILE"' EXIT
terraform -chdir=api output -json ui_config > "$JSON_FILE"

python3 - "$JSON_FILE" "$(pwd)/ui/src/config/index.ts" <<'PYEOF'
import json, sys

with open(sys.argv[1]) as f:
    config = json.load(f)
out_path = sys.argv[2]

ORDER = [
    "APP_STATE_ENDPOINTS", "APP_STATES_ENDPOINTS", "APP_CONTROLS_ENDPOINTS",
    "ARC_CONTROL_ENDPOINTS", "RUNBOOK_ENDPOINTS", "APP_RECONS_ENDPOINTS",
    "APP_RECON_STEP_ENDPOINTS", "APP_READY_ENDPOINTS", "APP_HEALTH_ENDPOINTS",
    "APP_REPLICATION_ENDPOINTS", "START_APP_ENDPOINTS", "STOP_APPS_ENDPOINTS",
    "CLEAN_DATABASES_ENDPOINTS", "EXECUTIONS_ENDPOINTS", "EXECUTION_DETAIL_ENDPOINTS",
    "EXPERIMENT_ENDPOINTS", "START_APP_COMPONENT_ENDPOINTS", "ENABLE_VPC_ENDPOINTS",
]

lines = [
    "// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.",
    "// SPDX-License-Identifier: MIT-0",
    "//",
    "// GENERATED FILE - do not edit by hand.",
    "// Regenerate with infrastructure/dashboard/generate_ui_config.sh",
    "",
]
for name in ORDER:
    entry = config[name]
    lines.append(f"export const {name} = {{")
    lines.append(f"    ApiKey: '{entry['ApiKey']}',")
    lines.append(f"    Endpoint: '{entry['Endpoint']}',")
    lines.append(f"    Resources : ['{entry['Resource']}']")
    lines.append("};")
    lines.append("")

with open(out_path, "w") as f:
    f.write("\n".join(lines))
print(f"Wrote {out_path} ({len(ORDER)} endpoints)")
PYEOF
