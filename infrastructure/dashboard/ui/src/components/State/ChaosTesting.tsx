// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import React, {FunctionComponent, useEffect, useState} from 'react';
import {Container, Button, StatusIndicator, ExpandableSection} from "aws-northstar";
import Stack from "aws-northstar/layouts/Stack";
import '../home/styles.css';
import {IAppHealth, IAppReady, IAppReplication} from "../../interfaces";

import Grid from "aws-northstar/esm/layouts/Grid";
import {
  enableVPCEndpoint,
  executeRunbook,
  getAppHealth,
  getAppReady,
  getAppReplication, runExperiment, startAppComponent,
} from "../../data";
import Flashbar, {FlashbarMessage} from "aws-northstar/components/Flashbar";
import Alert from "aws-northstar/components/Alert";

const ChaosTesting: FunctionComponent = () => {

  const [appReady, setAppReady] = useState<IAppReady>({});
  const [appHealth, setAppHealth] = useState<IAppHealth>({});
  const [appReplication, setAppReplication] = useState<IAppReplication>({});
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

  const execute = async () => {

    try {
      setMessage("Test Scenario Not Yet Implemented")
    }
    catch (err) {
      const items:FlashbarMessage[] = [
        {
          header: 'Could not get the app state: ' + err.toString(),
          type: 'error',
          dismissible: true,
        }
      ];
      setErrors(items);
    }
  }

  const executeExperiment = async (scenario: any) => {
    setMessage("Initiated Execution of Scenario: " + scenario)
    let request = await runExperiment("us-east-1", scenario).then(
        (result: any) => {
          console.log("Received Result :" + JSON.stringify(result))
        });
  }

  const recoverAppComponent = async (app: string, component: string) => {
    setMessage("Initiated Recovery of App Component: " + app + " component")
    let request = await startAppComponent("us-east-1", app, component).then(
        (result: any) => {
          console.log("Received Result :" + JSON.stringify(result))
        });
  }

  const recoverVPCAccess = async (app: string, service: string) => {
    setMessage("Initiated Recovery of Service Access: " + service)
    let request = await enableVPCEndpoint("us-east-1", app, service).then(
        (result: any) => {
          console.log("Received Result :" + JSON.stringify(result))
        });
  }

  return (
      <Grid>
        <div>
          <div className="awsui-grid awsui-util-p-s">
            <div className="awsui-util-pt-xxl awsui-row">
              <div className="custom-home-main-content-area col-xxs-10 offset-xxs-1 col-s-6 col-l-5 offset-l-2 col-xl-6">

                <Container headingVariant='h4'>
                  <Grid container spacing={3} className="spacing_10">

                    <Grid item xs={12} spacing={5} className="border_black">
                      <div className="center">
                        <b>Chaos Testing</b>
                      </div>
                    </Grid>

                    <Grid item xs={12} className="border_black">
                      <Grid>
                        
                        <ExpandableSection variant="default" header="Trade Matching">

                          <Grid container xs={12} className="spacing_5">
                            <Grid item xs={12} spacing={1}>
                              <Stack spacing='s'>

                                <ExpandableSection variant="default" header="1. ECS: Stop All ECS Tasks In A Component">

                                  <Grid container xs={12} className="spacing_5">
                                    <Grid item xs={12} spacing={1}>
                                      <Stack spacing='s'>
                                        <div className="left">

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">Scenario</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Application</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Component</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Description</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10"></div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">TM_001_01</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Trade Matching</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Inbound Gateway</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stop All ECS Tasks</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("tm-in-gateway-stop-all-ECS-tasks")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => recoverAppComponent("trade-matching", "in-gateway")}>Recover</Button>
                                              </div>
                                            </Grid>

                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">TM_001_02</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Trade Matching</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Ingress</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stop All ECS Tasks</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("tm-ingress-stop-all-ECS-tasks")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => recoverAppComponent("trade-matching", "ingress")}>Recover</Button>
                                              </div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">TM_001_03</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Trade Matching</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Core Matching</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stop All ECS Tasks</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("tm-core-matching-stop-all-ECS-tasks")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => recoverAppComponent("trade-matching", "core-matching")}>Recover</Button>
                                              </div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">TM_001_04</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Trade Matching</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Egress</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stop All ECS Tasks</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("tm-egress-stop-all-ECS-tasks")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => recoverAppComponent("trade-matching", "egress")}>Recover</Button>
                                              </div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">TM_001_05</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Trade Matching</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Out Gateway</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stop All ECS Tasks</div>
                                            </Grid>


                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("tm-out-gateway-stop-all-ECS-tasks")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => recoverAppComponent("trade-matching", "out-gateway")}>Recover</Button>
                                              </div>
                                            </Grid>

                                          </Grid>

                                        </div>

                                      </Stack>

                                    </Grid>

                                  </Grid>

                                </ExpandableSection>

                                <ExpandableSection variant="default" header="2. ECS: Stop One ECS Task In A Component">

                                  <Grid container xs={12} className="spacing_5">
                                    <Grid item xs={12} spacing={1}>
                                      <Stack spacing='s'>
                                        <div className="left">

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">Scenario</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Application</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Component</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Description</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10"></div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">TM_002_01</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Trade Matching</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Inbound Gateway</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stop One ECS Task</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("tm-in-gateway-stop-one-ECS-task")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => recoverAppComponent("trade-matching", "in-gateway")}>Recover</Button>
                                              </div>
                                            </Grid>

                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">TM_002_02</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Trade Matching</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Ingress</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stop One ECS Task</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("tm-ingress-stop-one-ECS-task")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => recoverAppComponent("trade-matching", "ingress")}>Recover</Button>
                                              </div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">TM_002_03</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Trade Matching</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Core Matching</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stop One ECS Task</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("tm-core-matching-stop-one-ECS-task")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => recoverAppComponent("trade-matching", "core-matching")}>Recover</Button>
                                              </div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">TM_002_04</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Trade Matching</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Egress</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stop One ECS Task</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("tm-egress-stop-one-ECS-task")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => recoverAppComponent("trade-matching", "egress")}>Recover</Button>
                                              </div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">TM_002_05</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Trade Matching</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Out Gateway</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stop One ECS Task</div>
                                            </Grid>


                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("tm-out-gateway-stop-one-ECS-task")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => recoverAppComponent("trade-matching", "out-gateway")}>Recover</Button>
                                              </div>
                                            </Grid>

                                          </Grid>

                                        </div>

                                      </Stack>

                                    </Grid>

                                  </Grid>

                                </ExpandableSection>

                                <ExpandableSection variant="default" header="3. ECS: Stop All ECS EC2 Instances In A Component">
                                  <Grid container xs={12} className="spacing_5">
                                    <Grid item xs={12} spacing={1}>
                                      <Stack spacing='s'>
                                        <div className="left">

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">Scenario</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Application</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Component</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Description</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10"></div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">TM_003_01</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Trade Matching</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Inbound Gateway</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stop All ECS EC2 Instances</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("tm-in-gateway-stop-all-ECS-EC2-instances")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                              </div>
                                            </Grid>

                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">TM_003_02</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Trade Matching</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Ingress</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stop All ECS EC2 Instances</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("tm-ingress-stop-all-ECS-EC2-instances")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                              </div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">TM_003_03</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Trade Matching</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Core Matching</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stop All ECS EC2 Instances</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("tm-core-matching-stop-all-ECS-EC2-instances")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                              </div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">TM_003_04</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Trade Matching</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Egress</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stop All ECS EC2 Instances</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("tm-egress-stop-all-ECS-EC2-instances")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                              </div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">TM_003_05</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Trade Matching</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Out Gateway</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stop All ECS EC2 Instances</div>
                                            </Grid>


                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("tm-out-gateway-stop-all-ECS-EC2-instances")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                              </div>
                                            </Grid>

                                          </Grid>

                                        </div>

                                      </Stack>

                                    </Grid>

                                  </Grid>

                                </ExpandableSection>

                                <ExpandableSection variant="default" header="4. ECS: Stop One ECS EC2 Instance In A Component">

                                  <Grid container xs={12} className="spacing_5">
                                    <Grid item xs={12} spacing={1}>
                                      <Stack spacing='s'>
                                        <div className="left">

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">Scenario</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Application</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Component</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Description</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10"></div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">TM_004_01</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Trade Matching</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Inbound Gateway</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stop One ECS EC2 Instance</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("tm-in-gateway-stop-one-ECS-EC2-instance")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                              </div>
                                            </Grid>

                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">TM_004_02</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Trade Matching</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Ingress</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stop One ECS EC2 Instance</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("tm-ingress-stop-one-ECS-EC2-instance")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                              </div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">TM_004_03</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Trade Matching</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Core Matching</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stop One ECS EC2 Instance</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("tm-core-matching-stop-one-ECS-EC2-instance")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                              </div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">TM_004_04</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Trade Matching</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Egress</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stop One ECS EC2 Instance</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("tm-egress-stop-one-ECS-EC2-instance")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                              </div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">TM_004_05</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Trade Matching</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Out Gateway</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stop One ECS EC2 Instances</div>
                                            </Grid>


                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("tm-out-gateway-stop-one-ECS-EC2-instance")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                              </div>
                                            </Grid>

                                          </Grid>

                                        </div>

                                      </Stack>

                                    </Grid>

                                  </Grid>

                                </ExpandableSection>

                                <ExpandableSection variant="default" header="5. ECS: Terminate All ECS EC2 Instances In A Component">

                                  <Grid container xs={12} className="spacing_5">
                                    <Grid item xs={12} spacing={1}>
                                      <Stack spacing='s'>
                                        <div className="left">

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">Scenario</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Application</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Component</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Description</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10"></div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">TM_005_01</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Trade Matching</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Inbound Gateway</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Terminate All ECS EC2 Instances</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("tm-in-gateway-terminate-all-ECS-EC2-instances")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                              </div>
                                            </Grid>

                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">TM_005_02</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Trade Matching</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Ingress</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Terminate All ECS EC2 Instances</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("tm-ingress-terminate-all-ECS-EC2-instances")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                              </div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">TM_005_03</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Trade Matching</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Core Matching</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Terminate All ECS EC2 Instances</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("tm-core-matching-terminate-all-ECS-EC2-instances")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                              </div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">TM_005_04</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Trade Matching</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Egress</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Terminate All ECS EC2 Instances</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("tm-egress-terminate-all-ECS-EC2-instances")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                              </div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">TM_005_05</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Trade Matching</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Out Gateway</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Terminate All ECS EC2 Instances</div>
                                            </Grid>


                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("tm-out-gateway-terminate-all-ECS-EC2-instances")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                              </div>
                                            </Grid>

                                          </Grid>

                                        </div>

                                      </Stack>

                                    </Grid>

                                  </Grid>

                                </ExpandableSection>

                                <ExpandableSection variant="default" header="6. ECS: Terminate One ECS EC2 Instance In A Component">

                                  <Grid container xs={12} className="spacing_5">
                                    <Grid item xs={12} spacing={1}>
                                      <Stack spacing='s'>
                                        <div className="left">

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">Scenario</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Application</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Component</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Description</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10"></div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">TM_006_01</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Trade Matching</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Inbound Gateway</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Terminate One ECS EC2 Instance</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("tm-in-gateway-terminate-one-ECS-EC2-instance")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                              </div>
                                            </Grid>

                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">TM_006_02</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Trade Matching</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Ingress</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Terminate One ECS EC2 Instance</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("tm-ingress-terminate-one-ECS-EC2-instance")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                              </div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">TM_006_03</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Trade Matching</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Core Matching</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Terminate One ECS EC2 Instance</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("tm-core-matching-terminate-one-ECS-EC2-instance")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                              </div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">TM_006_04</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Trade Matching</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Egress</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Terminate One ECS EC2 Instance</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("tm-egress-terminate-one-ECS-EC2-instance")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                              </div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">TM_006_05</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Trade Matching</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Out Gateway</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Terminate One ECS EC2 Instance</div>
                                            </Grid>


                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("tm-out-gateway-terminate-one-ECS-EC2-instance")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                              </div>
                                            </Grid>

                                          </Grid>

                                        </div>

                                      </Stack>

                                    </Grid>

                                  </Grid>

                                </ExpandableSection>

                                <ExpandableSection variant="default" header="7. ECS: Stress All ECS EC2 Instances In A Component">

                                  <Grid container xs={12} className="spacing_5">
                                    <Grid item xs={12} spacing={1}>
                                      <Stack spacing='s'>
                                        <div className="left">

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">Scenario</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Application</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Component</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Description</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10"></div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">TM_007_01</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Trade Matching</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Inbound Gateway</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stress All ECS EC2 Instances</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("tm-in-gateway-stress-all-ECS-EC2-instances")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                              </div>
                                            </Grid>

                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">TM_007_02</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Trade Matching</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Ingress</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stress All ECS EC2 Instances</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("tm-ingress-stress-all-ECS-EC2-instances")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                              </div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">TM_007_03</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Trade Matching</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Core Matching</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stress All ECS EC2 Instances</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("tm-core-matching-stress-all-ECS-EC2-instances")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                              </div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">TM_007_04</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Trade Matching</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Egress</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stress All ECS EC2 Instances</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("tm-egress-stress-all-ECS-EC2-instances")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                              </div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">TM_007_05</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Trade Matching</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Out Gateway</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stress All ECS EC2 Instances</div>
                                            </Grid>


                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("tm-out-gateway-stress-all-ECS-EC2-instances")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                              </div>
                                            </Grid>

                                          </Grid>

                                        </div>

                                      </Stack>

                                    </Grid>

                                  </Grid>

                                </ExpandableSection>

                                <ExpandableSection variant="default" header="8. ECS: Stress One ECS EC2 Instance In A Component">

                                  <Grid container xs={12} className="spacing_5">
                                    <Grid item xs={12} spacing={1}>
                                      <Stack spacing='s'>
                                        <div className="left">

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">Scenario</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Application</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Component</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Description</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10"></div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">TM_008_01</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Trade Matching</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Inbound Gateway</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stress One ECS EC2 Instance</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("tm-in-gateway-stress-one-ECS-EC2-instance")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                              </div>
                                            </Grid>

                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">TM_008_02</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Trade Matching</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Ingress</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stress One ECS EC2 Instance</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("tm-ingress-stress-one-ECS-EC2-instance")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                              </div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">TM_008_03</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Trade Matching</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Core Matching</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stress One ECS EC2 Instance</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("tm-core-matching-stress-one-ECS-EC2-instance")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                              </div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">TM_008_04</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Trade Matching</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Egress</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stress One ECS EC2 Instance</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("tm-egress-stress-one-ECS-EC2-instance")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                              </div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">TM_008_05</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Trade Matching</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Out Gateway</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stress One ECS EC2 Instance</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("tm-out-gateway-stress-one-ECS-EC2-instance")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                              </div>
                                            </Grid>

                                          </Grid>

                                        </div>

                                      </Stack>

                                    </Grid>

                                  </Grid>

                                </ExpandableSection>

                                <ExpandableSection variant="default" header="9. Kinesis: Stop VPC Access to Kinesis">

                                  <Grid container xs={12} className="spacing_5">
                                    <Grid item xs={12} spacing={1}>
                                      <Stack spacing='s'>
                                        <div className="left">

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">Scenario</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Application</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Component</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Description</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10"></div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">TM_009_01</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Trade Matching</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">All</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stop Kinesis Access</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("tm-stop-kinesis-access")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => recoverVPCAccess("trade-matching", "kinesis-streams")}>Recover</Button>
                                              </div>
                                            </Grid>

                                          </Grid>

                                        </div>

                                      </Stack>

                                    </Grid>

                                  </Grid>

                                </ExpandableSection>

                                <ExpandableSection variant="default" header="10. DynamoDB: Stop VPC Access to DynamoDB">

                                  <Grid container xs={12} className="spacing_5">
                                    <Grid item xs={12} spacing={1}>
                                      <Stack spacing='s'>
                                        <div className="left">

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">Scenario</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Application</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Component</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Description</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10"></div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">TM_010_01</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Trade Matching</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">All</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stop DynamoDB Access</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("tm-stop-dynamodb-access")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => recoverVPCAccess("trade-matching", "dynamodb")}>Recover</Button>
                                              </div>
                                            </Grid>

                                          </Grid>

                                        </div>

                                      </Stack>

                                    </Grid>

                                  </Grid>

                                </ExpandableSection>

                                <ExpandableSection variant="default" header="11. Aurora: Stop VPC Access to Aurora">

                                  <Grid container xs={12} className="spacing_5">
                                    <Grid item xs={12} spacing={1}>
                                      <Stack spacing='s'>
                                        <div className="left">

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">Scenario</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Application</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Component</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Description</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10"></div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">TM_011_01</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Trade Matching</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">All</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stop Aurora Access</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("tm-stop-aurora-access")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => recoverVPCAccess("trade-matching", "rds")}>Recover</Button>
                                              </div>
                                            </Grid>

                                          </Grid>

                                        </div>

                                      </Stack>

                                    </Grid>

                                  </Grid>

                                </ExpandableSection>
                              </Stack>
                            </Grid>
                          </Grid>

                        </ExpandableSection>

                        <ExpandableSection variant="default" header="Settlement">

                          <Grid container xs={12} className="spacing_5">
                            <Grid item xs={12} spacing={1}>
                              <Stack spacing='s'>

                                <ExpandableSection variant="default" header="1. ECS: Stop All ECS Tasks In A Component">

                                  <Grid container xs={12} className="spacing_5">

                                    <Grid item xs={12} spacing={1}>
                                      <Stack spacing='s'>

                                        <div className="left">

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">Scenario</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Application</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Component</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Description</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10"></div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">SM_001_01</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Settlement</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Inbound Gateway</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stop All ECS Tasks</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("sm-in-gateway-stop-all-ECS-tasks")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => recoverAppComponent("settlement", "in-gateway")}>Recover</Button>
                                              </div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">SM_001_02</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Settlement</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Ingress</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stop All ECS Tasks</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("sm-ingress-stop-all-ECS-tasks")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => recoverAppComponent("settlement", "ingress")}>Recover</Button>
                                              </div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">SM_001_03</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Settlement</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Core Matching</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stop All ECS Tasks</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("sm-core-matching-stop-all-ECS-tasks")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => recoverAppComponent("settlement", "core-matching")}>Recover</Button>
                                              </div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">SM_001_04</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Settlement</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Egress</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stop All ECS Tasks</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("sm-egress-stop-all-ECS-tasks")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => recoverAppComponent("settlement", "egress")}>Recover</Button>
                                              </div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">SM_001_05</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Settlement</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Out Gateway</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stop All ECS Tasks</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("sm-out-gateway-stop-all-ECS-tasks")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => recoverAppComponent("settlement", "out-gateway")}>Recover</Button>
                                              </div>
                                            </Grid>
                                          </Grid>

                                        </div>

                                      </Stack>
                                    </Grid>

                                  </Grid>

                                </ExpandableSection>

                                <ExpandableSection variant="default" header="2. ECS: Stop One ECS Task In A Component">

                                  <Grid container xs={12} className="spacing_5">

                                    <Grid item xs={12} spacing={1}>
                                      <Stack spacing='s'>

                                        <div className="left">

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">Scenario</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Application</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Component</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Description</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10"></div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">SM_002_01</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Settlement</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Inbound Gateway</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stop One ECS Task</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("sm-in-gateway-stop-one-ECS-task")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => recoverAppComponent("settlement", "in-gateway")}>Recover</Button>
                                              </div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">SM_002_02</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Settlement</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Ingress</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stop One ECS Task</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("sm-ingress-stop-one-ECS-task")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => recoverAppComponent("settlement", "ingress")}>Recover</Button>
                                              </div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">SM_002_03</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Settlement</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Core Matching</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stop One ECS Task</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("sm-core-matching-stop-one-ECS-task")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => recoverAppComponent("settlement", "core-matching")}>Recover</Button>
                                              </div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">SM_002_04</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Settlement</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Egress</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stop One ECS Task</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("sm-egress-stop-one-ECS-task")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => recoverAppComponent("settlement", "egress")}>Recover</Button>
                                              </div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">SM_002_05</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Settlement</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Out Gateway</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stop One ECS Task</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("sm-out-gateway-stop-one-ECS-task")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => recoverAppComponent("settlement", "out-gateway")}>Recover</Button>
                                              </div>
                                            </Grid>
                                          </Grid>

                                        </div>

                                      </Stack>
                                    </Grid>

                                  </Grid>

                                </ExpandableSection>

                                <ExpandableSection variant="default" header="3. ECS: Stop All ECS EC2 Instances In A Component">

                                  <Grid container xs={12} className="spacing_5">

                                    <Grid item xs={12} spacing={1}>
                                      <Stack spacing='s'>

                                        <div className="left">

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">Scenario</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Application</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Component</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Description</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10"></div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">SM_003_01</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Settlement</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Inbound Gateway</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stop All ECS EC2 Instances</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("sm-in-gateway-stop-all-ECS-EC2-instances")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                              </div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">SM_003_02</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Settlement</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Ingress</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stop All ECS EC2 Instances</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("sm-ingress-stop-all-ECS-EC2-instances")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                              </div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">SM_003_03</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Settlement</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Core Matching</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stop All ECS EC2 Instances</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("sm-core-matching-stop-all-ECS-EC2-instances")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                              </div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">SM_003_04</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Settlement</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Egress</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stop All ECS EC2 Instances</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("sm-egress-stop-all-ECS-EC2-instances")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                              </div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">SM_003_05</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Settlement</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Out Gateway</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stop All ECS EC2 Instances</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("sm-out-gateway-stop-all-ECS-EC2-instances")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                              </div>
                                            </Grid>
                                          </Grid>

                                        </div>

                                      </Stack>
                                    </Grid>

                                  </Grid>

                                </ExpandableSection>

                                <ExpandableSection variant="default" header="4. ECS: Stop One ECS EC2 Instance In A Component">

                                  <Grid container xs={12} className="spacing_5">

                                    <Grid item xs={12} spacing={1}>
                                      <Stack spacing='s'>

                                        <div className="left">

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">Scenario</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Application</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Component</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Description</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10"></div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">SM_004_01</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Settlement</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Inbound Gateway</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stop One ECS EC2 Instance</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("sm-in-gateway-stop-one-ECS-EC2-instance")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                              </div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">SM_004_02</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Settlement</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Ingress</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stop One ECS EC2 Instance</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("sm-ingress-stop-one-ECS-EC2-instance")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                              </div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">SM_004_03</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Settlement</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Core Matching</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stop One ECS EC2 Instance</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("sm-core-matching-stop-one-ECS-EC2-instance")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                              </div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">SM_004_04</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Settlement</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Egress</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stop One ECS EC2 Instance</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("sm-egress-stop-one-ECS-EC2-instance")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                              </div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">SM_004_05</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Settlement</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Out Gateway</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stop One ECS EC2 Instance</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("sm-out-gateway-stop-one-ECS-EC2-instance")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                              </div>
                                            </Grid>
                                          </Grid>

                                        </div>

                                      </Stack>
                                    </Grid>

                                  </Grid>

                                </ExpandableSection>

                                <ExpandableSection variant="default" header="5. ECS: Terminate All ECS EC2 Instances In A Component">

                                  <Grid container xs={12} className="spacing_5">

                                    <Grid item xs={12} spacing={1}>
                                      <Stack spacing='s'>

                                        <div className="left">

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">Scenario</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Application</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Component</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Description</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10"></div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">SM_005_01</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Settlement</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Inbound Gateway</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Terminate All ECS EC2 Instances</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("sm-in-gateway-terminate-all-ECS-EC2-instances")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                              </div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">SM_005_02</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Settlement</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Ingress</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Terminate All ECS EC2 Instances</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("sm-ingress-terminate-all-ECS-EC2-instances")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                              </div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">SM_005_03</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Settlement</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Core Matching</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Terminate All ECS EC2 Instances</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("sm-core-matching-terminate-all-ECS-EC2-instances")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                              </div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">SM_005_04</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Settlement</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Egress</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Terminate All ECS EC2 Instances</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("sm-egress-terminate-all-ECS-EC2-instances")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                              </div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">SM_005_05</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Settlement</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Out Gateway</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Terminate All ECS EC2 Instances</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("sm-out-gateway-terminate-all-ECS-EC2-instances")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                              </div>
                                            </Grid>
                                          </Grid>

                                        </div>

                                      </Stack>
                                    </Grid>

                                  </Grid>

                                </ExpandableSection>

                                <ExpandableSection variant="default" header="6. ECS: Terminate One ECS EC2 Instance In A Component">

                                  <Grid container xs={12} className="spacing_5">

                                    <Grid item xs={12} spacing={1}>
                                      <Stack spacing='s'>

                                        <div className="left">

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">Scenario</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Application</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Component</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Description</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10"></div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">SM_006_01</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Settlement</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Inbound Gateway</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Terminate One ECS EC2 Instance</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("sm-in-gateway-terminate-one-ECS-EC2-instance")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                              </div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">SM_006_02</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Settlement</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Ingress</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Terminate One ECS EC2 Instance</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("sm-ingress-terminate-one-ECS-EC2-instance")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                              </div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">SM_006_03</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Settlement</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Core Matching</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Terminate One ECS EC2 Instance</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("sm-core-matching-terminate-one-ECS-EC2-instance")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                              </div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">SM_006_04</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Settlement</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Egress</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Terminate One ECS EC2 Instance</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("sm-egress-terminate-one-ECS-EC2-instance")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                              </div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">SM_006_05</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Settlement</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Out Gateway</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Terminate One ECS EC2 Instance</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("sm-out-gateway-terminate-one-ECS-EC2-instance")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                              </div>
                                            </Grid>
                                          </Grid>

                                        </div>

                                      </Stack>
                                    </Grid>

                                  </Grid>

                                </ExpandableSection>
                                
                                <ExpandableSection variant="default" header="7. ECS: Stress All ECS EC2 Instances In A Component">

                                  <Grid container xs={12} className="spacing_5">

                                    <Grid item xs={12} spacing={1}>
                                      <Stack spacing='s'>

                                        <div className="left">

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">Scenario</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Application</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Component</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Description</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10"></div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">SM_007_01</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Settlement</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Inbound Gateway</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stress All ECS EC2 Instances</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("sm-in-gateway-stress-all-ECS-EC2-instances")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                              </div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">SM_007_02</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Settlement</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Ingress</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stress All ECS EC2 Instances</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("sm-ingress-stress-all-ECS-EC2-instances")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                              </div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">SM_007_03</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Settlement</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Core Matching</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stress All ECS EC2 Instances</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("sm-core-matching-stress-all-ECS-EC2-instances")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                              </div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">SM_007_04</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Settlement</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Egress</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stress All ECS EC2 Instances</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("sm-egress-stress-all-ECS-EC2-instances")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                              </div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">SM_007_05</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Settlement</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Out Gateway</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stress All ECS EC2 Instances</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("sm-out-gateway-stress-all-ECS-EC2-instances")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                              </div>
                                            </Grid>
                                          </Grid>

                                        </div>

                                      </Stack>
                                    </Grid>

                                  </Grid>

                                </ExpandableSection>

                                <ExpandableSection variant="default" header="8. ECS: Stress One ECS EC2 Instance In A Component">

                                  <Grid container xs={12} className="spacing_5">

                                    <Grid item xs={12} spacing={1}>
                                      <Stack spacing='s'>

                                        <div className="left">

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">Scenario</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Application</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Component</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Description</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10"></div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">SM_008_01</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Settlement</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Inbound Gateway</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stress One ECS EC2 Instance</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("sm-in-gateway-stress-one-ECS-EC2-instance")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                              </div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">SM_008_02</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Settlement</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Ingress</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stress One ECS EC2 Instance</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("sm-ingress-stress-one-ECS-EC2-instance")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                              </div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">SM_008_03</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Settlement</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Core Matching</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stress One ECS EC2 Instance</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("sm-core-matching-stress-one-ECS-EC2-instance")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                              </div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">SM_008_04</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Settlement</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Egress</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stress One ECS EC2 Instance</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("sm-egress-stress-one-ECS-EC2-instance")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                              </div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">SM_008_05</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Settlement</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Out Gateway</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stress One ECS EC2 Instance</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("sm-out-gateway-stress-one-ECS-EC2-instance")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                              </div>
                                            </Grid>
                                          </Grid>

                                        </div>

                                      </Stack>
                                    </Grid>

                                  </Grid>

                                </ExpandableSection>

                                <ExpandableSection variant="default" header="9. Kinesis: Stop VPC Access to Kinesis">

                                  <Grid container xs={12} className="spacing_5">

                                    <Grid item xs={12} spacing={1}>
                                      <Stack spacing='s'>

                                        <div className="left">

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">Scenario</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Application</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Component</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Description</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10"></div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">SM_009_01</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Settlement</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">All</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stop Kinesis Access</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("sm-stop-kinesis-access")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => recoverVPCAccess("settlement", "kinesis-streams")}>Recover</Button>
                                              </div>
                                            </Grid>
                                          </Grid>

                                        </div>

                                      </Stack>
                                    </Grid>

                                  </Grid>

                                </ExpandableSection>

                                <ExpandableSection variant="default" header="10. DynamoDB: Stop VPC Access to DynamoDB">

                                  <Grid container xs={12} className="spacing_5">

                                    <Grid item xs={12} spacing={1}>
                                      <Stack spacing='s'>

                                        <div className="left">

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">Scenario</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Application</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Component</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Description</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10"></div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">SM_010_01</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Settlement</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">All</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stop DynamoDB Access</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("sm-stop-dynamodb-access")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => recoverVPCAccess("settlement", "dynamodb")}>Recover</Button>
                                              </div>
                                            </Grid>
                                          </Grid>

                                        </div>

                                      </Stack>
                                    </Grid>

                                  </Grid>

                                </ExpandableSection>

                                <ExpandableSection variant="default" header="11. Aurora:  Stop VPC Access to Aurora">

                                  <Grid container xs={12} className="spacing_5">

                                    <Grid item xs={12} spacing={1}>
                                      <Stack spacing='s'>

                                        <div className="left">

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">Scenario</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Application</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Component</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Description</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10"></div>
                                            </Grid>
                                          </Grid>

                                          <Grid container xs={12}>
                                            <Grid xs={2} className="border_black">
                                              <div className="spacing_2 spacing_10">SM_011_01</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">Settlement</div>
                                            </Grid>
                                            <Grid xs={2} spacing={5} className="border_black">
                                              <div className="spacing_2 spacing_10">All</div>
                                            </Grid>
                                            <Grid xs={3} spacing={5} className="border_black">
                                              <div className="left spacing_10">Stop Aurora Access</div>
                                            </Grid>

                                            <Grid item xs={3} spacing={5} className="border_black">
                                              <div className="center spacing_5">
                                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => executeExperiment("tm-stop-aurora-access")}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={() => recoverVPCAccess("settlement", "rds")}>Recover</Button>
                                              </div>
                                            </Grid>
                                          </Grid>

                                        </div>

                                      </Stack>
                                    </Grid>

                                  </Grid>

                                </ExpandableSection>

                              </Stack>
                            </Grid>
                          </Grid>
                        </ExpandableSection>

                      </Grid>
                    </Grid>

                  </Grid>
                </Container>

              </div>

            </div>
          </div>
        </div>
        <div><Flashbar items={errors} /></div>
        {renderMessage()}
      </Grid>
  );
}

export default ChaosTesting;

