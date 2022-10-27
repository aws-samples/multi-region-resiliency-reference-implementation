// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import React, {FunctionComponent} from 'react';
import {Container, Button, ExpandableSection} from "aws-northstar";
import Stack from "aws-northstar/layouts/Stack";
import '../home/styles.css';

import Grid from "aws-northstar/esm/layouts/Grid";
import {
    executeRunbook,
} from "../../data";
import Flashbar, {FlashbarMessage} from "aws-northstar/components/Flashbar";
import Alert from "aws-northstar/components/Alert";


const IntegrationTesting: FunctionComponent = () => {

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

    const executeUC01 = async () => {
        setMessage("Initiated Settlement App Rotation")
        await executeRunbook("us-east-1", "approtation-Runbook-Managed-Failover", "settlement", "App Rotation", "prod").then(
            (result: any) => {
                console.log("Received Result :" + JSON.stringify(result))
            });
    }

    const executeUC02 = async () => {
        setMessage("Initiated Settlement App Rotation")
        await executeRunbook("us-east-1", "approtation-Runbook-Managed-Failover", "settlement", "App Rotation", "prod").then(
            (result: any) => {
                console.log("Received Result :" + JSON.stringify(result))
            });
    }

    const executeUC03 = async () => {
        setMessage("Initiated Settlement DR Failover")
        await executeRunbook("us-east-1", "approtation-Runbook-Detach-And-Promote", "settlement", "DR", "test").then(
            (result: any) => {
                console.log("Received Result :" + JSON.stringify(result))
            });
    }

    const executeUC04 = async () => {
        setMessage("Initiated Settlement DR Failover")
        await executeRunbook("us-east-1", "approtation-Runbook-Detach-And-Promote", "settlement", "DR", "test").then(
            (result: any) => {
                console.log("Received Result :" + JSON.stringify(result))
            });
    }

    const executeUC05 = async () => {
        setMessage("Initiated Trade Matching App Rotation")
        await executeRunbook("us-east-1", "approtation-Runbook-Managed-Failover", "trade-matching", "App Rotation", "prod").then(
            (result: any) => {
                console.log("Received Result :" + JSON.stringify(result))
            });
    }

    const executeUC06 = async () => {
        setMessage("Initiated Trade Matching App Rotation")
        await executeRunbook("us-east-1", "approtation-Runbook-Managed-Failover", "trade-matching", "App Rotation", "prod").then(
            (result: any) => {
                console.log("Received Result :" + JSON.stringify(result))
            });
    }

    const executeUC07 = async () => {
        setMessage("Initiated Trade Matching DR Failover")
        await executeRunbook("us-east-1", "approtation-Runbook-Detach-And-Promote", "trade-matching", "DR", "test").then(
            (result: any) => {
                console.log("Received Result :" + JSON.stringify(result))
            });
    }

    const executeUC08 = async () => {
        setMessage("Initiated Trade Matching DR Failover")
        await executeRunbook("us-east-1", "approtation-Runbook-Detach-And-Promote", "trade-matching", "DR", "test").then(
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
                                                                        <div className="spacing_2 spacing_5"><b>Use Case ID</b></div>
                                                                    </Grid>
                                                                    <Grid xs={9} className="border_black">
                                                                        <div className="spacing_2 spacing_5"><b>Description</b></div>
                                                                    </Grid>
                                                                    <Grid item xs={2} spacing={5} className="border_black">
                                                                        <div className="left spacing_5"><b>Execute</b></div>
                                                                    </Grid>
                                                                </Grid>

                                                                <Grid container xs={12}>
                                                                    <Grid xs={1} className="border_black">
                                                                        <Grid xs={12} className="spacing_5">
                                                                        </Grid>
                                                                        <div className="spacing_2 spacing_5">Use Case 1</div>
                                                                    </Grid>
                                                                    <Grid xs={9} spacing={5} className="border_black">
                                                                        <Grid xs={12} className="spacing_5">
                                                                        </Grid>
                                                                        <ExpandableSection variant="borderless" header="Operationally Rotate Settlement Application from East to West – Reconcile as needed">
                                                                            <div className="left">
                                                                                <ul>
                                                                                    <li>
                                                                                        Quiesce external facing inbound channels so no new messages are received. Note that if we can operationally rotate without quiescing inbound channels from external clients, that would be ideal.
                                                                                    </li>
                                                                                    <li>
                                                                                        Inspect all queues to ensure all messages have been drained. Files need to be processed or copied to the West region.
                                                                                    </li>
                                                                                    <li>
                                                                                        Shut down Settlement application in the East
                                                                                    </li>
                                                                                    <li>
                                                                                        Rotate Settlement application to West
                                                                                    </li>
                                                                                    <li>
                                                                                        Start application, messages could be received from the Trade Matching Application. There should be no lost messages, missing messages should be in the Outbound Gateway of the Trade Matching Application
                                                                                    </li>
                                                                                    <li>
                                                                                        Reconcile for missing messages/gaps after app is running. Missing messages can be replayed out of order.
                                                                                    </li>
                                                                                </ul>
                                                                            </div>
                                                                        </ExpandableSection>
                                                                    </Grid>

                                                                    <Grid item xs={2} spacing={5} className="border_black">
                                                                        <div className="center spacing_10">
                                                                            &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={executeUC01}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                                                        </div>
                                                                    </Grid>
                                                                </Grid>

                                                                <Grid container xs={12}>
                                                                    <Grid xs={1} className="border_black">
                                                                        <Grid xs={12} className="spacing_5">
                                                                        </Grid>
                                                                        <div className="spacing_2 spacing_5">Use Case 2</div>
                                                                    </Grid>
                                                                    <Grid xs={9} spacing={5} className="border_black">
                                                                        <Grid xs={12} className="spacing_5">
                                                                        </Grid>
                                                                        <ExpandableSection variant="borderless" header="Operationally Rotate Settlement Application from West to East – Reconcile as needed">
                                                                            <div className="left">
                                                                                <ul>
                                                                                    <li>
                                                                                        Quiesce external facing inbound channels so no new messages are received. Note that if we can operationally rotate without quiescing inbound channels from external clients, that would be ideal.
                                                                                    </li>
                                                                                    <li>
                                                                                        Inspect all queues to ensure all messages have been drained. Files need to be processed or copied to the West region.
                                                                                    </li>
                                                                                    <li>
                                                                                        Shut down Settlement application in the West
                                                                                    </li>
                                                                                    <li>
                                                                                        Rotate Settlement application to East
                                                                                    </li>
                                                                                    <li>
                                                                                        Start application, messages could be received from the Trade Matching Application. There should be no lost messages, missing messages should be in the Outbound Gateway of the Trade Matching Application.
                                                                                    </li>
                                                                                    <li>
                                                                                        Reconcile for missing messages/gaps after app is running. Missing messages can be replayed out of order.
                                                                                    </li>
                                                                                </ul>
                                                                            </div>
                                                                        </ExpandableSection>
                                                                    </Grid>

                                                                    <Grid item xs={2} spacing={5} className="border_black">
                                                                        <div className="center spacing_10">
                                                                            &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={executeUC02}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                                                        </div>
                                                                    </Grid>
                                                                </Grid>

                                                                <Grid container xs={12}>
                                                                    <Grid xs={1} className="border_black">
                                                                        <Grid xs={12} className="spacing_5">
                                                                        </Grid>
                                                                        <div className="spacing_2 spacing_5">Use Case 3</div>
                                                                    </Grid>
                                                                    <Grid xs={9} spacing={5} className="border_black">
                                                                        <Grid xs={12} className="spacing_5">
                                                                        </Grid>
                                                                        <ExpandableSection variant="borderless" header="DR Settlement Application from East to West - Reconcile as needed">
                                                                            <div className="left">
                                                                                <ul>
                                                                                    <li>
                                                                                        Fail Settlement application while messages are in flight through entire system. Messages should be in ingest, egress, and OLTP within the Settlement Application. Introduce delays at each process if necessary.
                                                                                    </li>
                                                                                    <li>
                                                                                        Recover and Start Settlement application in West. Keep external entry points disabled.
                                                                                    </li>
                                                                                    <li>
                                                                                        Inspect Settlement Application. Ensure internal application is in sync. Comparison of Ingestion and Egress databases within the Settlement Application. Replay messages from Ingestion if required. There should be lost messages.
                                                                                    </li>
                                                                                    <li>
                                                                                        Start Settlement Application
                                                                                    </li>
                                                                                    <li>
                                                                                        Reconcile for missing messages/gaps after app is running. There is no need to worry about maintaining order between applications. Missing messages can be replayed out of order.
                                                                                    </li>
                                                                                </ul>
                                                                            </div>
                                                                        </ExpandableSection>
                                                                    </Grid>

                                                                    <Grid item xs={2} spacing={5} className="border_black">
                                                                        <div className="center spacing_10">
                                                                            &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={executeUC03}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                                                        </div>
                                                                    </Grid>
                                                                </Grid>

                                                                <Grid container xs={12}>
                                                                    <Grid xs={1} className="border_black">
                                                                        <Grid xs={12} className="spacing_5">
                                                                        </Grid>
                                                                        <div className="spacing_2 spacing_5">Use Case 4</div>
                                                                    </Grid>
                                                                    <Grid xs={9} spacing={5} className="border_black">
                                                                        <Grid xs={12} className="spacing_5">
                                                                        </Grid>
                                                                        <ExpandableSection variant="borderless" header="DR Settlement Application from West to East - Reconcile as needed">
                                                                            <div className="left">
                                                                                <ul>
                                                                                    <li>
                                                                                        Fail Settlement application while messages are in flight through entire system. Messages should be in ingest, egress, and OLTP within the Settlement Application. Introduce delays at each process if necessary.
                                                                                    </li>
                                                                                    <li>
                                                                                        Recover and Start Settlement application in East. Keep external entry points disabled.
                                                                                    </li>
                                                                                    <li>
                                                                                        Inspect Settlement Application. Ensure internal application is in sync. Comparison of Ingestion and Egress databases within the Settlement Application. Replay messages from Ingestion if required. There should be lost messages.
                                                                                    </li>
                                                                                    <li>
                                                                                        Start Settlement Application
                                                                                    </li>
                                                                                    <li>
                                                                                        Reconcile for missing messages/gaps after app is running. There is no need to worry about maintaining order between applications. Missing messages can be replayed out of order.
                                                                                    </li>
                                                                                </ul>
                                                                            </div>
                                                                        </ExpandableSection>
                                                                    </Grid>

                                                                    <Grid item xs={2} spacing={5} className="border_black">
                                                                        <div className="center spacing_10">
                                                                            &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={executeUC04}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                                                        </div>
                                                                    </Grid>
                                                                </Grid>

                                                                <Grid container xs={12}>
                                                                    <Grid xs={1} className="border_black">
                                                                        <Grid xs={12} className="spacing_5">
                                                                        </Grid>
                                                                        <div className="spacing_2 spacing_5">Use Case 5</div>
                                                                    </Grid>
                                                                    <Grid xs={9} spacing={5} className="border_black">
                                                                        <Grid xs={12} className="spacing_5">
                                                                        </Grid>
                                                                        <ExpandableSection variant="borderless" header="Operationally Rotate Trade Matching Application from East to West - Reconcile as needed">
                                                                            <div className="left">
                                                                                <ul>
                                                                                    <li>
                                                                                        Quiesce external facing inbound queues so no new messages are received. Note that if we can operationally rotate without quiescing inbound channels from external clients, that would be ideal.
                                                                                    </li>
                                                                                    <li>
                                                                                        Inspect all queues to ensure all messages have been drained. Files need to be processed or copied to the West region.
                                                                                    </li>
                                                                                    <li>
                                                                                        Shut down Trade Match application in the East.
                                                                                    </li>
                                                                                    <li>
                                                                                        Rotate Trade Match application to West.
                                                                                    </li>
                                                                                    <li>
                                                                                        Start application, messages could be received from the Settlement Application. There should be no lost messages, missing messages should be in the Outbound Gateway of the Settlement Application.
                                                                                    </li>
                                                                                    <li>
                                                                                        Reconcile for missing messages/gaps after app is running. Missing messages can be replayed out of order.
                                                                                    </li>
                                                                                </ul>
                                                                            </div>
                                                                        </ExpandableSection>
                                                                    </Grid>


                                                                    <Grid item xs={2} spacing={5} className="border_black">
                                                                        <div className="center spacing_10">
                                                                            &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={executeUC05}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                                                        </div>
                                                                    </Grid>
                                                                </Grid>

                                                                <Grid container xs={12}>
                                                                    <Grid xs={1} className="border_black">
                                                                        <Grid xs={12} className="spacing_5">
                                                                        </Grid>
                                                                        <div className="spacing_2 spacing_5">Use Case 6</div>
                                                                    </Grid>
                                                                    <Grid xs={9} spacing={5} className="border_black">
                                                                        <Grid xs={12} className="spacing_5">
                                                                        </Grid>
                                                                        <ExpandableSection variant="borderless" header="Operationally Rotate Trade Matching Application from West to East – Reconcile as needed">
                                                                            <div className="left">
                                                                                <ul>
                                                                                    <li>
                                                                                        Quiesce external facing inbound queues so no new messages are received. Note that if we can operationally rotate without quiescing inbound channels from external clients, that would be ideal.
                                                                                    </li>
                                                                                    <li>
                                                                                        Inspect all queues to ensure all messages have been drained. Files need to be processed or copied to the West region.
                                                                                    </li>
                                                                                    <li>
                                                                                        Shut down Trade Match application in the West.
                                                                                    </li>
                                                                                    <li>
                                                                                        Rotate Trade Match application to East.
                                                                                    </li>
                                                                                    <li>
                                                                                        Start application, messages could be received from the Settlement Application. There should be no lost messages, missing messages should be in the Outbound Gateway of the Settlement Application.
                                                                                    </li>
                                                                                    <li>
                                                                                        Reconcile for missing messages/gaps after app is running. Missing messages can be replayed out of order.
                                                                                    </li>
                                                                                </ul>
                                                                            </div>
                                                                        </ExpandableSection>
                                                                    </Grid>

                                                                    <Grid item xs={2} spacing={5} className="border_black">
                                                                        <div className="center spacing_10">
                                                                            &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={executeUC06}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                                                        </div>
                                                                    </Grid>
                                                                </Grid>

                                                                <Grid container xs={12}>
                                                                    <Grid xs={1} className="border_black">
                                                                        <Grid xs={12} className="spacing_5">
                                                                        </Grid>
                                                                        <div className="spacing_2 spacing_5">Use Case 7</div>
                                                                    </Grid>
                                                                    <Grid xs={9} spacing={5} className="border_black">
                                                                        <Grid xs={12} className="spacing_5">
                                                                        </Grid>
                                                                        <ExpandableSection variant="borderless" header="DR Trade Matching Application from East to West - Reconcile as needed">
                                                                            <div className="left">
                                                                                <ul>
                                                                                    <li>
                                                                                        Fail Trade Matching application while messages are in flight through entire system. Messages should be in ingest, egress, and OLTP within the Trade Matching Application. Introduce delays at each process if necessary.
                                                                                    </li>
                                                                                    <li>
                                                                                        Recover and Start Trade Matching application in West. Keep external entry points disabled.
                                                                                    </li>
                                                                                    <li>
                                                                                        Inspect Trade Matching Application. Ensure internal application is in sync. Comparison of Ingestion and Egress databases within the Trade Match Application. Replay messages from Ingestion if required. There should be lost messages.
                                                                                    </li>
                                                                                    <li>
                                                                                        Start Trade Match Application
                                                                                    </li>
                                                                                    <li>
                                                                                        Reconcile for missing messages/gaps after app is running. There is no need to worry about maintaining order between applications. Missing messages can be replayed out of order.
                                                                                    </li>
                                                                                </ul>
                                                                            </div>
                                                                        </ExpandableSection>
                                                                    </Grid>


                                                                    <Grid item xs={2} spacing={5} className="border_black">
                                                                        <div className="center spacing_10">
                                                                            &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={executeUC07}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                                                        </div>
                                                                    </Grid>
                                                                </Grid>


                                                                <Grid container xs={12}>
                                                                    <Grid xs={1} className="border_black">
                                                                        <Grid xs={12} className="spacing_5">
                                                                        </Grid>
                                                                        <div className="spacing_2 spacing_5">Use Case 8</div>
                                                                    </Grid>
                                                                    <Grid xs={9} spacing={5} className="border_black">
                                                                        <Grid xs={12} className="spacing_5">
                                                                        </Grid>
                                                                        <ExpandableSection variant="borderless" header="DR Trade Matching Application from West to East - Reconcile as needed">
                                                                            <div className="left">
                                                                                <ul>
                                                                                    <li>
                                                                                        Fail Trade Matching application while messages are in flight through entire system. Messages should be in ingest, egress, and OLTP within the Trade Matching Application. Introduce delays at each process if necessary.
                                                                                    </li>
                                                                                    <li>
                                                                                        Recover and Start Trade Matching application in East. Keep external entry points disabled.
                                                                                    </li>
                                                                                    <li>
                                                                                        Inspect Trade Matching Application. Ensure internal application is in sync. Comparison of Ingestion and Egress databases within the Trade Match Application. Replay messages from Ingestion if required. There should be lost messages.
                                                                                    </li>
                                                                                    <li>
                                                                                        Start Trade Match Application
                                                                                    </li>
                                                                                    <li>
                                                                                        Reconcile for missing messages/gaps after app is running. There is no need to worry about maintaining order between applications. Missing messages can be replayed out of order.
                                                                                    </li>
                                                                                </ul>
                                                                            </div>
                                                                        </ExpandableSection>
                                                                    </Grid>


                                                                    <Grid item xs={2} spacing={5} className="border_black">
                                                                        <div className="center spacing_10">
                                                                            &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={executeUC08}>Execute</Button>&nbsp;&nbsp;&nbsp;&nbsp;
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

