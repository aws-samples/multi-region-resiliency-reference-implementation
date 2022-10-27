// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import React, {FunctionComponent, useEffect, useState} from 'react';
import {Container, Button, StatusIndicator} from "aws-northstar";
import Stack from "aws-northstar/layouts/Stack";
import '../home/styles.css';
import {IAppHealth, IAppReady, IAppReplication} from "../../interfaces";

import Grid from "aws-northstar/esm/layouts/Grid";
import {
    getAppHealth,
    getAppReady,
    getAppReplication,
} from "../../data";
import Flashbar, {FlashbarMessage} from "aws-northstar/components/Flashbar";
import Alert from "aws-northstar/components/Alert";

const ApplicationMonitor: FunctionComponent = () => {

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

    const getAllRequests = async () => {

        try {

            getAppReady("trade-matching").then(
                (result: IAppReady) => {
                    console.log("Received Result for getAppReady for Trade Matching:" + JSON.stringify(result))
                    setAppReady(result);
                });

            getAppHealth().then(
                (result: IAppHealth) => {
                    console.log("Received Result for getAppHealth for Trade Matching:" + JSON.stringify(result))
                    setAppHealth(result);
                });

            getAppReplication("trade-matching").then(
                (result: IAppReplication) => {
                    console.log("Received Result for getAppReplication for Trade Matching:" + JSON.stringify(result))
                    setAppReplication(result);
                });
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

    useEffect( () => {

        console.log("useEffect Called")

        getAllRequests().then(() => console.log("getAppState() completed."));
        // const interval = setInterval(() => {
        //     getAllRequests().then(() => console.log("getAppState() completed."));
        // }, 3000);
        // return () => clearInterval(interval);

    }, []);


    const renderReady = (ready: any) => {
        return (ready == "READY"?<StatusIndicator statusType="positive"/>:(ready == "NOT_READY"?<StatusIndicator statusType="negative"/>:"?"));
    }

    const renderHealth = (health: any) => {
        return (health == "HEALTHY"?<StatusIndicator statusType="positive"/>:(health == "UNHEALTHY"?<StatusIndicator statusType="negative"/>:"?"));
    }

    const renderReplication = (replication: any) => {
        return (replication == "HEALTHY"?<StatusIndicator statusType="positive"/>:(replication == "DELAYED"?<StatusIndicator statusType="negative"/>:"?"));
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
                                        <b>Trade Matching Application</b>
                                        &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={getAllRequests}>Refresh</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                      </div>
                                    </Grid>

                                    <Grid item xs={6} className="border_black">
                                        <Stack>
                                            <div className="center color_royal_blue">
                                                <b>Primary (US East 1)</b>
                                            </div>
                                            <div className="center" >
                                                <Grid container xs={12} spacing={2} className="spacing_5">

                                                    {/*<Grid item xs={12} spacing={1} className="border_black back_ground_light_cyan">*/}
                                                    {/*    <Stack spacing='s'>*/}

                                                    {/*        <div className="center">*/}
                                                    {/*            <b>Route 53 Controls</b>*/}
                                                    {/*        </div>*/}

                                                    {/*        <div className="left">*/}
                                                    {/*            <Grid container xs={12} spacing={1}>*/}
                                                    {/*                <Grid xs={3} spacing={5}>*/}
                                                    {/*                    <div className="tab spacing_2">Control: DNS</div>*/}
                                                    {/*                </Grid>*/}
                                                    {/*                <Grid xs={1} spacing={5}>*/}
                                                    {/*                    <div className="center">Ready</div>*/}
                                                    {/*                </Grid>*/}
                                                    {/*                <Grid xs={1} spacing={5}>*/}
                                                    {/*                    <div className="center"><StatusIndicator statusType="positive"/></div>*/}
                                                    {/*                </Grid>*/}
                                                    {/*                <Grid xs={1} spacing={5}>*/}
                                                    {/*                    <div className="center">Healthy</div>*/}
                                                    {/*                </Grid>*/}
                                                    {/*                <Grid xs={1} spacing={5}>*/}
                                                    {/*                    <div className="center"><StatusIndicator statusType="positive"/></div>*/}
                                                    {/*                </Grid>*/}
                                                    {/*            </Grid>*/}
                                                    {/*            <Grid container xs={12} spacing={1}>*/}
                                                    {/*                <Grid xs={3} spacing={5}>*/}
                                                    {/*                    <div className="tab spacing_2">Control: Queue</div>*/}
                                                    {/*                </Grid>*/}
                                                    {/*                <Grid xs={1} spacing={5}>*/}
                                                    {/*                    <div className="center">Ready</div>*/}
                                                    {/*                </Grid>*/}
                                                    {/*                <Grid xs={1} spacing={5}>*/}
                                                    {/*                    <div className="center"><StatusIndicator statusType="positive"/></div>*/}
                                                    {/*                </Grid>*/}
                                                    {/*                <Grid xs={1} spacing={5}>*/}
                                                    {/*                    <div className="center">Healthy</div>*/}
                                                    {/*                </Grid>*/}
                                                    {/*                <Grid xs={1} spacing={5}>*/}
                                                    {/*                    <div className="center"><StatusIndicator statusType="positive"/></div>*/}
                                                    {/*                </Grid>*/}
                                                    {/*            </Grid>*/}
                                                    {/*            <Grid container xs={12} spacing={1}>*/}
                                                    {/*                <Grid xs={3} spacing={5}>*/}
                                                    {/*                    <div className="tab spacing_2">Control: App</div>*/}
                                                    {/*                </Grid>*/}
                                                    {/*                <Grid xs={1} spacing={5}>*/}
                                                    {/*                    <div className="center">Ready</div>*/}
                                                    {/*                </Grid>*/}
                                                    {/*                <Grid xs={1} spacing={5}>*/}
                                                    {/*                    <div className="center"><StatusIndicator statusType="positive"/></div>*/}
                                                    {/*                </Grid>*/}
                                                    {/*                <Grid xs={1} spacing={5}>*/}
                                                    {/*                    <div className="center">Healthy</div>*/}
                                                    {/*                </Grid>*/}
                                                    {/*                <Grid xs={1} spacing={5}>*/}
                                                    {/*                    <div className="center"><StatusIndicator statusType="positive"/></div>*/}
                                                    {/*                </Grid>*/}
                                                    {/*            </Grid>*/}
                                                    {/*        </div>*/}

                                                    {/*    </Stack>*/}
                                                    {/*</Grid>*/}

                                                    {/*<Grid xs={12} className="spacing_5">*/}
                                                    {/*</Grid>*/}

                                                    <Grid item xs={12} spacing={1} className="border_black back_ground_light_cyan">
                                                        <Stack spacing='s'>

                                                            <div className="center">
                                                                <b>Inbound Gateway</b>
                                                            </div>

                                                            <div className="left">
                                                                <Grid container xs={12} spacing={1}>
                                                                    <Grid xs={3} spacing={5}>
                                                                        <div className="tab spacing_2">Amazon MQ: Trades</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Ready</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">NA</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Healthy</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderHealth(appHealth.mq)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Replication</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">NA</div>
                                                                    </Grid>
                                                                </Grid>
                                                                <Grid container xs={12} spacing={1}>
                                                                    <Grid xs={3} spacing={5}>
                                                                        <div className="tab spacing_2">Amazon MQ: Settlements</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Ready</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">NA</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Healthy</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderHealth(appHealth.mq)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Replication</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">NA</div>
                                                                    </Grid>
                                                                </Grid>
                                                                <Grid container xs={12} spacing={1}>
                                                                    <Grid xs={3} spacing={5}>
                                                                        <div className="tab spacing_2">DynamoDB: Trades</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Ready</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderReady(appReady.inbound_dynamodb_trade)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Healthy</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderHealth(appHealth.dynamodb)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Replication</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderReplication(appReplication.inbound_dynamodb_trade)}</div>
                                                                    </Grid>
                                                                </Grid>
                                                                <Grid container xs={12} spacing={1}>
                                                                    <Grid xs={3} spacing={5}>
                                                                        <div className="tab spacing_2">DynamoDB: Settlements</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Ready</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderReady(appReady.inbound_dynamodb_settlement)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Healthy</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderHealth(appHealth.dynamodb)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Replication</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderReplication(appReplication.inbound_dynamodb_settlement)}</div>
                                                                    </Grid>
                                                                </Grid>
                                                                <Grid container xs={12} spacing={1}>
                                                                    <Grid xs={3} spacing={5}>
                                                                        <div className="tab spacing_2">ECS Containers</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Ready</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderReady(appReady.inbound_ecs_primary)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Healthy</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderHealth(appHealth.ecs)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Replication</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">NA</div>
                                                                    </Grid>
                                                                </Grid>
                                                            </div>

                                                        </Stack>
                                                    </Grid>

                                                    <Grid xs={12} className="spacing_5">
                                                    </Grid>

                                                    <Grid item xs={12} spacing={1} className="border_black back_ground_light_cyan">
                                                        <Stack spacing='s'>

                                                            <div className="center">
                                                                <b>Ingestion</b>
                                                            </div>

                                                            <div className="left">
                                                                <Grid container xs={12} spacing={1}>
                                                                    <Grid xs={3} spacing={5}>
                                                                        <div className="tab spacing_2">Kinesis: Trades</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Ready</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">NA</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Healthy</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderHealth(appHealth.kinesis)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Replication</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">NA</div>
                                                                    </Grid>
                                                                </Grid>
                                                                <Grid container xs={12} spacing={1}>
                                                                    <Grid xs={3} spacing={5}>
                                                                        <div className="tab spacing_2">Kinesis: Settlements</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Ready</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">NA</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Healthy</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderHealth(appHealth.kinesis)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Replication</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">NA</div>
                                                                    </Grid>
                                                                </Grid>
                                                                <Grid container xs={12} spacing={1}>
                                                                    <Grid xs={3} spacing={5}>
                                                                        <div className="tab spacing_2">DynamoDB: Trades</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Ready</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderReady(appReady.ingestion_dynamodb_trade)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Healthy</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderHealth(appHealth.dynamodb)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Replication</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderReplication(appReplication.ingestion_dynamodb_trade)}</div>
                                                                    </Grid>
                                                                </Grid>
                                                                <Grid container xs={12} spacing={1}>
                                                                    <Grid xs={3} spacing={5}>
                                                                        <div className="tab spacing_2">DynamoDB: Settlements</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Ready</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderReady(appReady.ingestion_dynamodb_settlement)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Healthy</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderHealth(appHealth.dynamodb)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Replication</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderReplication(appReplication.ingestion_dynamodb_settlement)}</div>
                                                                    </Grid>
                                                                </Grid>
                                                                <Grid container xs={12} spacing={1}>
                                                                    <Grid xs={3} spacing={5}>
                                                                        <div className="tab spacing_2">ECS Containers</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Ready</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderReady(appReady.ingestion_ecs_primary)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Healthy</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderHealth(appHealth.ecs)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Replication</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">NA</div>
                                                                    </Grid>
                                                                </Grid>
                                                            </div>

                                                        </Stack>
                                                    </Grid>

                                                    <Grid xs={12} className="spacing_5">
                                                    </Grid>

                                                    <Grid item xs={12} spacing={3} className="border_black back_ground_light_cyan">
                                                        <Stack>

                                                            <div className="center">
                                                                <b>Matching</b>
                                                            </div>

                                                            <div className="left">
                                                                <Grid container xs={12} spacing={1}>
                                                                    <Grid xs={3} spacing={5}>
                                                                        <div className="tab spacing_2">Kinesis: Trades</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Ready</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">NA</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Healthy</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderHealth(appHealth.kinesis)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Replication</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">NA</div>
                                                                    </Grid>
                                                                </Grid>
                                                                <Grid container xs={12} spacing={1}>
                                                                    <Grid xs={3} spacing={5}>
                                                                        <div className="tab spacing_2">Kinesis: Settlements</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Ready</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">NA</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Healthy</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderHealth(appHealth.kinesis)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Replication</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">NA</div>
                                                                    </Grid>
                                                                </Grid>
                                                                <Grid container xs={12} spacing={1}>
                                                                    <Grid xs={3} spacing={5}>
                                                                        <div className="tab spacing_2">RDS</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Ready</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderReady(appReady.matching_rds)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Healthy</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderHealth(appHealth.rds)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Replication</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderReplication(appReplication.matching_rds)}</div>
                                                                    </Grid>
                                                                </Grid>
                                                                <Grid container xs={12} spacing={1}>
                                                                    <Grid xs={3} spacing={5}>
                                                                        <div className="tab spacing_2">ECS Containers: Ingestion</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Ready</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderReady(appReady.matching_ecs_ingestion_primary)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Healthy</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderHealth(appHealth.ecs)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Replication</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">NA</div>
                                                                    </Grid>
                                                                </Grid>
                                                                <Grid container xs={12} spacing={1}>
                                                                    <Grid xs={3} spacing={5}>
                                                                        <div className="tab spacing_2">ECS Containers: Matching</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Ready</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderReady(appReady.matching_ecs_matching_primary)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Healthy</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderHealth(appHealth.ecs)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Replication</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">NA</div>
                                                                    </Grid>
                                                                </Grid>
                                                            </div>

                                                        </Stack>
                                                    </Grid>

                                                    <Grid xs={12} className="spacing_5">
                                                    </Grid>

                                                    <Grid item xs={12} spacing={3} className="border_black back_ground_light_cyan">
                                                        <Stack spacing='s'>

                                                            <div className="center">
                                                                <b>Egress</b>
                                                            </div>

                                                            <div className="left">
                                                                <Grid container xs={12} spacing={1}>
                                                                    <Grid xs={3} spacing={5}>
                                                                        <div className="tab spacing_2">Kinesis: Trades</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Ready</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">NA</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Healthy</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderHealth(appHealth.kinesis)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Replication</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">NA</div>
                                                                    </Grid>
                                                                </Grid>
                                                                <Grid container xs={12} spacing={1}>
                                                                    <Grid xs={3} spacing={5}>
                                                                        <div className="tab spacing_2">Kinesis: Settlements</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Ready</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">NA</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Healthy</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderHealth(appHealth.kinesis)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Replication</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">NA</div>
                                                                    </Grid>
                                                                </Grid>
                                                                <Grid container xs={12} spacing={1}>
                                                                    <Grid xs={3} spacing={5}>
                                                                        <div className="tab spacing_2">DynamoDB: Trades</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Ready</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderReady(appReady.egress_dynamodb_trade)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Healthy</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderHealth(appHealth.dynamodb)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Replication</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderReplication(appReplication.egress_dynamodb_trade)}</div>
                                                                    </Grid>
                                                                </Grid>
                                                                <Grid container xs={12} spacing={1}>
                                                                    <Grid xs={3} spacing={5}>
                                                                        <div className="tab spacing_2">DynamoDB: Settlements</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Ready</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderReady(appReady.egress_dynamodb_settlement)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Healthy</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderHealth(appHealth.dynamodb)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Replication</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderReplication(appReplication.egress_dynamodb_settlement)}</div>
                                                                    </Grid>
                                                                </Grid>
                                                                <Grid container xs={12} spacing={1}>
                                                                    <Grid xs={3} spacing={5}>
                                                                        <div className="tab spacing_2">ECS Containers</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Ready</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderReady(appReady.egress_ecs_primary)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Healthy</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderHealth(appHealth.ecs)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Replication</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">NA</div>
                                                                    </Grid>
                                                                </Grid>
                                                            </div>

                                                        </Stack>
                                                    </Grid>

                                                    <Grid xs={12} className="spacing_5">
                                                    </Grid>

                                                    <Grid item xs={12} spacing={3} className="border_black back_ground_light_cyan">
                                                        <Stack spacing='s'>

                                                            <div className="center">
                                                                <b>Outbound Gateway</b>
                                                            </div>

                                                            <div className="left">
                                                                <Grid container xs={12} spacing={1}>
                                                                    <Grid xs={3} spacing={5}>
                                                                        <div className="tab spacing_2">Kinesis: Trades</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Ready</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">NA</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Healthy</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderHealth(appHealth.kinesis)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Replication</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">NA</div>
                                                                    </Grid>
                                                                </Grid>
                                                                <Grid container xs={12} spacing={1}>
                                                                    <Grid xs={3} spacing={5}>
                                                                        <div className="tab spacing_2">Kinesis: Settlements</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Ready</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">NA</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Healthy</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderHealth(appHealth.kinesis)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Replication</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">NA</div>
                                                                    </Grid>
                                                                </Grid>
                                                                <Grid container xs={12} spacing={1}>
                                                                    <Grid xs={3} spacing={5}>
                                                                        <div className="tab spacing_2">DynamoDB: Trades</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Ready</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderReady(appReady.outbound_dynamodb_trade)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Healthy</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderHealth(appHealth.dynamodb)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Replication</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderReplication(appReplication.outbound_dynamodb_trade)}</div>
                                                                    </Grid>
                                                                </Grid>
                                                                <Grid container xs={12} spacing={1}>
                                                                    <Grid xs={3} spacing={5}>
                                                                        <div className="tab spacing_2">DynamoDB: Settlements</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Ready</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderReady(appReady.outbound_dynamodb_settlement)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Healthy</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderHealth(appHealth.dynamodb)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Replication</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderReplication(appReplication.outbound_dynamodb_settlement)}</div>
                                                                    </Grid>
                                                                </Grid>
                                                                <Grid container xs={12} spacing={1}>
                                                                    <Grid xs={3} spacing={5}>
                                                                        <div className="tab spacing_2">ECS Containers</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Ready</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderReady(appReady.outbound_ecs_primary)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Healthy</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderHealth(appHealth.ecs)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Replication</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">NA</div>
                                                                    </Grid>
                                                                </Grid>
                                                                <Grid container xs={12} spacing={1}>
                                                                    <Grid xs={3} spacing={5}>
                                                                        <div className="tab spacing_2">Amazon MQ: Trades</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Ready</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">NA</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Healthy</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderHealth(appHealth.mq)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Replication</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">NA</div>
                                                                    </Grid>
                                                                </Grid>
                                                                <Grid container xs={12} spacing={1}>
                                                                    <Grid xs={3} spacing={5}>
                                                                        <div className="tab spacing_2">Amazon MQ: Settlements</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Ready</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">NA</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Healthy</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderHealth(appHealth.mq)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Replication</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">NA</div>
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

                                    <Grid item xs={6} className="border_black">
                                        <Stack>
                                            <div className="center color_royal_blue">
                                                <b>Secondary (US West 2)</b>
                                            </div>
                                            <div className="center" >
                                                <Grid container xs={12} spacing={2} className="spacing_5">

                                                    {/*<Grid item xs={12} spacing={1} className="border_black back_ground_light_cyan">*/}
                                                    {/*    <Stack spacing='s'>*/}

                                                    {/*        <div className="center">*/}
                                                    {/*            <b>Route 53 Controls</b>*/}
                                                    {/*        </div>*/}

                                                    {/*        <div className="left">*/}
                                                    {/*            <Grid container xs={12} spacing={1}>*/}
                                                    {/*                <Grid xs={3} spacing={5}>*/}
                                                    {/*                    <div className="tab spacing_2">Control: DNS</div>*/}
                                                    {/*                </Grid>*/}
                                                    {/*                <Grid xs={1} spacing={5}>*/}
                                                    {/*                    <div className="center">Ready</div>*/}
                                                    {/*                </Grid>*/}
                                                    {/*                <Grid xs={1} spacing={5}>*/}
                                                    {/*                    <div className="center"><StatusIndicator statusType="positive"/></div>*/}
                                                    {/*                </Grid>*/}
                                                    {/*                <Grid xs={1} spacing={5}>*/}
                                                    {/*                    <div className="center">Healthy</div>*/}
                                                    {/*                </Grid>*/}
                                                    {/*                <Grid xs={1} spacing={5}>*/}
                                                    {/*                    <div className="center"><StatusIndicator statusType="positive"/></div>*/}
                                                    {/*                </Grid>*/}
                                                    {/*            </Grid>*/}
                                                    {/*            <Grid container xs={12} spacing={1}>*/}
                                                    {/*                <Grid xs={3} spacing={5}>*/}
                                                    {/*                    <div className="tab spacing_2">Control: Queue</div>*/}
                                                    {/*                </Grid>*/}
                                                    {/*                <Grid xs={1} spacing={5}>*/}
                                                    {/*                    <div className="center">Ready</div>*/}
                                                    {/*                </Grid>*/}
                                                    {/*                <Grid xs={1} spacing={5}>*/}
                                                    {/*                    <div className="center"><StatusIndicator statusType="positive"/></div>*/}
                                                    {/*                </Grid>*/}
                                                    {/*                <Grid xs={1} spacing={5}>*/}
                                                    {/*                    <div className="center">Healthy</div>*/}
                                                    {/*                </Grid>*/}
                                                    {/*                <Grid xs={1} spacing={5}>*/}
                                                    {/*                    <div className="center"><StatusIndicator statusType="positive"/></div>*/}
                                                    {/*                </Grid>*/}
                                                    {/*            </Grid>*/}
                                                    {/*            <Grid container xs={12} spacing={1}>*/}
                                                    {/*                <Grid xs={3} spacing={5}>*/}
                                                    {/*                    <div className="tab spacing_2">Control: App</div>*/}
                                                    {/*                </Grid>*/}
                                                    {/*                <Grid xs={1} spacing={5}>*/}
                                                    {/*                    <div className="center">Ready</div>*/}
                                                    {/*                </Grid>*/}
                                                    {/*                <Grid xs={1} spacing={5}>*/}
                                                    {/*                    <div className="center"><StatusIndicator statusType="positive"/></div>*/}
                                                    {/*                </Grid>*/}
                                                    {/*                <Grid xs={1} spacing={5}>*/}
                                                    {/*                    <div className="center">Healthy</div>*/}
                                                    {/*                </Grid>*/}
                                                    {/*                <Grid xs={1} spacing={5}>*/}
                                                    {/*                    <div className="center"><StatusIndicator statusType="positive"/></div>*/}
                                                    {/*                </Grid>*/}
                                                    {/*            </Grid>*/}
                                                    {/*        </div>*/}

                                                    {/*    </Stack>*/}
                                                    {/*</Grid>*/}

                                                    {/*<Grid xs={12} className="spacing_5">*/}
                                                    {/*</Grid>*/}

                                                    <Grid item xs={12} spacing={1} className="border_black back_ground_light_cyan">
                                                        <Stack spacing='s'>

                                                            <div className="center">
                                                                <b>Inbound Gateway</b>
                                                            </div>

                                                            <div className="left">
                                                                <Grid container xs={12} spacing={1}>
                                                                    <Grid xs={3} spacing={5}>
                                                                        <div className="tab spacing_2">Amazon MQ: Trades</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Ready</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">NA</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Healthy</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderHealth(appHealth.mq)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Replication</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">NA</div>
                                                                    </Grid>
                                                                </Grid>
                                                                <Grid container xs={12} spacing={1}>
                                                                    <Grid xs={3} spacing={5}>
                                                                        <div className="tab spacing_2">Amazon MQ: Settlements</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Ready</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">NA</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Healthy</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderHealth(appHealth.mq)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Replication</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">NA</div>
                                                                    </Grid>
                                                                </Grid>
                                                                <Grid container xs={12} spacing={1}>
                                                                    <Grid xs={3} spacing={5}>
                                                                        <div className="tab spacing_2">DynamoDB: Trades</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Ready</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderReady(appReady.inbound_dynamodb_trade)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Healthy</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderHealth(appHealth.dynamodb)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Replication</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderReplication(appReplication.inbound_dynamodb_trade)}</div>
                                                                    </Grid>
                                                                </Grid>
                                                                <Grid container xs={12} spacing={1}>
                                                                    <Grid xs={3} spacing={5}>
                                                                        <div className="tab spacing_2">DynamoDB: Settlements</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Ready</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderReady(appReady.inbound_dynamodb_settlement)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Healthy</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderHealth(appHealth.dynamodb)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Replication</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderReplication(appReplication.inbound_dynamodb_settlement)}</div>
                                                                    </Grid>
                                                                </Grid>
                                                                <Grid container xs={12} spacing={1}>
                                                                    <Grid xs={3} spacing={5}>
                                                                        <div className="tab spacing_2">ECS Containers</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Ready</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderReady(appReady.inbound_ecs_secondary)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Healthy</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderHealth(appHealth.ecs)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Replication</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">NA</div>
                                                                    </Grid>
                                                                </Grid>
                                                            </div>

                                                        </Stack>
                                                    </Grid>

                                                    <Grid xs={12} className="spacing_5">
                                                    </Grid>

                                                    <Grid item xs={12} spacing={1} className="border_black back_ground_light_cyan">
                                                        <Stack spacing='s'>

                                                            <div className="center">
                                                                <b>Ingestion</b>
                                                            </div>

                                                            <div className="left">
                                                                <Grid container xs={12} spacing={1}>
                                                                    <Grid xs={3} spacing={5}>
                                                                        <div className="tab spacing_2">Kinesis: Trades</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Ready</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">NA</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Healthy</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderHealth(appHealth.kinesis)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Replication</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">NA</div>
                                                                    </Grid>
                                                                </Grid>
                                                                <Grid container xs={12} spacing={1}>
                                                                    <Grid xs={3} spacing={5}>
                                                                        <div className="tab spacing_2">Kinesis: Settlements</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Ready</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">NA</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Healthy</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderHealth(appHealth.kinesis)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Replication</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">NA</div>
                                                                    </Grid>
                                                                </Grid>
                                                                <Grid container xs={12} spacing={1}>
                                                                    <Grid xs={3} spacing={5}>
                                                                        <div className="tab spacing_2">DynamoDB: Trades</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Ready</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderReady(appReady.ingestion_dynamodb_trade)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Healthy</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderHealth(appHealth.dynamodb)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Replication</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderReplication(appReplication.ingestion_dynamodb_trade)}</div>
                                                                    </Grid>
                                                                </Grid>
                                                                <Grid container xs={12} spacing={1}>
                                                                    <Grid xs={3} spacing={5}>
                                                                        <div className="tab spacing_2">DynamoDB: Settlements</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Ready</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderReady(appReady.ingestion_dynamodb_settlement)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Healthy</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderHealth(appHealth.dynamodb)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Replication</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderReplication(appReplication.ingestion_dynamodb_settlement)}</div>
                                                                    </Grid>
                                                                </Grid>
                                                                <Grid container xs={12} spacing={1}>
                                                                    <Grid xs={3} spacing={5}>
                                                                        <div className="tab spacing_2">ECS Containers</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Ready</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderReady(appReady.ingestion_ecs_secondary)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Healthy</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderHealth(appHealth.ecs)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Replication</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">NA</div>
                                                                    </Grid>
                                                                </Grid>
                                                            </div>

                                                        </Stack>
                                                    </Grid>

                                                    <Grid xs={12} className="spacing_5">
                                                    </Grid>

                                                    <Grid item xs={12} spacing={3} className="border_black back_ground_light_cyan">
                                                        <Stack>

                                                            <div className="center">
                                                                <b>Matching</b>
                                                            </div>

                                                            <div className="left">
                                                                <Grid container xs={12} spacing={1}>
                                                                    <Grid xs={3} spacing={5}>
                                                                        <div className="tab spacing_2">Kinesis: Trades</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Ready</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">NA</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Healthy</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderHealth(appHealth.kinesis)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Replication</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">NA</div>
                                                                    </Grid>
                                                                </Grid>
                                                                <Grid container xs={12} spacing={1}>
                                                                    <Grid xs={3} spacing={5}>
                                                                        <div className="tab spacing_2">Kinesis: Settlements</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Ready</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">NA</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Healthy</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderHealth(appHealth.kinesis)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Replication</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">NA</div>
                                                                    </Grid>
                                                                </Grid>
                                                                <Grid container xs={12} spacing={1}>
                                                                    <Grid xs={3} spacing={5}>
                                                                        <div className="tab spacing_2">RDS</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Ready</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderReady(appReady.matching_rds)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Healthy</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderHealth(appHealth.rds)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Replication</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderReplication(appReplication.matching_rds)}</div>
                                                                    </Grid>
                                                                </Grid>
                                                                <Grid container xs={12} spacing={1}>
                                                                    <Grid xs={3} spacing={5}>
                                                                        <div className="tab spacing_2">ECS Containers: Ingestion</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Ready</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderReady(appReady.matching_ecs_ingestion_secondary)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Healthy</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderHealth(appHealth.ecs)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Replication</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">NA</div>
                                                                    </Grid>
                                                                </Grid>
                                                                <Grid container xs={12} spacing={1}>
                                                                    <Grid xs={3} spacing={5}>
                                                                        <div className="tab spacing_2">ECS Containers: Matching</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Ready</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderReady(appReady.matching_ecs_matching_secondary)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Healthy</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderHealth(appHealth.ecs)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Replication</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">NA</div>
                                                                    </Grid>
                                                                </Grid>
                                                            </div>

                                                        </Stack>
                                                    </Grid>

                                                    <Grid xs={12} className="spacing_5">
                                                    </Grid>

                                                    <Grid item xs={12} spacing={3} className="border_black back_ground_light_cyan">
                                                        <Stack spacing='s'>

                                                            <div className="center">
                                                                <b>Egress</b>
                                                            </div>

                                                            <div className="left">
                                                                <Grid container xs={12} spacing={1}>
                                                                    <Grid xs={3} spacing={5}>
                                                                        <div className="tab spacing_2">Kinesis: Trades</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Ready</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">NA</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Healthy</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderHealth(appHealth.kinesis)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Replication</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">NA</div>
                                                                    </Grid>
                                                                </Grid>
                                                                <Grid container xs={12} spacing={1}>
                                                                    <Grid xs={3} spacing={5}>
                                                                        <div className="tab spacing_2">Kinesis: Settlements</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Ready</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">NA</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Healthy</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderHealth(appHealth.kinesis)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Replication</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">NA</div>
                                                                    </Grid>
                                                                </Grid>
                                                                <Grid container xs={12} spacing={1}>
                                                                    <Grid xs={3} spacing={5}>
                                                                        <div className="tab spacing_2">DynamoDB: Trades</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Ready</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderReady(appReady.egress_dynamodb_trade)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Healthy</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderHealth(appHealth.dynamodb)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Replication</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderReplication(appReplication.egress_dynamodb_trade)}</div>
                                                                    </Grid>
                                                                </Grid>
                                                                <Grid container xs={12} spacing={1}>
                                                                    <Grid xs={3} spacing={5}>
                                                                        <div className="tab spacing_2">DynamoDB: Settlements</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Ready</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderReady(appReady.egress_dynamodb_settlement)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Healthy</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderHealth(appHealth.dynamodb)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Replication</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderReplication(appReplication.egress_dynamodb_settlement)}</div>
                                                                    </Grid>
                                                                </Grid>
                                                                <Grid container xs={12} spacing={1}>
                                                                    <Grid xs={3} spacing={5}>
                                                                        <div className="tab spacing_2">ECS Containers</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Ready</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderReady(appReady.egress_ecs_secondary)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Healthy</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderHealth(appHealth.ecs)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Replication</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">NA</div>
                                                                    </Grid>
                                                                </Grid>
                                                            </div>

                                                        </Stack>
                                                    </Grid>

                                                    <Grid xs={12} className="spacing_5">
                                                    </Grid>

                                                    <Grid item xs={12} spacing={3} className="border_black back_ground_light_cyan">
                                                        <Stack spacing='s'>

                                                            <div className="center">
                                                                <b>Outbound Gateway</b>
                                                            </div>

                                                            <div className="left">
                                                                <Grid container xs={12} spacing={1}>
                                                                    <Grid xs={3} spacing={5}>
                                                                        <div className="tab spacing_2">Kinesis: Trades</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Ready</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">NA</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Healthy</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderHealth(appHealth.kinesis)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Replication</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">NA</div>
                                                                    </Grid>
                                                                </Grid>
                                                                <Grid container xs={12} spacing={1}>
                                                                    <Grid xs={3} spacing={5}>
                                                                        <div className="tab spacing_2">Kinesis: Settlements</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Ready</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">NA</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Healthy</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderHealth(appHealth.kinesis)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Replication</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">NA</div>
                                                                    </Grid>
                                                                </Grid>
                                                                <Grid container xs={12} spacing={1}>
                                                                    <Grid xs={3} spacing={5}>
                                                                        <div className="tab spacing_2">DynamoDB: Trades</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Ready</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderReady(appReady.outbound_dynamodb_trade)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Healthy</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderHealth(appHealth.dynamodb)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Replication</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderReplication(appReplication.outbound_dynamodb_trade)}</div>
                                                                    </Grid>
                                                                </Grid>
                                                                <Grid container xs={12} spacing={1}>
                                                                    <Grid xs={3} spacing={5}>
                                                                        <div className="tab spacing_2">DynamoDB: Settlements</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Ready</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderReady(appReady.outbound_dynamodb_settlement)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Healthy</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderHealth(appHealth.dynamodb)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Replication</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderReplication(appReplication.outbound_dynamodb_settlement)}</div>
                                                                    </Grid>
                                                                </Grid>
                                                                <Grid container xs={12} spacing={1}>
                                                                    <Grid xs={3} spacing={5}>
                                                                        <div className="tab spacing_2">ECS Containers</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Ready</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderReady(appReady.outbound_ecs_secondary)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Healthy</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderHealth(appHealth.ecs)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Replication</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">NA</div>
                                                                    </Grid>
                                                                </Grid>
                                                                <Grid container xs={12} spacing={1}>
                                                                    <Grid xs={3} spacing={5}>
                                                                        <div className="tab spacing_2">Amazon MQ: Trades</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Ready</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">NA</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Healthy</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderHealth(appHealth.mq)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Replication</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">NA</div>
                                                                    </Grid>
                                                                </Grid>
                                                                <Grid container xs={12} spacing={1}>
                                                                    <Grid xs={3} spacing={5}>
                                                                        <div className="tab spacing_2">Amazon MQ: Settlements</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Ready</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">NA</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Healthy</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">{renderHealth(appHealth.mq)}</div>
                                                                    </Grid>
                                                                    <Grid xs={2} spacing={5}>
                                                                        <div className="center">Replication</div>
                                                                    </Grid>
                                                                    <Grid xs={1} spacing={5}>
                                                                        <div className="center">NA</div>
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

export default ApplicationMonitor;

