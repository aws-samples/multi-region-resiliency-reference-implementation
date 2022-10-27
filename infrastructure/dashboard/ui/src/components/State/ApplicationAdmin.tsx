// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import React, {FunctionComponent, useEffect, useState} from 'react';
import {Container, Button} from "aws-northstar";
import Stack from "aws-northstar/layouts/Stack";
import '../home/styles.css';
import {IAppControls, IAppState} from "../../interfaces";

import {useHistory} from "react-router-dom";
import Grid from "aws-northstar/esm/layouts/Grid";
import {
  executeRunbook,
  getAppControls,
  getAppState,
  getAppStates,
  updateArcControl,
  cleanDatabases,
  startApplication, stopApplications
} from "../../data";
import Flashbar, {FlashbarMessage} from "aws-northstar/components/Flashbar";
import Alert from "aws-northstar/components/Alert";

import dns_on from "./dns_on.png";
import dns_off from "./dns_off.png";
import queue_on from "./queue_on.png";
import queue_off from "./queue_off.png";
import app_on from "./app_on.png";
import app_off from "./app_off.png";
import TEA from "../home/TEA.png";

const ApplicationAdmin: FunctionComponent = () => {

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

      let request1 = await getAppStates("trade-matching").then(
          (result: IAppState[]) => {
            console.log("Received Result for getAppState for Trade Matching:" + JSON.stringify(result))
            setTradeMatchingPrimaryState(get_app_state(result, "trade-matching", "us-east-1"));
            setTradeMatchingSecondaryState(get_app_state(result, "trade-matching", "us-west-2"));
          });

      let request2 = await getAppStates("settlement").then(
          (result: IAppState[]) => {
            console.log("Received Result  for getAppState for Settlement" + JSON.stringify(result))
            setSettlementPrimaryState(get_app_state(result, "settlement", "us-east-1"));
            setSettlementSecondaryState(get_app_state(result, "settlement", "us-west-2"));
          });

      let request3 = await getAppControls("trade-matching", "us-east-1").then(
          (result: IAppControls) => {
            console.log("Received Result for getAppControls for Trade Matching for Primary:" + JSON.stringify(result))
            setTradeMatchingPrimaryControls(result);
          });

      let request4 = await getAppControls("trade-matching", "us-west-2").then(
          (result: IAppControls) => {
            console.log("Received Result for getAppControls for Trade Matching for Secondary:" + JSON.stringify(result))
            setTradeMatchingSecondaryControls(result);
          });

      let request5 = await getAppControls("settlement", "us-east-1").then(
          (result: IAppControls) => {
            console.log("Received Result for getAppControls for Settlement for Primary:" + JSON.stringify(result))
            setSettlementPrimaryControls(result);
          });

      let request6 = await getAppControls("settlement", "us-west-2").then(
          (result: IAppControls) => {
            console.log("Received Result for getAppControls for Settlement for Secondary:" + JSON.stringify(result))
            setSettlementSecondaryControls(result);
          });

      await Promise.resolve();

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

    // getAllRequests().then(() => console.log("getAppState() completed."));
    // const interval = setInterval(() => {
    //     getAllRequests().then(() => console.log("getAppState() completed."));
    // }, 1000);
    // return () => clearInterval(interval);

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

  const startTradeMatchingPrimary = async () => {
    setMessage("Initiated Start Trade Matching Application in Primary")
    let request = await startApplication("trade", "us-east-1").then(
        (result: any) => {
          console.log("Received Result :" + JSON.stringify(result))
        });
  }

  const startTradeMatchingSecondary = async () => {
    setMessage("Initiated Start Trade Matching Application in Secondary")
    let request = await startApplication("trade", "us-west-2").then(
        (result: any) => {
          console.log("Received Result :" + JSON.stringify(result))
        });
  }

  const startSettlementPrimary = async () => {
    setMessage("Initiated Start Settlement Application in Primary")
    let request = await startApplication("settlement", "us-east-1").then(
        (result: any) => {
          console.log("Received Result :" + JSON.stringify(result))
        });
  }

  const startSettlementSecondary = async () => {
    setMessage("Initiated Start Settlement Application in Secondary")
    let request = await startApplication("settlement", "us-west-2").then(
        (result: any) => {
          console.log("Received Result :" + JSON.stringify(result))
        });
  }

  const stopApplicationsPrimary = async () => {
    setMessage("Initiated Stop Applications in Primary")
    let request = await stopApplications("us-east-1").then(
        (result: any) => {
          console.log("Received Result :" + JSON.stringify(result))
        });
  }

  const stopApplicationsSecondary = async () => {
    setMessage("Initiated Stop Applications in Secondary")
    let request = await stopApplications("us-west-2").then(
        (result: any) => {
          console.log("Received Result :" + JSON.stringify(result))
        });
  }

  const clearDatabases = async () => {
    setMessage("Initiated Clean Databases")
    let request = await cleanDatabases().then(
        (result: any) => {
          console.log("Received Result :" + JSON.stringify(result))
        });
  }

  return (
      <Stack>
        <div>
          <div className="awsui-grid awsui-util-p-s ">
            <div className="awsui-util-pt-xxl awsui-row">
              <div className="custom-home-main-content-area col-xxs-10 offset-xxs-1 col-s-6 col-l-5 offset-l-2 col-xl-6">

                <Container headingVariant='h4'>
                  <div className="center border_black">
                    <Grid container  spacing={3} className="spacing_10 center">
                      <Grid xs={12} spacing={5} >
                        <Stack spacing='s'>

                          <Grid item xs={12} className="spacing_5">
                          </Grid>

                          <div className="center">
                            <Grid container  spacing={5} >
                              <Grid item xs={4} spacing={10} className="right spacing_10">
                                <b>Both Applications</b>
                              </Grid>
                              <Grid item xs={8} spacing={5}>
                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={stopApplicationsPrimary}>Stop Primary</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={stopApplicationsSecondary}>Stop Secondary</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={clearDatabases}>Clear Databases</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                              </Grid>
                            </Grid>
                          </div>

                          <Grid item xs={12} className="spacing_5">
                          </Grid>

                          <div className="center">
                            <Grid container spacing={5} >
                              <Grid item xs={4} spacing={10} className="right spacing_10">
                                <b>Trade Matching</b>
                              </Grid>
                              <Grid item xs={8} spacing={5}>
                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={startTradeMatchingPrimary}>Start Primary</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={startTradeMatchingSecondary}>Start Secondary</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                              </Grid>
                            </Grid>
                          </div>


                          <Grid item xs={12} className="spacing_5">
                          </Grid>

                          <div className="center">
                            <Grid container  spacing={5} >
                              <Grid item xs={4} spacing={10} className="right spacing_10">
                                <b>Settlement</b>
                              </Grid>
                              <Grid item xs={8} spacing={5}>
                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={startSettlementPrimary}>Start Primary</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={startSettlementSecondary}>Start Secondary</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                              </Grid>
                            </Grid>
                          </div>

                          <Grid item xs={12} className="spacing_5">
                          </Grid>

                        </Stack>
                      </Grid>
                    </Grid>
                  </div>
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

export default ApplicationAdmin;

