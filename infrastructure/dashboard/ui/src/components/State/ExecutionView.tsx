// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import React, {FunctionComponent, useEffect, useState} from 'react';
import {Container, Button, ExpandableSection, StatusIndicator, Text} from "aws-northstar";
import Stack from "aws-northstar/layouts/Stack";
import '../home/styles.css';

import Grid from "aws-northstar/esm/layouts/Grid";
import {
  executeRunbook, getExecutionDetails,
} from "../../data";
import Flashbar, {FlashbarMessage} from "aws-northstar/components/Flashbar";
import Alert from "aws-northstar/components/Alert";
import {IExecution, IExecutionDetail, IExecutionStepDetail} from "../../interfaces";
import Table, {Column} from "aws-northstar/components/Table";
import {useDispatch, useSelector} from "react-redux";
import {useHistory} from "react-router-dom";
import {ReduxRoot} from "../../interfaces";

const ExecutionView: FunctionComponent = () => {

  const executionId = useSelector( (state:ReduxRoot) => {
    return state.approtationReducerState.executionId
  });

  const columnDefinitions: Column<IExecutionStepDetail>[]= [
    {
      id: 'step_number',
      width: 100,
      Header: 'Step #',
      accessor: 'step_number'
    },
    {
      id: 'step_name',
      width: 300,
      Header: 'Step Name',
      accessor: 'step_name'
    },
    {
      id: 'action',
      width: 200,
      Header: 'Action',
      accessor: 'action'
    },
    {
      id: 'step_status',
      width: 200,
      Header: 'Status',
      Cell: ({ row }: any) => {
        if (row && row.original) {
          const status = row.original.step_status;
          switch(status) {
            case 'Success':
              return <StatusIndicator  statusType='positive'>Success</StatusIndicator>;
            case 'Failed':
              return <StatusIndicator  statusType='negative'>Failed</StatusIndicator>;
            default:
              return <StatusIndicator  statusType='info'>{row.original.step_status}</StatusIndicator>;
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

  const [executionDetail, setExecutionDetail] = React.useState<IExecutionDetail>({});
  const [executionSteps, setExecutionSteps] = React.useState<IExecutionStepDetail[]>([]);
  const [selectedExecutionStepNumber, setSelectedExecutionStepNumber] = React.useState<number>(0);
  const [selectedExecutionStep, setSelectedExecutionStep] = React.useState<IExecutionStepDetail>({});
  const [loading, setLoading] = useState(false);
  const [errors, setErrors] = React.useState<FlashbarMessage[]>([]);
  const [message, setMessage] = React.useState<String>("");

  const renderMessage = () => {
    return (message == ""?<div/>:<Alert
            type="success"
            dismissible={true}
            buttonText="Clear"
            onButtonClick={() => setMessage("")}
        >
          {message}
        </Alert>
    );
  }

  const getExecution = async () => {

    await getExecutionDetails(executionId).then(
        (result: IExecutionDetail) => {
          console.log("Received Result in Execution Detail:" + JSON.stringify(result))
          setExecutionDetail(result)
          setExecutionSteps(result.steps?result.steps:[])
          if (selectedExecutionStepNumber > 0) {
            setSelectedExecutionStep(executionSteps[selectedExecutionStepNumber])
          }
        });
  }

  useEffect( () => {

    getExecution().then(() => console.log("getExecutionDetails() completed."));
    const interval = setInterval(() => {
      getExecution().then(() => console.log("getExecutionDetails() completed."));
      if (selectedExecutionStepNumber > 0) {
        setSelectedExecutionStep(executionSteps[selectedExecutionStepNumber])
      }
    }, 5000);
    return () => clearInterval(interval);
  }, []);

  const handleSelectionChange = (items: IExecutionStepDetail[]) => {
    if (items.length === 1) {
      const step_number: number = Number(items[0].step_number?items[0].step_number:0)
      setSelectedExecutionStepNumber(step_number)
      setSelectedExecutionStep(items[0])
    }
  };

  function renderValues(sampleJSON: any) {
    return (
        <div>
          {Object.keys(sampleJSON).map((key, i) => (
              <p key={i}>
                <div><b>{key}</b>{sampleJSON[key]}</div>
              </p>
          ))}
        </div>
    );
  }


  const renderInput = (value:any) => {
    return Object.entries(JSON.parse(value)).map((step) => {
      return (<div>
                <Grid container xs={12}>
                     <Grid xs={4} >
                       {step[0]}
                     </Grid>
                     <Grid xs={8} >
                       : {step[1]}
                    </Grid>
                </Grid>

              </div>
      );
    });
  }

  const renderLog = (value:any) => {
    value = value!=""?value.slice(1, -1):""
    const lines = value.split("\\n")
    return lines.map((line:any) => {
      return (<div>
            <Grid container xs={12}>
              <Grid xs={12}>
                {line.replace("\\n", "")}
              </Grid>
            </Grid>
          </div>
      );
    });
  }

  // const render_input = () => {
  //   let entries = Object.entries(selectedExecutionStep.input_payload?selectedExecutionStep.input_payload:{})
  //   for (var value in mapObject) {
  //     return (<div><b>{value}</b></div>)
  //   }
  // }

  // function render_value(value: string) {
  //   let response = ""
  //   response = "<div>"
  //   const new_value = value.slice(1, -1)
  //   response = response
  //   const key_value_pairs = new_value.split(",");
  //   for (const key_value_pair of key_value_pairs) {
  //     const key_value_array = key_value_pair.split(":");
  //     const key = key_value_array[0].slice(1, -1)
  //     const value = key_value_array[1].slice(1, -1)
  //     response = response + key + ": " + value +"<br/>"
  //   }
  //   response = response + "</div>"
  //   return response
  // }
  //
  // const renderSteps = (value: string) => {
  //   let response = ""
  //   response = "<div>"
  //   const new_value = value.slice(1, -1)
  //   response = response
  //   const key_value_pairs = new_value.split(",");
  //   for (const key_value_pair of key_value_pairs) {
  //   const key_value_array = key_value_pair.split(":");
  //   const key = key_value_array[0].slice(1, -1)
  //   const value = key_value_array[1].slice(1, -1)
  //      response = response + key + ": " + value +"<br/>"
  //   }
  //   response = response + "</div>"
  //   return response
  // }

  // const renderMap = (values: any) => {
  //   const values_map = Object.entries(values)
  //   return values_map.map(() => {
  //     return (<div></div>);
  //   });
  // }
  //
  // const renderSteps = () => {
  // }
  //

  function formatString(value: any) {

    return value.replace('\\n', '<br>')
  }

  const tableActions = (
      <div/>
  );

  return (
      <div>
        <Stack>
          <Table
            tableTitle={'Runbook Execution Detail'}
            columnDefinitions={columnDefinitions}
            loading={loading}
            items={executionSteps}
            actionGroup={tableActions}
            multiSelect={false}
            onSelectionChange={handleSelectionChange}
            getRowId={(originalRow: IExecutionStepDetail, relativeIndex: number) => {return originalRow.step_execution_id?originalRow.step_execution_id:""}}
            selectedRowIds={[selectedExecutionStep.step_execution_id?selectedExecutionStep.step_execution_id:""]}
          />
          <Grid container xs={12}>

            <Grid xs={2} className="border_black">
              <div className="spacing_5"><b>Input</b></div>
              <div className="spacing_5">{selectedExecutionStep.input_payload?renderInput(selectedExecutionStep.input_payload?selectedExecutionStep.input_payload:{}):""}</div>
            </Grid>

            <Grid xs={2} spacing={5} className="border_black">
              <div className="spacing_5"><b>Output</b></div>
              <div className="spacing_5">{selectedExecutionStep.output_payload?renderInput(selectedExecutionStep.output_payload?selectedExecutionStep.output_payload:{}):""}</div>
            </Grid>

            <Grid xs={8} spacing={5} className="border_black">
              <div className="spacing_5"><b>Execution Log</b></div>
              <div className="spacing_5">{selectedExecutionStep.execution_log?renderLog(selectedExecutionStep.execution_log?selectedExecutionStep.execution_log:""):""}</div>
            </Grid>
          </Grid>
          <Flashbar items={errors} />
        </Stack>
    </div>
  );

  // const renderSteps = () => {
  //   return executionSteps.map((step) => {
  //     return (<Grid container xs={12}>
  //               <Grid xs={1} className="border_black">
  //                 <div className="spacing_2 spacing_5">Step Number</div>
  //               </Grid>
  //               <Grid xs={3} spacing={5} className="border_black">
  //                 <div className="spacing_2 spacing_5">Step Name</div>
  //               </Grid>
  //               <Grid xs={1} spacing={5} className="border_black">
  //                 <div className="spacing_2 spacing_5">Action</div>
  //               </Grid>
  //               <Grid xs={1} spacing={5} className="border_black">
  //                 <div className="spacing_2 spacing_5">Step Status</div>
  //               </Grid>
  //               <Grid xs={3} spacing={5} className="border_black">
  //                 <div className="spacing_2 spacing_5">Start Time</div>
  //               </Grid>
  //               <Grid xs={3} spacing={5} className="border_black">
  //                 <div className="spacing_2 spacing_5">End Time</div>
  //               </Grid>
  //             </Grid>
  //     );
  //   });
  // }
  //
  // return (
  //     <Stack>
  //       <div>
  //         <div className="awsui-grid awsui-util-p-s">
  //           <div className="awsui-util-pt-xxl awsui-row">
  //             <div className="custom-home-main-content-area col-xxs-10 offset-xxs-1 col-s-6 col-l-5 offset-l-2 col-xl-6">
  //
  //               <Container headingVariant='h4'>
  //                 <Grid container spacing={3} className="spacing_10">
  //
  //                   <Grid item xs={12} spacing={5} className="border_black">
  //                     <div className="center">
  //                       <b>Execution Details</b>
  //                     </div>
  //                   </Grid>
  //
  //                   <Grid item xs={12} className="border_black">
  //                     <Stack>
  //                       <div className="center" >
  //                         <Grid container xs={12} className="spacing_5">
  //
  //                           <Grid item xs={12} spacing={1}>
  //                             <Stack spacing='s'>
  //
  //                               <div className="left">
  //
  //                                 <Grid container xs={12}>
  //                                   <Grid xs={1} className="border_black">
  //                                     <div className="spacing_2 spacing_5">Step Number</div>
  //                                   </Grid>
  //                                   <Grid xs={3} spacing={5} className="border_black">
  //                                     <div className="spacing_2 spacing_5">Step Name</div>
  //                                   </Grid>
  //                                   <Grid xs={1} spacing={5} className="border_black">
  //                                     <div className="spacing_2 spacing_5">Action</div>
  //                                   </Grid>
  //                                   <Grid xs={1} spacing={5} className="border_black">
  //                                     <div className="spacing_2 spacing_5">Step Status</div>
  //                                   </Grid>
  //                                   <Grid xs={3} spacing={5} className="border_black">
  //                                     <div className="spacing_2 spacing_5">Start Time</div>
  //                                   </Grid>
  //                                   <Grid xs={3} spacing={5} className="border_black">
  //                                     <div className="spacing_2 spacing_5">End Time</div>
  //                                   </Grid>
  //                                 </Grid>
  //
  //                                 {renderSteps}
  //
  //                               </div>
  //
  //                             </Stack>
  //                           </Grid>
  //
  //                           <Grid xs={12} className="spacing_5">
  //                           </Grid>
  //
  //                         </Grid>
  //                       </div>
  //
  //                     </Stack>
  //                   </Grid>
  //
  //                 </Grid>
  //               </Container>
  //
  //             </div>
  //
  //           </div>
  //         </div>
  //       </div>
  //       <div><Flashbar items={errors} /></div>
  //       {renderMessage()}
  //     </Stack>
  // );
}


export default ExecutionView;

