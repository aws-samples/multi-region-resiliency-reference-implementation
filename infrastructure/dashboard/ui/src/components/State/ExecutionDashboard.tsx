// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import React, { FunctionComponent } from 'react';
import Stack from 'aws-northstar/layouts/Stack';
import ExecutionTable from "./ExecutionTable";

const ExecutionDashboard: FunctionComponent = () => {
  return <Stack>
    <ExecutionTable/>
  </Stack>
}

export default ExecutionDashboard;