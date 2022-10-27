// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import React, {FunctionComponent, useEffect, useState} from 'react';
import {Container, Button} from "aws-northstar";
import Stack from "aws-northstar/layouts/Stack";
import '../home/styles.css';
import {IAppControls, IAppState} from "../../interfaces";

import {useHistory} from "react-router-dom";
import Grid from "aws-northstar/esm/layouts/Grid";
import {executeRunbook, getAppControls, getAppStates, updateArcControl} from "../../data";
import Flashbar, {FlashbarMessage} from "aws-northstar/components/Flashbar";
import Alert from "aws-northstar/components/Alert";

import dns_on from "./dns_on.png";
import dns_off from "./dns_off.png";
import queue_on from "./queue_on.png";
import queue_off from "./queue_off.png";
import app_on from "./app_on.png";
import app_off from "./app_off.png";

const ApplicationState: FunctionComponent = () => {

    const history = useHistory();

    const [tradeMatchingPrimaryState, setTradeMatchingPrimaryState] = useState<IAppState>({});
    const [tradeMatchingSecondaryState, setTradeMatchingSecondaryState] = useState<IAppState>({});
    const [settlementPrimaryState, setSettlementPrimaryState] = useState<IAppState>({});
    const [settlementSecondaryState, setSettlementSecondaryState] = useState<IAppState>({});
    const [tradeMatchingPrimaryControls, setTradeMatchingPrimaryControls] = useState<IAppControls>({});
    const [tradeMatchingSecondaryControls, setTradeMatchingSecondaryControls] = useState<IAppControls>({});
    const [settlementPrimaryControls, setSettlementPrimaryControls] = useState<IAppControls>({});
    const [settlementSecondaryControls, setSettlementSecondaryControls] = useState<IAppControls>({});
    const [errors, setErrors] = React.useState<FlashbarMessage[]>([]);
    const [message, setMessage] = React.useState<String>("");

    const startTradeGenerator = async () => {

        setMessage("Initiated Trade Generator Start")
        let request = await updateArcControl("trade-matching", "generator", "", "On").then(
            (result: any) => {
                console.log("Received Result :" + JSON.stringify(result))
            });
    }

    const stopTradeGenerator = async () => {

        setMessage("Initiated Trade Generator Stop")
        let request = await updateArcControl("trade-matching", "generator", "", "Off").then(
            (result: any) => {
                console.log("Received Result :" + JSON.stringify(result))
            });
    }

    const rotateTradeMatching = async () => {
        setMessage("Initiated Trade Matching App Rotation")
        let request = await executeRunbook("us-east-1", "approtation-Runbook-Managed-Failover", "trade-matching", "App Rotation", "test", "Off").then(
            (result: any) => {
                console.log("Received Result :" + JSON.stringify(result))
            });
    }

    const drTradeMatching = async () => {
        setMessage("Initiated Trade Matching DR")
        let request = await executeRunbook("us-east-1", "approtation-Runbook-Detach-And-Promote", "trade-matching", "DR", "test", "Off").then(
            (result: any) => {
                console.log("Received Result :" + JSON.stringify(result))
            });
    }

    const rotateSettlement = async () => {
        setMessage("Initiated Settlement App Rotation")
        let request = await executeRunbook("us-east-1", "approtation-Runbook-Managed-Failover", "settlement", "App Rotation", "test", "Off").then(
            (result: any) => {
                console.log("Received Result :" + JSON.stringify(result))
            });
    }

    const drSettlement = async () => {
        setMessage("Initiated Settlement App Rotation")
        let request = await executeRunbook("us-east-1", "approtation-Runbook-Detach-And-Promote", "settlement", "DR", "test", "Off").then(
            (result: any) => {
                console.log("Received Result :" + JSON.stringify(result))
            });
    }

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

            // getAppStates("trade-matching").then(
            //     (result: IAppState[]) => {
            //         console.log("Received Result for getAppState for Trade Matching:" + JSON.stringify(result))
            //         setTradeMatchingPrimaryState(get_app_state(result, "trade-matching", "us-east-1"));
            //         setTradeMatchingSecondaryState(get_app_state(result, "trade-matching", "us-west-2"));
            //     });
            //
            // getAppStates("settlement").then(
            //     (result: IAppState[]) => {
            //         console.log("Received Result  for getAppState for Settlement" + JSON.stringify(result))
            //         setSettlementPrimaryState(get_app_state(result, "settlement", "us-east-1"));
            //         setSettlementSecondaryState(get_app_state(result, "settlement", "us-west-2"));
            //     });
            //
            // getAppControls("trade-matching", "us-east-1").then(
            //     (result: IAppControls) => {
            //         console.log("Received Result for getAppControls for Trade Matching for Primary:" + JSON.stringify(result))
            //         setTradeMatchingPrimaryControls(result);
            //     });
            //
            // getAppControls("trade-matching", "us-west-2").then(
            //     (result: IAppControls) => {
            //         console.log("Received Result for getAppControls for Trade Matching for Secondary:" + JSON.stringify(result))
            //         setTradeMatchingSecondaryControls(result);
            //     });
            //
            // getAppControls("settlement", "us-east-1").then(
            //     (result: IAppControls) => {
            //         console.log("Received Result for getAppControls for Settlement for Primary:" + JSON.stringify(result))
            //         setSettlementPrimaryControls(result);
            //     });
            //
            // getAppControls("settlement", "us-west-2").then(
            //     (result: IAppControls) => {
            //         console.log("Received Result for getAppControls for Settlement for Secondary:" + JSON.stringify(result))
            //         setSettlementSecondaryControls(result);
            //     });

            try {
                let request1 = await getAppStates("trade-matching").then(
                    (result: IAppState[]) => {
                        console.log("Received Result for getAppState for Trade Matching:" + JSON.stringify(result))
                        setTradeMatchingPrimaryState(get_app_state(result, "trade-matching", "us-east-1"));
                        setTradeMatchingSecondaryState(get_app_state(result, "trade-matching", "us-west-2"));
                    });
            }
            catch (err) {
                // const items:FlashbarMessage[] = [
                //     {
                //         header: 'Could not get the app state for Trade Matching: ' + err.toString(),
                //         type: 'error',
                //         dismissible: true,
                //     }
                // ];
                // setErrors(items);
            }

            try {
                let request2 = await getAppStates("settlement").then(
                    (result: IAppState[]) => {
                        console.log("Received Result  for getAppState for Settlement" + JSON.stringify(result))
                        setSettlementPrimaryState(get_app_state(result, "settlement", "us-east-1"));
                        setSettlementSecondaryState(get_app_state(result, "settlement", "us-west-2"));
                    });
            }
            catch (err) {
                // const items:FlashbarMessage[] = [
                //     {
                //         header: 'Could not get the app state for Settlement: ' + err.toString(),
                //         type: 'error',
                //         dismissible: true,
                //     }
                // ];
                // setErrors(items);
            }

            try {
                let request3 = await getAppControls("trade-matching", "us-east-1").then(
                    (result: IAppControls) => {
                        console.log("Received Result for getAppControls for Trade Matching for Primary:" + JSON.stringify(result))
                        setTradeMatchingPrimaryControls(result);
                    });
            }
            catch (err) {
                // const items:FlashbarMessage[] = [
                //     {
                //         header: 'Could not get the app controls for Trade Matching for Primary: ' + err.toString(),
                //         type: 'error',
                //         dismissible: true,
                //     }
                // ];
                // setErrors(items);
            }

            try {
                let request4 = await getAppControls("trade-matching", "us-west-2").then(
                    (result: IAppControls) => {
                        console.log("Received Result for getAppControls for Trade Matching for Secondary:" + JSON.stringify(result))
                        setTradeMatchingSecondaryControls(result);
                    });
            }
            catch (err) {
                // const items:FlashbarMessage[] = [
                //     {
                //         header: 'Could not get the app controls for Trade Matching for Secondary: ' + err.toString(),
                //         type: 'error',
                //         dismissible: true,
                //     }
                // ];
                // setErrors(items);
            }

            try {
                let request5 = await getAppControls("settlement", "us-east-1").then(
                    (result: IAppControls) => {
                        console.log("Received Result for getAppControls for Settlement for Primary:" + JSON.stringify(result))
                        setSettlementPrimaryControls(result);
                    });
            }
            catch (err) {
                // const items:FlashbarMessage[] = [
                //     {
                //         header: 'Could not get the app controls for Settlement for Primary: ' + err.toString(),
                //         type: 'error',
                //         dismissible: true,
                //     }
                // ];
                // setErrors(items);
            }

            try {
                let request6 = await getAppControls("settlement", "us-west-2").then(
                    (result: IAppControls) => {
                        console.log("Received Result for getAppControls for Settlement for Secondary:" + JSON.stringify(result))
                        setSettlementSecondaryControls(result);
                    });
            }
            catch (err) {
                // const items:FlashbarMessage[] = [
                //     {
                //         header: 'Could not get the app controls for Settlement for Secondary: ' + err.toString(),
                //         type: 'error',
                //         dismissible: true,
                //     }
                // ];
                // setErrors(items);
            }

            await Promise.resolve();

        }
        catch (err) {
            // const items:FlashbarMessage[] = [
            //     {
            //         header: 'Could not get the app state: ' + err.toString(),
            //         type: 'error',
            //         dismissible: true,
            //     }
            // ];
            // setErrors(items);
        }
    }

    // const getAllRequests = async () => {
    //
    //     try {
    //
    //         let request1 = await getAppState("trade-matching", "us-east-1").then(
    //             (result: IAppState) => {
    //                 console.log("Received Result :" + JSON.stringify(result))
    //                 setTradeMatchingPrimaryState(result);
    //             });
    //
    //         let request2 = await getAppState("trade-matching", "us-west-2").then(
    //             (result: IAppState) => {
    //                 console.log("Received Result :" + JSON.stringify(result))
    //                 setTradeMatchingSecondaryState(result);
    //             });
    //
    //         let request3 = await getAppState("settlement", "us-east-1").then(
    //             (result: IAppState) => {
    //                 console.log("Received Result :" + JSON.stringify(result))
    //                 setSettlementPrimaryState(result);
    //             });
    //
    //         let request4 = await getAppState("settlement", "us-west-2").then(
    //             (result: IAppState) => {
    //                 console.log("Received Result :" + JSON.stringify(result))
    //                 setSettlementSecondaryState(result);
    //             });
    //
    //         await Promise.resolve();
    //
    //     }
    //     catch (err) {
    //         const items:FlashbarMessage[] = [
    //             {
    //                 header: 'Could not get the app state: ' + err.toString(),
    //                 type: 'error',
    //                 dismissible: true,
    //             }
    //         ];
    //         setErrors(items);
    //     }
    // }

    useEffect( () => {

        console.log("useEffect Called")

        getAllRequests().then(() => console.log("getAppState() completed."));
        const interval = setInterval(() => {
            getAllRequests().then(() => console.log("getAppState() completed."));
        }, 3000);
        return () => clearInterval(interval);

    }, []);


    const renderDNSControl = (state: any) => {
        return (state == "On"?<img src={dns_on} width="50" height="50"/>:<img src={dns_off} width="50" height="50"/>);
    }

    const renderQueueControl = (state: any) => {
        return (state == "On"?<img src={queue_on} width="50" height="50"/>:<img src={queue_off} width="50" height="50"/>);
    }

    const renderAppControl = (state: any) => {
        return (state == "On"?<img src={app_on} width="50" height="50"/>:<img src={app_off} width="50" height="50"/>);
    }

    return (
        <Stack>
            <div>
                <div className="awsui-grid awsui-util-p-s">
                    <div className="awsui-util-pt-xxl awsui-row">
                        <div className="custom-home-main-content-area col-xxs-10 offset-xxs-1 col-s-6 col-l-5 offset-l-2 col-xl-6">

                            <Container headingVariant='h4'>
                                <Grid container spacing={3} className="spacing_10">

                                    <Grid item xs={4} spacing={5} className="border_black">
                                        <div className="center">
                                            <b>Trade Generator</b>
                                            &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={startTradeGenerator}>Start</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                            &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={stopTradeGenerator}>Stop</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                        </div>
                                    </Grid>

                                    <Grid item xs={4} spacing={5} className="border_black">
                                        <div className="center">
                                            <b>Trade Matching</b>
                                            &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={rotateTradeMatching}>Rotate</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                            &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={drTradeMatching}>DR</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                        </div>
                                    </Grid>

                                    <Grid item xs={4} spacing={5} className="border_black">
                                        <div className="center">
                                            <b>Settlement</b>
                                            &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={rotateSettlement}>Rotate</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                            &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={drSettlement}>DR</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                        </div>
                                    </Grid>

                                    <Grid item xs={6} className="border_black">
                                        <Stack>
                                            <div className="center color_royal_blue">
                                                <b>Primary (US East 1)</b>
                                            </div>
                                            <div className="center">
                                                <Grid container xs={12} spacing={3}>
                                                    <Grid item xs={6} spacing={5} className="border_black">

                                                        <div className="center" >
                                                            <Grid container xs={12} spacing={2} className="spacing_5">

                                                                <Grid item xs={12} spacing={1}>
                                                                    <div className="center color_green">
                                                                        <b>Trade Matching</b>
                                                                    </div>
                                                                </Grid>

                                                                <Grid item xs={12} spacing={1} className="border_black center">

                                                                    <Grid item xs={4} spacing={1}>
                                                                        <div className="center">
                                                                            {renderDNSControl(tradeMatchingPrimaryControls.dns_arc_control_state?tradeMatchingPrimaryControls.dns_arc_control_state:"Off")}
                                                                        </div>
                                                                    </Grid>

                                                                    <Grid item xs={4} spacing={1}>
                                                                        <div className="center">
                                                                            {renderQueueControl(tradeMatchingPrimaryControls.queue_arc_control_state?tradeMatchingPrimaryControls.queue_arc_control_state:"Off")}
                                                                        </div>
                                                                    </Grid>

                                                                    <Grid item xs={4} spacing={1}>
                                                                        <div className="center">
                                                                            {renderAppControl(tradeMatchingPrimaryControls.app_arc_control_state?tradeMatchingPrimaryControls.app_arc_control_state:"Off")}
                                                                        </div>
                                                                    </Grid>

                                                                </Grid>

                                                                <Grid xs={12} className="spacing_5">
                                                                </Grid>

                                                                <Grid item xs={12} spacing={1} className="border_black back_ground_light_cyan">
                                                                    <Stack spacing='s'>

                                                                        <div className="center">
                                                                            <b>Inbound Gateway</b>
                                                                        </div>

                                                                        <div className="center">
                                                                            <Grid container xs={12} spacing={1}>
                                                                                <Grid xs={5} spacing={5}>
                                                                                    <Stack>
                                                                                    <div className="center back_ground_honey_dew border_green">Trades: {tradeMatchingPrimaryState.inbound_gateway_trade_store_count?tradeMatchingPrimaryState.inbound_gateway_trade_store_count:0}</div>
                                                                                    </Stack>
                                                                                </Grid>

                                                                                <Grid xs={2} className="spacing_5">
                                                                                </Grid>

                                                                                <Grid xs={5} spacing={5}>
                                                                                    <Stack>
                                                                                    <div className="center back_ground_honey_dew border_green">Settlements: {tradeMatchingPrimaryState.inbound_gateway_settlement_store_count?tradeMatchingPrimaryState.inbound_gateway_settlement_store_count:0}</div>
                                                                                    </Stack>
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

                                                                        <div className="center">
                                                                            <Grid container xs={12} spacing={1}>
                                                                                <Grid xs={5} spacing={5}>
                                                                                    <Stack>
                                                                                        <div className="center back_ground_honey_dew border_green">Trades: {tradeMatchingPrimaryState.ingestion_trade_store_count?tradeMatchingPrimaryState.ingestion_trade_store_count:0}</div>
                                                                                    </Stack>
                                                                                </Grid>

                                                                                <Grid xs={2} className="spacing_5">
                                                                                </Grid>

                                                                                <Grid xs={5} spacing={5}>
                                                                                    <Stack>
                                                                                        <div className="center back_ground_honey_dew border_green">Settlements: {tradeMatchingPrimaryState.ingestion_settlement_store_count?tradeMatchingPrimaryState.ingestion_settlement_store_count:0}</div>
                                                                                    </Stack>
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

                                                                        <div className="center">
                                                                            <Grid container xs={12} spacing={3}>
                                                                                <Grid xs={5} spacing={5}>
                                                                                    <Stack>
                                                                                        <div className="center back_ground_honey_dew border_green">Total: {tradeMatchingPrimaryState.matching_store_count?tradeMatchingPrimaryState.matching_store_count:0}</div>
                                                                                    </Stack>
                                                                                </Grid>

                                                                                <Grid xs={2} className="spacing_5">
                                                                                </Grid>

                                                                                <Grid xs={5} spacing={5}>
                                                                                    <Stack>
                                                                                        <div className="center back_ground_honey_dew border_green">Settled: {tradeMatchingPrimaryState.matching_settled_store_count?tradeMatchingPrimaryState.matching_settled_store_count:0}</div>
                                                                                    </Stack>
                                                                                </Grid>

                                                                                <Grid xs={12} className="spacing_5">
                                                                                </Grid>

                                                                                <Grid xs={5} spacing={5}>
                                                                                    <Stack>
                                                                                        <div className="center back_ground_honey_dew border_green">Matched: {tradeMatchingPrimaryState.matching_matched_store_count?tradeMatchingPrimaryState.matching_matched_store_count:0}</div>
                                                                                    </Stack>
                                                                                </Grid>

                                                                                <Grid xs={2} className="spacing_5">
                                                                                </Grid>

                                                                                <Grid xs={5} spacing={5}>
                                                                                    <Stack>
                                                                                        <div className="center back_ground_honey_dew border_green">Mismatched: {tradeMatchingPrimaryState.matching_mismatched_store_count?tradeMatchingPrimaryState.matching_mismatched_store_count:0}</div>
                                                                                    </Stack>
                                                                                </Grid>

                                                                                <Grid xs={12} className="spacing_5">
                                                                                </Grid>

                                                                                <Grid xs={5} spacing={5}>
                                                                                    <Stack>
                                                                                        <div className="center back_ground_honey_dew border_green">Unmatched: {tradeMatchingPrimaryState.matching_unmatched_store_count?tradeMatchingPrimaryState.matching_unmatched_store_count:0}</div>
                                                                                    </Stack>
                                                                                </Grid>

                                                                                <Grid xs={7} className="spacing_5">
                                                                                </Grid>

                                                                                <Grid xs={12} className="spacing_5">
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

                                                                        <div className="center">
                                                                            <Grid container xs={12} spacing={1}>
                                                                                <Grid xs={5} spacing={5}>
                                                                                    <Stack>
                                                                                        <div className="center back_ground_honey_dew border_green">Trades: {tradeMatchingPrimaryState.egress_trade_store_count?tradeMatchingPrimaryState.egress_trade_store_count:0}</div>
                                                                                    </Stack>
                                                                                </Grid>

                                                                                <Grid xs={2} className="spacing_5">
                                                                                </Grid>

                                                                                <Grid xs={5} spacing={5}>
                                                                                    <Stack>
                                                                                        <div className="center back_ground_honey_dew border_green">Settlements: {tradeMatchingPrimaryState.egress_settlement_store_count?tradeMatchingPrimaryState.egress_settlement_store_count:0}</div>
                                                                                    </Stack>
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

                                                                        <div className="center">
                                                                            <Grid container xs={12} spacing={1}>
                                                                                <Grid xs={5} spacing={5}>
                                                                                    <Stack>
                                                                                        <div className="center back_ground_honey_dew border_green">Trades: {tradeMatchingPrimaryState.outbound_gateway_trade_store_count?tradeMatchingPrimaryState.outbound_gateway_trade_store_count:0}</div>
                                                                                    </Stack>
                                                                                </Grid>

                                                                                <Grid xs={2} className="spacing_5">
                                                                                </Grid>

                                                                                <Grid xs={5} spacing={5}>
                                                                                    <Stack>
                                                                                        <div className="center back_ground_honey_dew border_green">Settlements: {tradeMatchingPrimaryState.outbound_gateway_settlement_store_count?tradeMatchingPrimaryState.outbound_gateway_settlement_store_count:0}</div>
                                                                                    </Stack>
                                                                                </Grid>
                                                                            </Grid>
                                                                        </div>

                                                                    </Stack>
                                                                </Grid>

                                                                <Grid xs={12} className="spacing_5">
                                                                </Grid>

                                                            </Grid>
                                                        </div>
                                                    </Grid>

                                                    <Grid item xs={6} spacing={5} className="border_black">

                                                        <div className="center" >
                                                            <Grid container xs={12} spacing={2} className="spacing_5">

                                                                <Grid item xs={12} spacing={3}>
                                                                    <div className="center color_green">
                                                                        <b>Settlement</b>
                                                                    </div>
                                                                </Grid>

                                                                <Grid item xs={12} spacing={1} className="border_black center">

                                                                    <Grid item xs={4} spacing={1}>
                                                                        <div className="center">
                                                                            {renderDNSControl(settlementPrimaryControls.dns_arc_control_state?settlementPrimaryControls.dns_arc_control_state:"Off")}
                                                                        </div>
                                                                    </Grid>

                                                                    <Grid item xs={4} spacing={1}>
                                                                        <div className="center">
                                                                            {renderQueueControl(settlementPrimaryControls.queue_arc_control_state?settlementPrimaryControls.queue_arc_control_state:"Off")}
                                                                        </div>
                                                                    </Grid>

                                                                    <Grid item xs={4} spacing={1}>
                                                                        <div className="center">
                                                                            {renderAppControl(settlementPrimaryControls.app_arc_control_state?settlementPrimaryControls.app_arc_control_state:"Off")}
                                                                        </div>
                                                                    </Grid>

                                                                </Grid>

                                                                <Grid xs={12} className="spacing_5">
                                                                </Grid>

                                                                <Grid item xs={12} spacing={1} className="border_black back_ground_misty_rose">
                                                                    <Stack spacing='s'>

                                                                        <div className="center">
                                                                            <b>Inbound Gateway</b>
                                                                        </div>

                                                                        <div className="center">
                                                                            <Grid container xs={12} spacing={1} className="center">

                                                                                <Grid xs={5} spacing={5}>
                                                                                    <Stack>
                                                                                        <div className="center back_ground_honey_dew border_green">Settlements: {settlementPrimaryState.inbound_gateway_settlement_store_count?settlementPrimaryState.inbound_gateway_settlement_store_count:0}</div>
                                                                                    </Stack>
                                                                                </Grid>
                                                                            </Grid>
                                                                        </div>

                                                                    </Stack>
                                                                </Grid>

                                                                <Grid xs={12} className="spacing_5">
                                                                </Grid>

                                                                <Grid item xs={12} spacing={1} className="border_black back_ground_misty_rose">
                                                                    <Stack spacing='s'>

                                                                        <div className="center">
                                                                            <b>Ingestion</b>
                                                                        </div>

                                                                        <div className="center">
                                                                            <Grid container xs={12} spacing={1} className="center">

                                                                                <Grid xs={5} spacing={5}>
                                                                                    <Stack>
                                                                                        <div className="center back_ground_honey_dew border_green">Settlements: {settlementPrimaryState.ingestion_settlement_store_count?settlementPrimaryState.ingestion_settlement_store_count:0}</div>
                                                                                    </Stack>
                                                                                </Grid>
                                                                            </Grid>
                                                                        </div>

                                                                    </Stack>
                                                                </Grid>

                                                                <Grid xs={12} className="spacing_5">
                                                                </Grid>

                                                                <Grid item xs={12} spacing={3} className="border_black back_ground_misty_rose">
                                                                    <Stack>

                                                                        <div className="center">
                                                                            <b>Matching</b>
                                                                        </div>

                                                                        <div className="center">
                                                                            <Grid container xs={12} spacing={3}>
                                                                                <Grid xs={5} spacing={5}>
                                                                                    <Stack>
                                                                                        <div className="center back_ground_honey_dew border_green">Total: {settlementPrimaryState.matching_store_count?settlementPrimaryState.matching_store_count:0}</div>
                                                                                    </Stack>
                                                                                </Grid>

                                                                                <Grid xs={2} className="spacing_5">
                                                                                </Grid>

                                                                                <Grid xs={5} spacing={5}>
                                                                                    <Stack>
                                                                                        <div className="center back_ground_honey_dew border_green">Matched: {settlementPrimaryState.matching_matched_store_count?settlementPrimaryState.matching_matched_store_count:0}</div>
                                                                                    </Stack>
                                                                                </Grid>

                                                                                <Grid xs={12} className="spacing_5">
                                                                                </Grid>

                                                                                <Grid xs={5} spacing={5}>
                                                                                    <Stack>
                                                                                        <div className="center back_ground_honey_dew border_green">Mismatched: {settlementPrimaryState.matching_mismatched_store_count?settlementPrimaryState.matching_mismatched_store_count:0}</div>
                                                                                    </Stack>
                                                                                </Grid>

                                                                                <Grid xs={2} className="spacing_5">
                                                                                </Grid>

                                                                                <Grid xs={5} spacing={5}>
                                                                                    <Stack>
                                                                                        <div className="center back_ground_honey_dew border_green">Unmatched: {settlementPrimaryState.matching_unmatched_store_count?settlementPrimaryState.matching_unmatched_store_count:0}</div>
                                                                                    </Stack>
                                                                                </Grid>

                                                                                <Grid xs={12} className="spacing_5">
                                                                                </Grid>

                                                                                <Grid xs={12} className="spacing_5">
                                                                                </Grid>

                                                                                <Grid xs={12} className="spacing_5">
                                                                                </Grid>

                                                                                <Grid xs={12} className="spacing_6">
                                                                                </Grid>

                                                                            </Grid>
                                                                        </div>

                                                                    </Stack>
                                                                </Grid>

                                                                <Grid xs={12} className="spacing_5">
                                                                </Grid>

                                                                <Grid item xs={12} spacing={3} className="border_black back_ground_misty_rose">
                                                                    <Stack spacing='s'>

                                                                        <div className="center">
                                                                            <b>Egress</b>
                                                                        </div>

                                                                        <div className="center">
                                                                            <Grid container xs={12} spacing={1} className="center">

                                                                                <Grid xs={5} spacing={5}>
                                                                                    <Stack>
                                                                                        <div className="center back_ground_honey_dew border_green">Settlements: {settlementPrimaryState.egress_settlement_store_count?settlementPrimaryState.egress_settlement_store_count:0}</div>
                                                                                    </Stack>
                                                                                </Grid>
                                                                            </Grid>
                                                                        </div>

                                                                    </Stack>
                                                                </Grid>

                                                                <Grid xs={12} className="spacing_5">
                                                                </Grid>

                                                                <Grid item xs={12} spacing={3} className="border_black back_ground_misty_rose">
                                                                    <Stack spacing='s'>

                                                                        <div className="center">
                                                                            <b>Outbound Gateway</b>
                                                                        </div>

                                                                        <div className="center">
                                                                            <Grid container xs={12} spacing={1} className="center">

                                                                                <Grid xs={5} spacing={5}>
                                                                                    <Stack>
                                                                                        <div className="center back_ground_honey_dew border_green">Settlements: {settlementPrimaryState.outbound_gateway_settlement_store_count?settlementPrimaryState.outbound_gateway_settlement_store_count:0}</div>
                                                                                    </Stack>
                                                                                </Grid>
                                                                            </Grid>
                                                                        </div>

                                                                    </Stack>
                                                                </Grid>

                                                            </Grid>
                                                        </div>
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
                                            <div className="center">
                                                <Grid container xs={12} spacing={3}>
                                                    <Grid item xs={6} spacing={5} className="border_black">

                                                        <div className="center" >
                                                            <Grid container xs={12} spacing={2} className="spacing_5">

                                                                <Grid item xs={12} spacing={3}>
                                                                    <div className="center color_green">
                                                                        <b>Trade Matching</b>
                                                                    </div>
                                                                </Grid>

                                                                <Grid item xs={12} spacing={1} className="border_black center">

                                                                    <Grid item xs={4} spacing={1}>
                                                                        <div className="center">
                                                                            {renderDNSControl(tradeMatchingSecondaryControls.dns_arc_control_state?tradeMatchingSecondaryControls.dns_arc_control_state:"Off")}
                                                                        </div>
                                                                    </Grid>

                                                                    <Grid item xs={4} spacing={1}>
                                                                        <div className="center">
                                                                            {renderQueueControl(tradeMatchingSecondaryControls.queue_arc_control_state?tradeMatchingSecondaryControls.queue_arc_control_state:"Off")}
                                                                        </div>
                                                                    </Grid>

                                                                    <Grid item xs={4} spacing={1}>
                                                                        <div className="center">
                                                                            {renderAppControl(tradeMatchingSecondaryControls.app_arc_control_state?tradeMatchingSecondaryControls.app_arc_control_state:"Off")}
                                                                        </div>
                                                                    </Grid>

                                                                </Grid>

                                                                <Grid xs={12} className="spacing_5">
                                                                </Grid>

                                                                <Grid item xs={12} spacing={1} className="border_black back_ground_light_cyan">
                                                                    <Stack spacing='s'>

                                                                        <div className="center">
                                                                            <b>Inbound Gateway</b>
                                                                        </div>

                                                                        <div className="center">
                                                                            <Grid container xs={12} spacing={1}>
                                                                                <Grid xs={5} spacing={5}>
                                                                                    <Stack>
                                                                                        <div className="center back_ground_honey_dew border_green">Trades: {tradeMatchingSecondaryState.inbound_gateway_trade_store_count?tradeMatchingSecondaryState.inbound_gateway_trade_store_count:0}</div>
                                                                                    </Stack>
                                                                                </Grid>

                                                                                <Grid xs={2} className="spacing_5">
                                                                                </Grid>

                                                                                <Grid xs={5} spacing={5}>
                                                                                    <Stack>
                                                                                        <div className="center back_ground_honey_dew border_green">Settlements: {tradeMatchingSecondaryState.inbound_gateway_settlement_store_count?tradeMatchingSecondaryState.inbound_gateway_settlement_store_count:0}</div>
                                                                                    </Stack>
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

                                                                        <div className="center">
                                                                            <Grid container xs={12} spacing={1}>
                                                                                <Grid xs={5} spacing={5}>
                                                                                    <Stack>
                                                                                        <div className="center back_ground_honey_dew border_green">Trades: {tradeMatchingSecondaryState.ingestion_trade_store_count?tradeMatchingSecondaryState.ingestion_trade_store_count:0}</div>
                                                                                    </Stack>
                                                                                </Grid>

                                                                                <Grid xs={2} className="spacing_5">
                                                                                </Grid>

                                                                                <Grid xs={5} spacing={5}>
                                                                                    <Stack>
                                                                                        <div className="center back_ground_honey_dew border_green">Settlements: {tradeMatchingSecondaryState.ingestion_settlement_store_count?tradeMatchingSecondaryState.ingestion_settlement_store_count:0}</div>
                                                                                    </Stack>
                                                                                </Grid>
                                                                            </Grid>
                                                                        </div>

                                                                    </Stack>
                                                                </Grid>

                                                                <Grid xs={12} className="spacing_5">
                                                                </Grid>

                                                                <Grid item xs={12} spacing={3} className="border_black back_ground_light_cyan">
                                                                    <Stack >

                                                                        <div className="center">
                                                                            <b>Matching</b>
                                                                        </div>

                                                                        <div className="center">
                                                                            <Grid container xs={12} spacing={3}>
                                                                                <Grid xs={5} spacing={5}>
                                                                                    <Stack>
                                                                                        <div className="center back_ground_honey_dew border_green">Total: {tradeMatchingSecondaryState.matching_store_count?tradeMatchingSecondaryState.matching_store_count:0}</div>
                                                                                    </Stack>
                                                                                </Grid>

                                                                                <Grid xs={2} className="spacing_5">
                                                                                </Grid>

                                                                                <Grid xs={5} spacing={5}>
                                                                                    <Stack>
                                                                                        <div className="center back_ground_honey_dew border_green">Settled: {tradeMatchingSecondaryState.matching_settled_store_count?tradeMatchingSecondaryState.matching_settled_store_count:0}</div>
                                                                                    </Stack>
                                                                                </Grid>

                                                                                <Grid xs={12} className="spacing_5">
                                                                                </Grid>

                                                                                <Grid xs={5} spacing={5}>
                                                                                    <Stack>
                                                                                        <div className="center back_ground_honey_dew border_green">Matched: {tradeMatchingSecondaryState.matching_matched_store_count?tradeMatchingSecondaryState.matching_matched_store_count:0}</div>
                                                                                    </Stack>
                                                                                </Grid>

                                                                                <Grid xs={2} className="spacing_5">
                                                                                </Grid>

                                                                                <Grid xs={5} spacing={5}>
                                                                                    <Stack>
                                                                                        <div className="center back_ground_honey_dew border_green">Mismatched: {tradeMatchingSecondaryState.matching_mismatched_store_count?tradeMatchingSecondaryState.matching_mismatched_store_count:0}</div>
                                                                                    </Stack>
                                                                                </Grid>

                                                                                <Grid xs={12} className="spacing_5">
                                                                                </Grid>

                                                                                <Grid xs={5} spacing={5}>
                                                                                    <Stack>
                                                                                        <div className="center back_ground_honey_dew border_green">Unmatched: {tradeMatchingSecondaryState.matching_unmatched_store_count?tradeMatchingSecondaryState.matching_unmatched_store_count:0}</div>
                                                                                    </Stack>
                                                                                </Grid>

                                                                                <Grid xs={7} className="spacing_5">
                                                                                </Grid>

                                                                                <Grid xs={12} className="spacing_5">
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

                                                                        <div className="center">
                                                                            <Grid container xs={12} spacing={1}>
                                                                                <Grid xs={5} spacing={5}>
                                                                                    <Stack>
                                                                                        <div className="center back_ground_honey_dew border_green">Trades: {tradeMatchingSecondaryState.egress_trade_store_count?tradeMatchingSecondaryState.egress_trade_store_count:0}</div>
                                                                                    </Stack>
                                                                                </Grid>

                                                                                <Grid xs={2} className="spacing_5">
                                                                                </Grid>

                                                                                <Grid xs={5} spacing={5}>
                                                                                    <Stack>
                                                                                        <div className="center back_ground_honey_dew border_green">Settlements: {tradeMatchingSecondaryState.egress_settlement_store_count?tradeMatchingSecondaryState.egress_settlement_store_count:0}</div>
                                                                                    </Stack>
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

                                                                        <div className="center">
                                                                            <Grid container xs={12} spacing={1}>
                                                                                <Grid xs={5} spacing={5}>
                                                                                    <Stack>
                                                                                        <div className="center back_ground_honey_dew border_green">Trades: {tradeMatchingSecondaryState.outbound_gateway_trade_store_count?tradeMatchingSecondaryState.outbound_gateway_trade_store_count:0}</div>
                                                                                    </Stack>
                                                                                </Grid>

                                                                                <Grid xs={2} className="spacing_5">
                                                                                </Grid>

                                                                                <Grid xs={5} spacing={5}>
                                                                                    <Stack>
                                                                                        <div className="center back_ground_honey_dew border_green">Settlements: {tradeMatchingSecondaryState.outbound_gateway_settlement_store_count?tradeMatchingSecondaryState.outbound_gateway_settlement_store_count:0}</div>
                                                                                    </Stack>
                                                                                </Grid>
                                                                            </Grid>
                                                                        </div>

                                                                    </Stack>
                                                                </Grid>

                                                                <Grid xs={12} className="spacing_5">
                                                                </Grid>

                                                            </Grid>
                                                        </div>
                                                    </Grid>


                                                    <Grid item xs={6} spacing={5} className="border_black">

                                                        <div className="center" >
                                                            <Grid container xs={12} spacing={2} className="spacing_5">

                                                                <Grid item xs={12} spacing={3}>
                                                                    <div className="center color_green">
                                                                        <b>Settlement</b>
                                                                    </div>
                                                                </Grid>

                                                                <Grid item xs={12} spacing={1} className="border_black center">

                                                                    <Grid item xs={4} spacing={1}>
                                                                        <div className="center">
                                                                            {renderDNSControl(settlementSecondaryControls.dns_arc_control_state?settlementSecondaryControls.dns_arc_control_state:"Off")}
                                                                        </div>
                                                                    </Grid>

                                                                    <Grid item xs={4} spacing={1}>
                                                                        <div className="center">
                                                                            {renderQueueControl(settlementSecondaryControls.queue_arc_control_state?settlementSecondaryControls.queue_arc_control_state:"Off")}
                                                                        </div>
                                                                    </Grid>

                                                                    <Grid item xs={4} spacing={1}>
                                                                        <div className="center">
                                                                            {renderAppControl(settlementSecondaryControls.app_arc_control_state?settlementSecondaryControls.app_arc_control_state:"Off")}
                                                                        </div>
                                                                    </Grid>

                                                                </Grid>

                                                                <Grid xs={12} className="spacing_5">
                                                                </Grid>

                                                                <Grid item xs={12} spacing={1} className="border_black back_ground_misty_rose">
                                                                    <Stack spacing='s'>

                                                                        <div className="center">
                                                                            <b>Inbound Gateway</b>
                                                                        </div>

                                                                        <div className="center">
                                                                            <Grid container xs={12} spacing={1} className="center">

                                                                                <Grid xs={5} spacing={5}>
                                                                                    <Stack>
                                                                                        <div className="center back_ground_honey_dew border_green">Settlements: {settlementSecondaryState.inbound_gateway_settlement_store_count?settlementSecondaryState.inbound_gateway_settlement_store_count:0}</div>
                                                                                    </Stack>
                                                                                </Grid>
                                                                            </Grid>
                                                                        </div>

                                                                    </Stack>
                                                                </Grid>

                                                                <Grid xs={12} className="spacing_5">
                                                                </Grid>

                                                                <Grid item xs={12} spacing={3} className="border_black back_ground_misty_rose">
                                                                    <Stack spacing='s'>

                                                                        <div className="center">
                                                                            <b>Ingestion</b>
                                                                        </div>

                                                                        <div className="center">
                                                                            <Grid container xs={12} spacing={1} className="center">

                                                                                <Grid xs={5} spacing={5}>
                                                                                    <Stack>
                                                                                        <div className="center back_ground_honey_dew border_green">Settlements: {settlementSecondaryState.ingestion_settlement_store_count?settlementSecondaryState.ingestion_settlement_store_count:0}</div>
                                                                                    </Stack>
                                                                                </Grid>
                                                                            </Grid>
                                                                        </div>

                                                                    </Stack>
                                                                </Grid>

                                                                <Grid xs={12} className="spacing_5">
                                                                </Grid>

                                                                <Grid item xs={12} spacing={3} className="border_black back_ground_misty_rose">
                                                                    <Stack>

                                                                        <div className="center">
                                                                            <b>Matching</b>
                                                                        </div>

                                                                        <div className="center">
                                                                            <Grid container xs={12} spacing={3}>
                                                                                <Grid xs={5} spacing={5}>
                                                                                    <Stack>
                                                                                        <div className="center back_ground_honey_dew border_green">Total: {settlementSecondaryState.matching_store_count?settlementSecondaryState.matching_store_count:0}</div>
                                                                                    </Stack>
                                                                                </Grid>

                                                                                <Grid xs={2} className="spacing_5">
                                                                                </Grid>

                                                                                <Grid xs={5} spacing={5}>
                                                                                    <Stack>
                                                                                        <div className="center back_ground_honey_dew border_green">Matched: {settlementSecondaryState.matching_matched_store_count?settlementSecondaryState.matching_matched_store_count:0}</div>
                                                                                    </Stack>
                                                                                </Grid>

                                                                                <Grid xs={12} className="spacing_5">
                                                                                </Grid>

                                                                                <Grid xs={5} spacing={5}>
                                                                                    <Stack>
                                                                                        <div className="center back_ground_honey_dew border_green">Mismatched: {settlementSecondaryState.matching_mismatched_store_count?settlementSecondaryState.matching_mismatched_store_count:0}</div>
                                                                                    </Stack>
                                                                                </Grid>

                                                                                <Grid xs={2} className="spacing_5">
                                                                                </Grid>

                                                                                <Grid xs={5} spacing={5}>
                                                                                    <Stack>
                                                                                        <div className="center back_ground_honey_dew border_green">Unmatched: {settlementSecondaryState.matching_unmatched_store_count?settlementSecondaryState.matching_unmatched_store_count:0}</div>
                                                                                    </Stack>
                                                                                </Grid>

                                                                                <Grid xs={12} className="spacing_5">
                                                                                </Grid>

                                                                                <Grid xs={12} className="spacing_5">
                                                                                </Grid>

                                                                                <Grid xs={12} className="spacing_5">
                                                                                </Grid>

                                                                                <Grid xs={12} className="spacing_6">
                                                                                </Grid>
                                                                            </Grid>
                                                                        </div>

                                                                    </Stack>
                                                                </Grid>

                                                                <Grid xs={12} className="spacing_5">
                                                                </Grid>

                                                                <Grid item xs={12} spacing={3} className="border_black back_ground_misty_rose">
                                                                    <Stack spacing='s'>

                                                                        <div className="center">
                                                                            <b>Egress</b>
                                                                        </div>

                                                                        <div className="center">
                                                                            <Grid container xs={12} spacing={1} className="center">

                                                                                <Grid xs={5} spacing={5}>
                                                                                    <Stack>
                                                                                        <div className="center back_ground_honey_dew border_green">Settlements: {settlementSecondaryState.egress_settlement_store_count?settlementSecondaryState.egress_settlement_store_count:0}</div>
                                                                                    </Stack>
                                                                                </Grid>
                                                                            </Grid>
                                                                        </div>

                                                                    </Stack>
                                                                </Grid>

                                                                <Grid xs={12} className="spacing_5">
                                                                </Grid>

                                                                <Grid item xs={12} spacing={3} className="border_black back_ground_misty_rose">
                                                                    <Stack spacing='s'>

                                                                        <div className="center">
                                                                            <b>Outbound Gateway</b>
                                                                        </div>

                                                                        <div className="center">
                                                                            <Grid container xs={12} spacing={1} className="center">

                                                                                <Grid xs={5} spacing={5}>
                                                                                    <Stack>
                                                                                        <div className="center back_ground_honey_dew border_green">Settlements: {settlementSecondaryState.outbound_gateway_settlement_store_count?settlementSecondaryState.outbound_gateway_settlement_store_count:0}</div>
                                                                                    </Stack>
                                                                                </Grid>
                                                                            </Grid>
                                                                        </div>

                                                                    </Stack>
                                                                </Grid>

                                                            </Grid>
                                                        </div>
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

function get_app_state(apps: any, app_name: any, app_region: any) {
    for (var app of apps) {
        if ((app.app_name == app_name) && (app.app_region == app_region)) {
            // var app_state:IAppState = {
            //     app_name = app.app_name,
            //     app_region = app.app_region,
            //     inbound_gateway_trade_store_count = app.inbound_gateway_trade_store_count,
            //     inbound_gateway_settlement_store_count = app.inbound_gateway_settlement_store_count,
            //     ingestion_trade_store_count = app.ingestion_trade_store_count,
            //     ingestion_settlement_store_count = app.ingestion_settlement_store_count,
            //     matching_store_count = app.matching_store_count,
            //     matching_unmatched_store_count = app.matching_unmatched_store_count,
            //     matching_matched_store_count = app.matching_matched_store_count,
            //     matching_mismatched_store_count = app.matching_mismatched_store_count,
            //     egress_trade_store_count = app.egress_trade_store_count,
            //     egress_settlement_store_count = app.egress_settlement_store_count,
            //     outbound_gateway_trade_store_count = app.outbound_gateway_trade_store_count,
            //     outbound_gateway_settlement_store_count = app.outbound_gateway_settlement_store_count
            // };
            return app
        }
    }
    return {};
}

export default ApplicationState;

