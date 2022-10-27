// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import React, {FunctionComponent, useEffect, useState} from 'react';
import {Container, Button, StatusIndicator} from "aws-northstar";
import Stack from "aws-northstar/layouts/Stack";
import '../home/styles.css';
import {IAppHealth, IAppReady, IAppReplication} from "../../interfaces";

import Grid from "aws-northstar/esm/layouts/Grid";
import {
    executeRunbook,
    getAppHealth,
    getAppReady,
    getAppReplication,
} from "../../data";
import Flashbar, {FlashbarMessage} from "aws-northstar/components/Flashbar";
import Alert from "aws-northstar/components/Alert";

const IntegrationTesting: FunctionComponent = () => {

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

    const executeSC001 = async () => {
        setMessage("Initiated Execution of Scenario 001")
        let request = await executeRunbook("us-east-1", "Scenario-001", "settlement", "App Rotation", "test").then(
            (result: any) => {
                console.log("Received Result :" + JSON.stringify(result))
            });
    }

    const executeSC003 = async () => {
        setMessage("Initiated Execution of Scenario 003")
        let request = await executeRunbook("us-east-1", "Scenario-001", "trade-matching", "App Rotation", "test").then(
            (result: any) => {
                console.log("Received Result :" + JSON.stringify(result))
            });
    }

    return (
        <Stack>
            <div>
                <div className="awsui-grid awsui-util-p-s">
                    <div className="awsui-util-pt-xxl awsui-row">
                        <div className="custom-home-main-content-area col-xxs-10 offset-xxs-1 col-s-6 col-l-5 offset-l-2 col-xl-6">

                            <Container headingVariant='h4'>
                                <Grid container spacing={3} className="spacing_10">

                                    <Grid item xs={12} spacing={5} className="border_black">
                                      <div className="center">
                                        <b>Rotation Testing</b>
                                      </div>
                                    </Grid>

                                    <Grid item xs={12} className="border_black">
                                        <Stack>
                                            <div className="center" >
                                                <Grid container xs={12} className="spacing_5">

                                                    <Grid item xs={12} spacing={1}>
                                                        <Stack spacing='s'>

                                                            <div className="left">

                                                                <Grid container xs={12}>
                                                                    <Grid xs={1} className="border_black">
                                                                        <div className="spacing_2 spacing_5"><b>Scenario ID</b></div>
                                                                    </Grid>
                                                                    <Grid xs={1} className="border_black">
                                                                        <div className="spacing_2 spacing_5"><b>Application</b></div>
                                                                    </Grid>
                                                                    <Grid xs={1} className="border_black">
                                                                        <div className="spacing_2 spacing_5"><b>Action</b></div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5} className="border_black">
                                                                        <div className="left spacing_5"><b>Scenario</b></div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5} className="border_black">
                                                                        <div className="left spacing_5"><b>Data Conditions</b></div>
                                                                    </Grid>
                                                                    <Grid xs={4} spacing={5} className="border_black">
                                                                        <div className="left spacing_5"><b>Hypothesis / Expected Behavior</b></div>
                                                                    </Grid>

                                                                    <Grid item xs={2} spacing={5} className="border_black">
                                                                        <div className="left spacing_5"><b>Execute</b></div>
                                                                    </Grid>
                                                                </Grid>
                                                                <Grid container xs={12}>
                                                                    <Grid xs={1} className="border_black">
                                                                        <div className="spacing_2 spacing_5">SC_001</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5} className="border_black">
                                                                        <div className="spacing_2 spacing_5">Settlement</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5} className="border_black">
                                                                        <div className="spacing_2 spacing_5">Planned Operational Rotation</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5} className="border_black">
                                                                        <div className="left spacing_5">Rotate Settlement Application from East to West</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5} className="border_black">
                                                                        <div className="left spacing_5">No new messages are sent to Trade Matching application during rotation </div>
                                                                    </Grid>
                                                                    <Grid xs={4} spacing={5} className="border_black">
                                                                        <div className="left">
                                                                            <ul>
                                                                                <li>
                                                                                    No messages are lost, RPO should be 0 for planned rotations
                                                                                </li>
                                                                                <li>
                                                                                    All data in MQ, DynamoDB Global Table and Aurora is available in West region.
                                                                                </li>
                                                                                <li>
                                                                                    All new messages submitted after the rotation is completed is successfully processed.
                                                                                </li>
                                                                            </ul>
                                                                        </div>
                                                                    </Grid>

                                                                    <Grid item xs={2} spacing={5} className="border_black">
                                                                        <div className="center spacing_10">
                                                                            &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={executeSC001}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                                                        </div>
                                                                    </Grid>
                                                                </Grid>
                                                                <Grid container xs={12}>
                                                                    <Grid xs={1} className="border_black">
                                                                        <div className="spacing_2 spacing_5">SC_002</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5} className="border_black">
                                                                        <div className="spacing_2 spacing_5">Settlement</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5} className="border_black">
                                                                        <div className="spacing_2 spacing_5">Planned Operational Rotation</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5} className="border_black">
                                                                        <div className="left spacing_5">Rotate Settlement Application from East to West</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5} className="border_black">
                                                                        <div className="left spacing_5">Data is submitted to Trade Matching Application, Settlement is quiesced and no data is processed until rotation is completed.</div>
                                                                    </Grid>
                                                                    <Grid xs={4} spacing={5} className="border_black">
                                                                        <div className="left">
                                                                            <ul>
                                                                                <li>
                                                                                    No messages are lost, RPO should be 0 for planned rotations
                                                                                </li>
                                                                                <li>
                                                                                    All data in MQ, DynamoDB Global Table and Aurora is available in West region.
                                                                                </li>
                                                                                <li>
                                                                                    Messages that were processed by Trade Matching while rotation is going on are processed by Settlement after rotation is completed.
                                                                                </li>
                                                                                <li>
                                                                                    All new messages submitted after the rotation is completed are successfully processed.
                                                                                </li>
                                                                            </ul>
                                                                        </div>
                                                                    </Grid>

                                                                    <Grid item xs={2} spacing={5} className="border_black">
                                                                        <div className="center spacing_10">
                                                                            &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" disabled={true} onClick={execute}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                                                        </div>
                                                                    </Grid>
                                                                </Grid>
                                                                <Grid container xs={12}>
                                                                    <Grid xs={1} className="border_black">
                                                                        <div className="spacing_2 spacing_5">SC_003</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5} className="border_black">
                                                                        <div className="spacing_2 spacing_5">Trade Matching</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5} className="border_black">
                                                                        <div className="spacing_2 spacing_5">Planned Operational Rotation</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5} className="border_black">
                                                                        <div className="left spacing_5">Rotate Trade Matching Application from East to West</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5} className="border_black">
                                                                        <div className="left spacing_5">No new messages are sent to Trade Matching application during rotation</div>
                                                                    </Grid>
                                                                    <Grid xs={4} spacing={5} className="border_black">
                                                                        <div className="left">
                                                                            <ul>
                                                                                <li>
                                                                                    No messages are lost, RPO should be 0 for planned rotations
                                                                                </li>
                                                                                <li>
                                                                                    All data in MQ, DynamoDB Global Table and Aurora is available in West region.
                                                                                </li>
                                                                                <li>
                                                                                    All new messages submitted after the rotation is completed are successfully processed.
                                                                                </li>
                                                                            </ul>
                                                                        </div>
                                                                    </Grid>

                                                                    <Grid item xs={2} spacing={5} className="border_black">
                                                                        <div className="center spacing_10">
                                                                            &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={executeSC003}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                                                        </div>
                                                                    </Grid>
                                                                </Grid>
                                                                <Grid container xs={12}>
                                                                    <Grid xs={1} className="border_black">
                                                                        <div className="spacing_2 spacing_5">SC_004</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5} className="border_black">
                                                                        <div className="spacing_2 spacing_5">Settlement/Trade Matching</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5} className="border_black">
                                                                        <div className="spacing_2 spacing_5">Planned Operational Rotation</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5} className="border_black">
                                                                        <div className="left spacing_5">Rotate Trade Matching and Settlement Application from East to West </div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5} className="border_black">
                                                                        <div className="left spacing_5">No new messages are sent to Trade Matching application during rotation</div>
                                                                    </Grid>
                                                                    <Grid xs={4} spacing={5} className="border_black">
                                                                        <div className="left">
                                                                            <ul>
                                                                                <li>
                                                                                    No messages are lost, RPO should be 0 for planned rotations
                                                                                </li>
                                                                                <li>
                                                                                    All data in MQ, DynamoDB Global Table and Aurora is available in West region.
                                                                                </li>
                                                                                <li>
                                                                                    All new messages submitted after the rotation is completed are successfully processed.
                                                                                </li>
                                                                            </ul>
                                                                        </div>
                                                                    </Grid>

                                                                    <Grid item xs={2} spacing={5} className="border_black">
                                                                        <div className="center spacing_10">
                                                                            &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" disabled={true} onClick={execute}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                                                        </div>
                                                                    </Grid>
                                                                </Grid>
                                                                <Grid container xs={12}>
                                                                    <Grid xs={1} className="border_black">
                                                                        <div className="spacing_2 spacing_5">SC_005</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5} className="border_black">
                                                                        <div className="spacing_2 spacing_5">Settlement/Trade Matching</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5} className="border_black">
                                                                        <div className="spacing_2 spacing_5">Unplanned Disaster Recovery</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5} className="border_black">
                                                                        <div className="left spacing_5">Perform Unplanned recovery of both Trade Matching and Settlement from East to West</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5} className="border_black">
                                                                        <div className="left spacing_5">Messages are sent to Trade Matching and being processed by trade matching and Settlement applications - Matching data(in Aurora DB) is lagging behind Ingestion data(Dynamo DB) (replicated data in target region)</div>
                                                                    </Grid>
                                                                    <Grid xs={4} spacing={5} className="border_black">
                                                                        <div className="left">
                                                                            <ul>
                                                                                <li>
                                                                                    Messages that are not replicated to west region before recovery may be missing
                                                                                </li>
                                                                                <li>
                                                                                    Reconcile and replay data within trade matching and settlement
                                                                                </li>
                                                                                <li>
                                                                                    Reconcile and replay data between trade matching and settlement
                                                                                </li>
                                                                                <li>
                                                                                    RPO is less than 30s
                                                                                </li>
                                                                            </ul>
                                                                        </div>
                                                                    </Grid>

                                                                    <Grid item xs={2} spacing={5} className="border_black">
                                                                        <div className="center spacing_10">
                                                                            &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" disabled={true} onClick={execute}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                                                        </div>
                                                                    </Grid>
                                                                </Grid>
                                                                <Grid container xs={12}>
                                                                    <Grid xs={1} className="border_black">
                                                                        <div className="spacing_2 spacing_5">SC_006</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5} className="border_black">
                                                                        <div className="spacing_2 spacing_5">Settlement/Trade Matching</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5} className="border_black">
                                                                        <div className="spacing_2 spacing_5">Unplanned Disaster Recovery</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5} className="border_black">
                                                                        <div className="left spacing_5">Perform Unplanned recovery of both Trade Matching and Settlement from East to West</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5} className="border_black">
                                                                        <div className="left spacing_5">Messages are sent to Trade Matching and being processed by trade matching and Settlement application Matching data(in Aurora DB) is ahead of Ingestion data(Dynamo DB) (replicated data in target region)</div>
                                                                    </Grid>
                                                                    <Grid xs={4} spacing={5} className="border_black">
                                                                        <div className="left">
                                                                            <ul>
                                                                                <li>
                                                                                    Messages that are not replicated to west region before recovery may be missing
                                                                                </li>
                                                                                <li>
                                                                                    Reconcile and replay data within trade matching and settlement
                                                                                </li>
                                                                                <li>
                                                                                    Reconcile and replay data between trade matching and settlement
                                                                                </li>
                                                                                <li>
                                                                                    Applications need a strategy to address scenarios where data in downstream services/application is ahead of upstream producer
                                                                                </li>
                                                                                <li>
                                                                                    There is no data loss after replay
                                                                                </li>
                                                                            </ul>
                                                                        </div>
                                                                    </Grid>

                                                                    <Grid item xs={2} spacing={5} className="border_black">
                                                                        <div className="center spacing_10">
                                                                            &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" disabled={true} onClick={execute}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                                                        </div>
                                                                    </Grid>
                                                                </Grid>
                                                                <Grid container xs={12}>
                                                                    <Grid xs={1} className="border_black">
                                                                        <div className="spacing_2 spacing_5">SC_007</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5} className="border_black">
                                                                        <div className="spacing_2 spacing_5">Settlement/Trade Matching</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5} className="border_black">
                                                                        <div className="spacing_2 spacing_5">Unplanned Disaster Recovery</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5} className="border_black">
                                                                        <div className="left spacing_5">Perform Unplanned recovery of both Trade Matching and Settlement from East to West</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5} className="border_black">
                                                                        <div className="left spacing_5">Messages are sent to Trade Matching and being processed by trade matching and Settlement application. Settlement Inbound Gateway data is lagging behind Trade Matching Outbound Gateway data</div>
                                                                    </Grid>
                                                                    <Grid xs={4} spacing={5} className="border_black">
                                                                        <div className="left">
                                                                            <ul>
                                                                                <li>
                                                                                    Messages that are not replicated to west region before recovery may be missing
                                                                                </li>
                                                                                <li>
                                                                                    Reconcile and replay data within trade matching and settlement
                                                                                </li>
                                                                                <li>
                                                                                    Reconcile and replay data between trade matching and settlement
                                                                                </li>
                                                                            </ul>
                                                                        </div>
                                                                    </Grid>

                                                                    <Grid item xs={2} spacing={5} className="border_black">
                                                                        <div className="center spacing_10">
                                                                            &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" disabled={true} onClick={execute}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                                                        </div>
                                                                    </Grid>
                                                                </Grid>

                                                                <Grid container xs={12}>
                                                                    <Grid xs={1} className="border_black">
                                                                        <div className="spacing_2 spacing_5">SC_008</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5} className="border_black">
                                                                        <div className="spacing_2 spacing_5">Settlement/Trade Matching</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5} className="border_black">
                                                                        <div className="spacing_2 spacing_5">Unplanned Disaster Recovery</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5} className="border_black">
                                                                        <div className="left spacing_5">Perform Unplanned recovery of both Trade Matching and Settlement from East to West</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5} className="border_black">
                                                                        <div className="left spacing_5">Messages are sent to Trade Matching and being processed by trade matching and Settlement application. Settlement Inbound Gateway data is ahead of Trade Matching Outbound Gateway data</div>
                                                                    </Grid>
                                                                    <Grid xs={4} spacing={5} className="border_black">
                                                                        <div className="left">
                                                                            <ul>
                                                                                <li>
                                                                                    Messages that are not replicated to west region before recovery may be missing
                                                                                </li>
                                                                                <li>
                                                                                    Reconcile and replay data within trade matching and settlement
                                                                                </li>
                                                                                <li>
                                                                                    Reconcile and replay data between trade matching and settlement
                                                                                </li>
                                                                                <li>
                                                                                    Applications need a strategy to address scenarios where data in downstream services/application is ahead of upstream producer
                                                                                </li>
                                                                            </ul>
                                                                        </div>
                                                                    </Grid>

                                                                    <Grid item xs={2} spacing={5} className="border_black">
                                                                        <div className="center spacing_10">
                                                                            &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" disabled={true} onClick={execute}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                                                        </div>
                                                                    </Grid>
                                                                </Grid>

                                                                <Grid container xs={12}>
                                                                    <Grid xs={1} className="border_black">
                                                                        <div className="spacing_2 spacing_5">SC_009</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5} className="border_black">
                                                                        <div className="spacing_2 spacing_5">Trade Matching</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5} className="border_black">
                                                                        <div className="spacing_2 spacing_5">Perform Unplanned recovery of Trade Matching from East to West</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5} className="border_black">
                                                                        <div className="left spacing_5">Perform Unplanned recovery of Trade Matching from East to West</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5} className="border_black">
                                                                        <div className="left spacing_5">Messages are sent to Trade Matching and being processed by trade matching and settlement applications. Matching data(in Aurora DB) is lagging behind Ingestion data(Dynamo DB) (replicated data in target region)</div>
                                                                    </Grid>
                                                                    <Grid xs={4} spacing={5} className="border_black">
                                                                        <div className="left">
                                                                            <ul>
                                                                                <li>
                                                                                    Messages that are not replicated to west region before recovery may be missing
                                                                                </li>
                                                                                <li>
                                                                                    Reconcile and replay data within trade matching and settlement
                                                                                </li>
                                                                                <li>
                                                                                    Reconcile and replay data between trade matching and settlement
                                                                                </li>
                                                                            </ul>
                                                                        </div>
                                                                    </Grid>

                                                                    <Grid item xs={2} spacing={5} className="border_black">
                                                                        <div className="center spacing_10">
                                                                            &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" disabled={true} onClick={execute}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                                                        </div>
                                                                    </Grid>
                                                                </Grid>

                                                                <Grid container xs={12}>
                                                                    <Grid xs={1} className="border_black">
                                                                        <div className="spacing_2 spacing_5">SC_010</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5} className="border_black">
                                                                        <div className="spacing_2 spacing_5">Trade Matching</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5} className="border_black">
                                                                        <div className="spacing_2 spacing_5">Unplanned Disaster Recovery</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5} className="border_black">
                                                                        <div className="left spacing_5">Perform Unplanned recovery of Trade Matching from East to West</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5} className="border_black">
                                                                        <div className="left spacing_5">Messages are sent to Trade Matching and being processed by trade matching and settlement applications. Matching data(in Aurora DB) is ahead of  Ingestion data(Dynamo DB) (replicated data in target region)</div>
                                                                    </Grid>
                                                                    <Grid xs={4} spacing={5} className="border_black">
                                                                        <div className="left">
                                                                            <ul>
                                                                                <li>
                                                                                    Messages that are not replicated to west region before recovery may be missing
                                                                                </li>
                                                                                <li>
                                                                                    Reconcile and replay data within trade matching and settlement
                                                                                </li>
                                                                                <li>
                                                                                    Reconcile and replay data between trade matching and settlement
                                                                                </li>
                                                                                <li>
                                                                                    Applications need a strategy to address scenarios where data in downstream services/application is ahead of upstream producer
                                                                                </li>
                                                                            </ul>
                                                                        </div>
                                                                    </Grid>

                                                                    <Grid item xs={2} spacing={5} className="border_black">
                                                                        <div className="center spacing_10">
                                                                            &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" disabled={true} onClick={execute}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                                                        </div>
                                                                    </Grid>
                                                                </Grid>

                                                                <Grid container xs={12}>
                                                                    <Grid xs={1} className="border_black">
                                                                        <div className="spacing_2 spacing_5">SC_011</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5} className="border_black">
                                                                        <div className="spacing_2 spacing_5">Trade Matching</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5} className="border_black">
                                                                        <div className="spacing_2 spacing_5">Unplanned Disaster Recovery</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5} className="border_black">
                                                                        <div className="left spacing_5">Perform Unplanned recovery of Trade Matching from East to West</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5} className="border_black">
                                                                        <div className="left spacing_5">Messages are sent to Trade Matching and being processed by matching and Settlement - Settlement Inbound Gateway is lagging behind Trade Matching Outbound Gateway</div>
                                                                    </Grid>
                                                                    <Grid xs={4} spacing={5} className="border_black">
                                                                        <div className="left">
                                                                            <ul>
                                                                                <li>
                                                                                    Messages that are not replicated to west region before recovery may be missing
                                                                                </li>
                                                                                <li>
                                                                                    Reconcile and replay data within trade matching and settlement
                                                                                </li>
                                                                                <li>
                                                                                    Reconcile and replay data between trade matching and settlement
                                                                                </li>
                                                                            </ul>
                                                                        </div>
                                                                    </Grid>

                                                                    <Grid item xs={2} spacing={5} className="border_black">
                                                                        <div className="center spacing_10">
                                                                            &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" disabled={true} onClick={execute}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                                                        </div>
                                                                    </Grid>
                                                                </Grid>

                                                                <Grid container xs={12}>
                                                                    <Grid xs={1} className="border_black">
                                                                        <div className="spacing_2 spacing_5">SC_012</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5} className="border_black">
                                                                        <div className="spacing_2 spacing_5">Trade Matching</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5} className="border_black">
                                                                        <div className="spacing_2 spacing_5">Unplanned Disaster Recovery</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5} className="border_black">
                                                                        <div className="left spacing_5">Perform Unplanned recovery of Trade Matching from East to West</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5} className="border_black">
                                                                        <div className="left spacing_5">Messages are sent to Trade Matching and being processed by trade matching and Settlement applications - Data in Trade Matching Outbound Gateway  (not replicated to target region)is behind data in Settlement Inbound Gateway </div>
                                                                    </Grid>
                                                                    <Grid xs={4} spacing={5} className="border_black">
                                                                        <div className="left">
                                                                            <ul>
                                                                                <li>
                                                                                    Messages that are not replicated to west region before recovery may be missing
                                                                                </li>
                                                                                <li>
                                                                                    messages from Trade matching to settlement are queued up in MQ
                                                                                </li>
                                                                                <li>
                                                                                    Reconcile and replay data within trade matching and settlement
                                                                                </li>
                                                                                <li>
                                                                                    Reconcile and replay data between trade matching and settlement
                                                                                </li>
                                                                                <li>
                                                                                    Applications need a strategy to address scenarios where data in downstream services/application is ahead of upstream producer
                                                                                </li>
                                                                            </ul>
                                                                        </div>
                                                                    </Grid>

                                                                    <Grid item xs={2} spacing={5} className="border_black">
                                                                        <div className="center spacing_10">
                                                                            &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" disabled={true} onClick={execute}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                                                        </div>
                                                                    </Grid>
                                                                </Grid>

                                                                <Grid container xs={12}>
                                                                    <Grid xs={1} className="border_black">
                                                                        <div className="spacing_2 spacing_5">SC_013</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5} className="border_black">
                                                                        <div className="spacing_2 spacing_5">Settlement</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5} className="border_black">
                                                                        <div className="spacing_2 spacing_5">Unplanned Disaster Recovery</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5} className="border_black">
                                                                        <div className="left spacing_5">Perform Unplanned recovery of Settlement from East to West</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5} className="border_black">
                                                                        <div className="left spacing_5">Messages are sent to Trade Matching and continue to be processed while settlement engine is being recovered.</div>
                                                                    </Grid>
                                                                    <Grid xs={4} spacing={5} className="border_black">
                                                                        <div className="left">
                                                                            <ul>
                                                                                <li>
                                                                                    Messages that are not replicated to west region before recovery may be missing
                                                                                </li>
                                                                                <li>
                                                                                    Messages from Trade matching to settlement are queued up in MQ
                                                                                </li>
                                                                                <li>
                                                                                    Reconcile and replay data within trade matching and settlement
                                                                                </li>
                                                                                <li>
                                                                                    Reconcile and replay data between trade matching and settlement
                                                                                </li>
                                                                            </ul>
                                                                        </div>
                                                                    </Grid>

                                                                    <Grid item xs={2} spacing={5} className="border_black">
                                                                        <div className="center spacing_10">
                                                                            &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" disabled={true} onClick={execute}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                                                        </div>
                                                                    </Grid>
                                                                </Grid>

                                                                <Grid container xs={12}>
                                                                    <Grid xs={1} className="border_black">
                                                                        <div className="spacing_2 spacing_5">SC_014</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5} className="border_black">
                                                                        <div className="spacing_2 spacing_5">Settlement</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5} className="border_black">
                                                                        <div className="spacing_2 spacing_5">Unplanned Disaster Recovery</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5} className="border_black">
                                                                        <div className="left spacing_5">Perform Unplanned recovery of Settlement from East to West</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5} className="border_black">
                                                                        <div className="left spacing_5">Messages are sent to Trade Matching and being processed by matching and Settlement-in Settlement application Matching data is lagging behind Ingestion.</div>
                                                                    </Grid>
                                                                    <Grid xs={4} spacing={5} className="border_black">
                                                                        <div className="left">
                                                                            <ul>
                                                                                <li>
                                                                                    Messages that are not replicated to west region before recovery may be missing
                                                                                </li>
                                                                                <li>
                                                                                    Messages from Trade matching to settlement are queued up in MQ
                                                                                </li>
                                                                                <li>
                                                                                    Reconcile and replay data within trade matching and settlement
                                                                                </li>
                                                                                <li>
                                                                                    Reconcile and replay data between trade matching and settlementReconcile and replay data between trade matching and settlement
                                                                                </li>
                                                                            </ul>
                                                                        </div>
                                                                    </Grid>

                                                                    <Grid item xs={2} spacing={5} className="border_black">
                                                                        <div className="center spacing_10">
                                                                            &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" disabled={true} onClick={execute}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                                                        </div>
                                                                    </Grid>
                                                                </Grid>

                                                                <Grid container xs={12}>
                                                                    <Grid xs={1} className="border_black">
                                                                        <div className="spacing_2 spacing_5">SC_015</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5} className="border_black">
                                                                        <div className="spacing_2 spacing_5">Settlement</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5} className="border_black">
                                                                        <div className="spacing_2 spacing_5">Unplanned Disaster Recovery</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5} className="border_black">
                                                                        <div className="left spacing_5">Perform Unplanned recovery of Settlement from East to West</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5} className="border_black">
                                                                        <div className="left spacing_5">Messages are sent to Trade Matching and being processed by matching and Settlement - Matching data(in Aurora DB) is lagging behind Ingestion data(Dynamo DB) (replicated data in target region)</div>
                                                                    </Grid>
                                                                    <Grid xs={4} spacing={5} className="border_black">
                                                                        <div className="left">
                                                                            <ul>
                                                                                <li>
                                                                                    Messages that are not replicated to west region before recovery may be missing
                                                                                </li>
                                                                                <li>
                                                                                    Reconcile and replay data within trade matching and settlement
                                                                                </li>
                                                                                <li>
                                                                                    Reconcile and replay data between trade matching and settlement
                                                                                </li>
                                                                            </ul>
                                                                        </div>
                                                                    </Grid>

                                                                    <Grid item xs={2} spacing={5} className="border_black">
                                                                        <div className="center spacing_10">
                                                                            &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" disabled={true} onClick={execute}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                                                        </div>
                                                                    </Grid>
                                                                </Grid>

                                                                <Grid container xs={12}>
                                                                    <Grid xs={1} className="border_black">
                                                                        <div className="spacing_2 spacing_5">SC_016</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5} className="border_black">
                                                                        <div className="spacing_2 spacing_5">Settlement</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5} className="border_black">
                                                                        <div className="spacing_2 spacing_5">Unplanned Disaster Recovery</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5} className="border_black">
                                                                        <div className="left spacing_5">Perform Unplanned recovery of Settlement from East to West</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5} className="border_black">
                                                                        <div className="left spacing_5">Messages are sent to Trade Matching and being processed by matching and Settlement - Settlement Inbound Gateway is lagging (data not replicated to target) behind  Trade Matching  Outbound Gateway </div>
                                                                    </Grid>
                                                                    <Grid xs={4} spacing={5} className="border_black">
                                                                        <div className="left">
                                                                            <ul>
                                                                                <li>
                                                                                    Messages that are not replicated to west region before recovery may be missing
                                                                                </li>
                                                                                <li>
                                                                                    Reconcile and replay data within trade matching and settlement
                                                                                </li>
                                                                                <li>
                                                                                    Reconcile and replay data between trade matching and settlement
                                                                                </li>
                                                                            </ul>
                                                                        </div>
                                                                    </Grid>

                                                                    <Grid item xs={2} spacing={5} className="border_black">
                                                                        <div className="center spacing_10">
                                                                            &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" disabled={true} onClick={execute}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                                                        </div>
                                                                    </Grid>
                                                                </Grid>

                                                                <Grid container xs={12}>
                                                                    <Grid xs={1} className="border_black">
                                                                        <div className="spacing_2 spacing_5">SC_017</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5} className="border_black">
                                                                        <div className="spacing_2 spacing_5">Settlement/Trade Matching</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5} className="border_black">
                                                                        <div className="spacing_2 spacing_5">Unplanned Disaster Recovery</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5} className="border_black">
                                                                        <div className="left spacing_5">Perform Unplanned recovery of both Trade Matching and Settlement from East to West </div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5} className="border_black">
                                                                        <div className="left spacing_5">Messages are sent to Trade Matching and being processed by trade matching and Settlement applications - Data in trade matching inbound gateway DynamoDB table is not replicated to the target region </div>
                                                                    </Grid>
                                                                    <Grid xs={4} spacing={5} className="border_black">
                                                                        <div className="left">
                                                                            <ul>
                                                                                <li>
                                                                                    Messages that are not replicated to west region before recovery may be missing
                                                                                </li>
                                                                                <li>
                                                                                    What is the maximum expected replication lag for data in DynamoDB global table and messages in MQ ?
                                                                                </li>
                                                                                <li>
                                                                                    RPO should be less than 30s
                                                                                </li>
                                                                            </ul>
                                                                        </div>
                                                                    </Grid>

                                                                    <Grid item xs={2} spacing={5} className="border_black">
                                                                        <div className="center spacing_10">
                                                                            &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" disabled={true} onClick={execute}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                                                        </div>
                                                                    </Grid>
                                                                </Grid>

                                                            </div>

                                                        </Stack>
                                                    </Grid>

                                                    <Grid xs={12} className="spacing_5">
                                                    </Grid>

                                                </Grid>
                                            </div>

                                        </Stack>
                                    </Grid>

                                </Grid>
                            </Container>

                        </div>

                    </div>
                </div>
            </div>
            <div><Flashbar items={errors} /></div>
            {renderMessage()}
        </Stack>
    );
}

export default IntegrationTesting;

