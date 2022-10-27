// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import React, {FunctionComponent, useEffect, useState} from 'react';
import { useHistory } from 'react-router-dom';
import Table, { Column } from 'aws-northstar/components/Table';
import {getExecutions} from "../../data";
import {IExecution, IExecutionStepDetail} from "../../interfaces";
import '../home/styles.css';
import {StatusIndicator, Link} from "aws-northstar";
import Stack from 'aws-northstar/layouts/Stack';

import Flashbar, {FlashbarMessage} from "aws-northstar/components/Flashbar";
import {useDispatch, useSelector} from "react-redux";
import ApplicationAdmin from "./ApplicationAdmin";
import {storeExecutionId} from "../../redux/actions";

const ExecutionTable: FunctionComponent = () => {

  const columnDefinitions: Column<IExecution>[]= [
    {
      id: 'automation_execution_id',
      width: 300,
      Header: 'Execution Id',
      Cell: ({ row }: any) => {
          return <Link onClick={() => dispatchExecutionId(row.original.automation_execution_id)} href="/Runbook-Execution-Detail">{row.original.automation_execution_id}</Link>;
      }
    },
    {
      id: 'document_name',
      width: 300,
      Header: 'Document',
      accessor: 'document_name'
    },
    {
      id: 'automation_execution_status',
      width: 150,
      Header: 'Status',
      Cell: ({ row }: any) => {
        if (row && row.original) {
          const status = row.original.automation_execution_status;
          switch(status) {
            case 'Success':
              return <StatusIndicator  statusType='positive'>Success</StatusIndicator>;
            case 'Failed':
              return <StatusIndicator  statusType='negative'>Failed</StatusIndicator>;
            default:
              return <StatusIndicator  statusType='info'>{row.original.automation_execution_status}</StatusIndicator>;
          }
        }

        return row.automation_execution_status;
      }
    },
    {
      id: 'execution_start_time',
      width: 300,
      Header: 'Start Time',
      accessor: 'execution_start_time'
    },
    {
      id: 'execution_end_time',
      width: 300,
      Header: 'End Time',
      accessor: 'execution_end_time'
    },
  ];

  const dispatch = useDispatch();
  const history = useHistory();

  const onOpenExecutionView = () => {
    history.push("/Runbook-Execution-Detail");
  }

  const [executions, setExecutions] = useState<IExecution[]>([]);
  const [selectedExecution, setSelectedExecution] = React.useState<IExecution>({});
  const [selectedItems, setSelectedItems] = useState<IExecution[]>([]);

  const [loading, setLoading] = useState(false);
  const [errors, setErrors] = React.useState<FlashbarMessage[]>([]);

  const getAllRequests = async () => {

    try {

      setLoading(true)
      await getExecutions().then(
          (result: IExecution[]) => {
            console.log("Received Result :" + JSON.stringify(result))
            setExecutions(result);
          });
      setLoading(false)

      await Promise.resolve();

    }
    catch (err) {
      const items:FlashbarMessage[] = [
        {
          header: 'Could not get the executions: ' + err.toString(),
          type: 'error',
          dismissible: true,
        }
      ];
      setErrors(items);
    }
  }

  useEffect( () => {

    getAllRequests().then(() => console.log("getExecutions() completed."));
  }, []);

  const handleSelectionChange = (items: IExecution[]) => {
    if (items.length === 1) {
      setSelectedExecution(items[0]);
      dispatchExecutionId(items[0].automation_execution_id?items[0].automation_execution_id:"");
    }
  };

  const dispatchExecutionId = (executionId: string) => {
    console.log("Dispatch is Called : " + executionId)
    dispatch(storeExecutionId(executionId));
  }

  const tableActions = (
      <div/>
  );

  return ( <Stack><div><Table
      tableTitle={'Runbook Executions'}
      columnDefinitions={columnDefinitions}
      loading={loading}
      items={executions}
      actionGroup={tableActions}
      multiSelect={false}
      onSelectionChange={handleSelectionChange}
    />
    <Flashbar items={errors} />
  </div></Stack>);
}

export default ExecutionTable;