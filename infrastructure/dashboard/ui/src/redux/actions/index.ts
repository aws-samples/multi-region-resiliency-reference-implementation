// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

export enum ActionTypes {
    STORE_EXECUTION_ID = "STORE_EXECUTION_ID"
}

export const storeExecutionId = (executionId:string) => ({
    type: ActionTypes.STORE_EXECUTION_ID, executionId
})