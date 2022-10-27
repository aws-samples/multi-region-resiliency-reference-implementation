// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import React, {FunctionComponent, useEffect, useState} from 'react';
import {Container, Button} from "aws-northstar";
import Stack from "aws-northstar/layouts/Stack";
import '../home/styles.css';

import Grid from "aws-northstar/esm/layouts/Grid";
import {
  getAppReconStep
} from "../../data";
import Flashbar, {FlashbarMessage} from "aws-northstar/components/Flashbar";
import Alert from "aws-northstar/components/Alert";

import dns_on from "./dns_on.png";
import dns_off from "./dns_off.png";
import queue_on from "./queue_on.png";
import queue_off from "./queue_off.png";
import app_on from "./app_on.png";
import app_off from "./app_off.png";

const ApplicationRecon: FunctionComponent = () => {

  const [tmInboundIngressTrade, setTmInboundIngressTrade] = useState<string>("");
  const [tmInboundIngressSettlement, setTmInboundIngressSettlement] = useState<string>("");
  const [tmIngressCoreTrade, setTmIngressCoreTrade] = useState<string>("");
  const [tmIngressCoreSettlement, setTmIngressCoreSettlement] = useState<string>("");
  const [tmCoreEgressTrade, setTmCoreEgressTrade] = useState<string>("");
  const [tmCoreEgressSettlement, setTmCoreEgressSettlement] = useState<string>("");
  const [tmEgressOutboundTrade, setTmEgressOutboundTrade] = useState<string>("");
  const [tmEgressOutboundSettlement, setTmEgressOutboundSettlement] = useState<string>("");
  const [tmOutboundSmInboundSettlement, setTmOutboundSmInboundSettlement] = useState<string>("");

  const [smInboundIngressSettlement, setSmInboundIngressSettlement] = useState<string>("");
  const [smIngressCoreSettlement, setSmIngressCoreSettlement] = useState<string>("");
  const [smCoreEgressSettlement, setSmCoreEgressSettlement] = useState<string>("");
  const [smEgressOutboundSettlement, setSmEgressOutboundSettlement] = useState<string>("");
  const [smOutboundTmInboundSettlement, setSmOutboundTmInboundSettlement] = useState<string>("");

  // const [tradeMatchingPrimaryRecon, setTradeMatchingPrimaryRecon] = useState<IAppRecon>({});
  // const [tradeMatchingSecondaryRecon, setTradeMatchingSecondaryRecon] = useState<IAppRecon>({});
  // const [settlementPrimaryRecon, setSettlementPrimaryRecon] = useState<IAppRecon>({});
  // const [settlementSecondaryRecon, setSettlementSecondaryRecon] = useState<IAppRecon>({});
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

      try {
        getAppReconStep("TM-INBOUND-INGRESS-T").then(
            (result: string) => {
              setTmInboundIngressTrade(result)
            });
      } catch (err) {}

      try {
        getAppReconStep("TM-INBOUND-INGRESS-S").then(
            (result: string) => {
              setTmInboundIngressSettlement(result)
            });
      } catch (err) {}

      try {
        getAppReconStep("TM-INGRESS-CORE-T").then(
            (result: string) => {
              setTmIngressCoreTrade(result)
            });
      } catch (err) {}

      try {
        getAppReconStep("TM-INGRESS-CORE-S").then(
            (result: string) => {
              setTmIngressCoreSettlement(result)
            });
      } catch (err) {}

      try {
        getAppReconStep("TM-CORE-EGRESS-T").then(
            (result: string) => {
              setTmCoreEgressTrade(result)
            });
      } catch (err) {}

      try {
        getAppReconStep("TM-CORE-EGRESS-S").then(
            (result: string) => {
              setTmCoreEgressSettlement(result)
            });
      } catch (err) {}

      try {
        getAppReconStep("TM-EGRESS-OUTBOUND-T").then(
            (result: string) => {
              setTmEgressOutboundTrade(result)
            });
      } catch (err) {}

      try {
        getAppReconStep("TM-EGRESS-OUTBOUND-S").then(
            (result: string) => {
              setTmEgressOutboundSettlement(result)
            });
      } catch (err) {}

      try {
        getAppReconStep("TM-OUTBOUND-SM-INBOUND-S").then(
            (result: string) => {
              setTmOutboundSmInboundSettlement(result)
            });
      } catch (err) {}

      try {
        getAppReconStep("SM-INBOUND-INGRESS-S").then(
            (result: string) => {
              setSmInboundIngressSettlement(result)
            });
      } catch (err) {}

      try {
        getAppReconStep("SM-INGRESS-CORE-S").then(
            (result: string) => {
              setSmIngressCoreSettlement(result)
            });
      } catch (err) {}

      try {
        getAppReconStep("SM-CORE-EGRESS-S").then(
            (result: string) => {
              setSmCoreEgressSettlement(result)
            });
      } catch (err) {}

      try {
        getAppReconStep("SM-EGRESS-OUTBOUND-S").then(
            (result: string) => {
              setSmEgressOutboundSettlement(result)
            });
      } catch (err) {}

      try {
        getAppReconStep("SM-OUTBOUND-TM-INBOUND-S").then(
            (result: string) => {
              setSmOutboundTmInboundSettlement(result)
            });
      } catch (err) {}

      // let request1 = await getAppRecons("trade-matching").then(
      //     (result: IAppRecon[]) => {
      //       console.log("Received Result for getAppRecon for Trade Matching:" + JSON.stringify(result))
      //       setTradeMatchingPrimaryRecon(get_app_recon(result, "trade-matching", "us-east-1"));
      //       setTradeMatchingSecondaryRecon(get_app_recon(result, "trade-matching", "us-west-2"));
      //       setMessage("Received Reconciliation Result for Trade Matching")
      //     });
      //
      // let request2 = await getAppRecons("settlement").then(
      //     (result: IAppRecon[]) => {
      //       console.log("Received Result  for getAppRecon for Settlement" + JSON.stringify(result))
      //       setSettlementPrimaryRecon(get_app_recon(result, "settlement", "us-east-1"));
      //       setSettlementSecondaryRecon(get_app_recon(result, "settlement", "us-west-2"));
      //       setMessage("Received Reconciliation Result for Settlement")
      //     });

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

  useEffect( () => {

    console.log("useEffect Called")

    //getAllRequests().then(() => console.log("getAppRecon() completed."));
  }, []);

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
                        <b>Reconciliation</b>
                        &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={getAllRequests}>Refresh</Button>&nbsp;&nbsp;&nbsp;&nbsp;
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

                                  <Grid item xs={12} spacing={1} className="border_black back_ground_light_cyan">

                                    <div className="center">
                                      <b>Inbound Gateway</b>
                                    </div>

                                  </Grid>

                                  <Grid xs={12} className="spacing_5">
                                  </Grid>

                                  <Grid item xs={12} spacing={1} >

                                    <div className="center">
                                      <Grid container xs={12} spacing={1}>
                                        <Grid xs={5} spacing={5}>
                                          <Stack>
                                            <div className="center back_ground_honey_dew border_green">Trades: {tmInboundIngressTrade}</div>
                                          </Stack>
                                        </Grid>

                                        <Grid xs={2} className="spacing_5">
                                        </Grid>

                                        <Grid xs={5} spacing={5}>
                                          <Stack>
                                            <div className="center back_ground_honey_dew border_green">Settlements: {tmInboundIngressSettlement}</div>
                                          </Stack>
                                        </Grid>
                                      </Grid>
                                    </div>

                                  </Grid>

                                  <Grid xs={12} className="spacing_5">
                                  </Grid>

                                  <Grid item xs={12} spacing={1} className="border_black back_ground_light_cyan">

                                    <div className="center">
                                      <b>Ingestion</b>
                                    </div>

                                  </Grid>

                                  <Grid xs={12} className="spacing_5">
                                  </Grid>

                                  <Grid item xs={12} spacing={1}>
                                    <Stack spacing='s'>

                                      <div className="center">
                                        <Grid container xs={12} spacing={1}>
                                          <Grid xs={5} spacing={5}>
                                            <Stack>
                                              <div className="center back_ground_honey_dew border_green">Trades: {tmIngressCoreTrade}</div>
                                            </Stack>
                                          </Grid>

                                          <Grid xs={2} className="spacing_5">
                                          </Grid>

                                          <Grid xs={5} spacing={5}>
                                            <Stack>
                                              <div className="center back_ground_honey_dew border_green">Settlements: {tmIngressCoreSettlement}</div>
                                            </Stack>
                                          </Grid>
                                        </Grid>
                                      </div>

                                    </Stack>
                                  </Grid>

                                  <Grid xs={12} className="spacing_5">
                                  </Grid>

                                  <Grid item xs={12} spacing={1} className="border_black back_ground_light_cyan">
                                    <Stack>

                                      <div className="center">
                                        <b>Matching</b>
                                      </div>

                                    </Stack>
                                  </Grid>

                                  <Grid xs={12} className="spacing_5">
                                  </Grid>

                                  <Grid item xs={12} spacing={1} >

                                    <div className="center">
                                      <Grid container xs={12} spacing={1}>
                                        <Grid xs={5} spacing={5}>
                                          <Stack>
                                            <div className="center back_ground_honey_dew border_green">Trades: {tmCoreEgressTrade}</div>
                                          </Stack>
                                        </Grid>

                                        <Grid xs={2} className="spacing_5">
                                        </Grid>

                                        <Grid xs={5} spacing={5}>
                                          <Stack>
                                            <div className="center back_ground_honey_dew border_green">Settlements: {tmCoreEgressSettlement}</div>
                                          </Stack>
                                        </Grid>

                                      </Grid>
                                    </div>

                                  </Grid>

                                  <Grid xs={12} className="spacing_5">
                                  </Grid>

                                  <Grid item xs={12} spacing={1} className="border_black back_ground_light_cyan">

                                    <div className="center">
                                      <b>Egress</b>
                                    </div>

                                  </Grid>

                                  <Grid xs={12} className="spacing_5">
                                  </Grid>

                                  <Grid item xs={12} spacing={3}>

                                    <div className="center">
                                      <Grid container xs={12} spacing={1}>
                                        <Grid xs={5} spacing={5}>
                                          <Stack>
                                            <div className="center back_ground_honey_dew border_green">Trades: {tmEgressOutboundTrade}</div>
                                          </Stack>
                                        </Grid>

                                        <Grid xs={2} className="spacing_5">
                                        </Grid>

                                        <Grid xs={5} spacing={5}>
                                          <Stack>
                                            <div className="center back_ground_honey_dew border_green">Settlements: {tmEgressOutboundSettlement}</div>
                                          </Stack>
                                        </Grid>
                                      </Grid>
                                    </div>

                                  </Grid>

                                  <Grid xs={12} className="spacing_5">
                                  </Grid>

                                  <Grid item xs={12} spacing={1} className="border_black back_ground_light_cyan">

                                    <div className="center">
                                      <b>Outbound Gateway</b>
                                    </div>

                                  </Grid>

                                  <Grid xs={12} className="spacing_5">
                                  </Grid>

                                  <Grid item xs={12} spacing={3}>

                                    <div className="center">
                                      <Grid container xs={12} spacing={1}>
                                        <Grid xs={5} spacing={5}>
                                          <Stack>
                                            <div className="center back_ground_honey_dew border_green">Trades: 0</div>
                                          </Stack>
                                        </Grid>

                                        <Grid xs={2} className="spacing_5">
                                        </Grid>

                                        <Grid xs={5} spacing={5}>
                                          <Stack>
                                            <div className="center back_ground_honey_dew border_green">Settlements: {tmOutboundSmInboundSettlement}</div>
                                          </Stack>
                                        </Grid>
                                      </Grid>
                                    </div>

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

                                  <Grid item xs={12} spacing={1} className="border_black back_ground_misty_rose">

                                    <div className="center">
                                      <b>Inbound Gateway</b>
                                    </div>

                                  </Grid>

                                  <Grid xs={12} className="spacing_5">
                                  </Grid>

                                  <Grid item xs={12} spacing={1}>

                                      <div className="center">
                                        <Grid container xs={12} spacing={1} className="center">

                                          <Grid xs={5} spacing={5}>
                                            <Stack>
                                              <div className="center back_ground_honey_dew border_green">Settlements: {smInboundIngressSettlement}</div>
                                            </Stack>
                                          </Grid>
                                        </Grid>
                                      </div>

                                  </Grid>

                                  <Grid xs={12} className="spacing_5">
                                  </Grid>

                                  <Grid item xs={12} spacing={1} className="border_black back_ground_misty_rose">

                                    <div className="center">
                                      <b>Ingestion</b>
                                    </div>

                                  </Grid>

                                  <Grid xs={12} className="spacing_5">
                                  </Grid>

                                  <Grid item xs={12} spacing={1}>

                                    <div className="center">
                                      <Grid container xs={12} spacing={1} className="center">

                                        <Grid xs={5} spacing={5}>
                                          <Stack>
                                            <div className="center back_ground_honey_dew border_green">Settlements: {smIngressCoreSettlement}</div>
                                          </Stack>
                                        </Grid>
                                      </Grid>
                                    </div>

                                  </Grid>

                                  <Grid xs={12} className="spacing_5">
                                  </Grid>

                                  <Grid item xs={12} spacing={1} className="border_black back_ground_misty_rose">

                                      <div className="center">
                                        <b>Matching</b>
                                      </div>

                                  </Grid>

                                  <Grid xs={12} className="spacing_5">
                                  </Grid>

                                  <Grid item xs={12} spacing={1}>

                                      <div className="center">
                                        <Grid container xs={12} spacing={1} className="center">
                                          <Grid xs={5} spacing={5}>
                                            <Stack>
                                              <div className="center back_ground_honey_dew border_green">Settlements: {smCoreEgressSettlement}</div>
                                            </Stack>
                                          </Grid>

                                        </Grid>
                                      </div>

                                  </Grid>

                                  <Grid xs={12} className="spacing_5">
                                  </Grid>

                                  <Grid item xs={12} spacing={1} className="border_black back_ground_misty_rose">

                                    <div className="center">
                                      <b>Egress</b>
                                    </div>

                                  </Grid>

                                  <Grid xs={12} className="spacing_5">
                                  </Grid>

                                  <Grid item xs={12} spacing={1}>

                                    <div className="center">
                                      <Grid container xs={12} spacing={1} className="center">

                                        <Grid xs={5} spacing={5}>
                                          <Stack>
                                            <div className="center back_ground_honey_dew border_green">Settlements: {smEgressOutboundSettlement}</div>
                                          </Stack>
                                        </Grid>
                                      </Grid>
                                    </div>

                                  </Grid>

                                  <Grid xs={12} className="spacing_5">
                                  </Grid>

                                  <Grid item xs={12} spacing={3} className="border_black back_ground_misty_rose">

                                    <div className="center">
                                      <b>Outbound Gateway</b>
                                    </div>

                                  </Grid>

                                  <Grid xs={12} className="spacing_5">
                                  </Grid>

                                  <Grid item xs={12} spacing={3}>

                                    <div className="center">
                                      <Grid container xs={12} spacing={1} className="center">

                                        <Grid xs={5} spacing={5}>
                                          <Stack>
                                            <div className="center back_ground_honey_dew border_green">Settlements: {smOutboundTmInboundSettlement}</div>
                                          </Stack>
                                        </Grid>
                                      </Grid>
                                    </div>

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

                                  <Grid item xs={12} spacing={1}>
                                    <div className="center color_green">
                                      <b>Trade Matching</b>
                                    </div>
                                  </Grid>

                                  <Grid item xs={12} spacing={1} className="border_black back_ground_light_cyan">

                                    <div className="center">
                                      <b>Inbound Gateway</b>
                                    </div>

                                  </Grid>

                                  <Grid xs={12} className="spacing_5">
                                  </Grid>

                                  <Grid item xs={12} spacing={1} >

                                    <div className="center">
                                      <Grid container xs={12} spacing={1}>
                                        <Grid xs={5} spacing={5}>
                                          <Stack>
                                            <div className="center back_ground_honey_dew border_green">Trades: {tmInboundIngressTrade}</div>
                                          </Stack>
                                        </Grid>

                                        <Grid xs={2} className="spacing_5">
                                        </Grid>

                                        <Grid xs={5} spacing={5}>
                                          <Stack>
                                            <div className="center back_ground_honey_dew border_green">Settlements: {tmInboundIngressSettlement}</div>
                                          </Stack>
                                        </Grid>
                                      </Grid>
                                    </div>

                                  </Grid>

                                  <Grid xs={12} className="spacing_5">
                                  </Grid>

                                  <Grid item xs={12} spacing={1} className="border_black back_ground_light_cyan">

                                    <div className="center">
                                      <b>Ingestion</b>
                                    </div>

                                  </Grid>

                                  <Grid xs={12} className="spacing_5">
                                  </Grid>

                                  <Grid item xs={12} spacing={1}>
                                    <Stack spacing='s'>

                                      <div className="center">
                                        <Grid container xs={12} spacing={1}>
                                          <Grid xs={5} spacing={5}>
                                            <Stack>
                                              <div className="center back_ground_honey_dew border_green">Trades: {tmIngressCoreTrade}</div>
                                            </Stack>
                                          </Grid>

                                          <Grid xs={2} className="spacing_5">
                                          </Grid>

                                          <Grid xs={5} spacing={5}>
                                            <Stack>
                                              <div className="center back_ground_honey_dew border_green">Settlements: {tmIngressCoreSettlement}</div>
                                            </Stack>
                                          </Grid>
                                        </Grid>
                                      </div>

                                    </Stack>
                                  </Grid>

                                  <Grid xs={12} className="spacing_5">
                                  </Grid>

                                  <Grid item xs={12} spacing={1} className="border_black back_ground_light_cyan">
                                    <Stack>

                                      <div className="center">
                                        <b>Matching</b>
                                      </div>

                                    </Stack>
                                  </Grid>

                                  <Grid xs={12} className="spacing_5">
                                  </Grid>

                                  <Grid item xs={12} spacing={1} >

                                    <div className="center">
                                      <Grid container xs={12} spacing={1}>
                                        <Grid xs={5} spacing={5}>
                                          <Stack>
                                            <div className="center back_ground_honey_dew border_green">Trades: {tmCoreEgressTrade}</div>
                                          </Stack>
                                        </Grid>

                                        <Grid xs={2} className="spacing_5">
                                        </Grid>

                                        <Grid xs={5} spacing={5}>
                                          <Stack>
                                            <div className="center back_ground_honey_dew border_green">Settlements: {tmCoreEgressSettlement}</div>
                                          </Stack>
                                        </Grid>

                                      </Grid>
                                    </div>

                                  </Grid>

                                  <Grid xs={12} className="spacing_5">
                                  </Grid>

                                  <Grid item xs={12} spacing={1} className="border_black back_ground_light_cyan">

                                    <div className="center">
                                      <b>Egress</b>
                                    </div>

                                  </Grid>

                                  <Grid xs={12} className="spacing_5">
                                  </Grid>

                                  <Grid item xs={12} spacing={3}>

                                    <div className="center">
                                      <Grid container xs={12} spacing={1}>
                                        <Grid xs={5} spacing={5}>
                                          <Stack>
                                            <div className="center back_ground_honey_dew border_green">Trades: {tmEgressOutboundTrade}</div>
                                          </Stack>
                                        </Grid>

                                        <Grid xs={2} className="spacing_5">
                                        </Grid>

                                        <Grid xs={5} spacing={5}>
                                          <Stack>
                                            <div className="center back_ground_honey_dew border_green">Settlements: {tmEgressOutboundSettlement}</div>
                                          </Stack>
                                        </Grid>
                                      </Grid>
                                    </div>

                                  </Grid>

                                  <Grid xs={12} className="spacing_5">
                                  </Grid>

                                  <Grid item xs={12} spacing={1} className="border_black back_ground_light_cyan">

                                    <div className="center">
                                      <b>Outbound Gateway</b>
                                    </div>

                                  </Grid>

                                  <Grid xs={12} className="spacing_5">
                                  </Grid>

                                  <Grid item xs={12} spacing={3}>

                                    <div className="center">
                                      <Grid container xs={12} spacing={1}>
                                        <Grid xs={5} spacing={5}>
                                          <Stack>
                                            <div className="center back_ground_honey_dew border_green">Trades: 0</div>
                                          </Stack>
                                        </Grid>

                                        <Grid xs={2} className="spacing_5">
                                        </Grid>

                                        <Grid xs={5} spacing={5}>
                                          <Stack>
                                            <div className="center back_ground_honey_dew border_green">Settlements: {tmOutboundSmInboundSettlement}</div>
                                          </Stack>
                                        </Grid>
                                      </Grid>
                                    </div>

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

                                  <Grid item xs={12} spacing={1} className="border_black back_ground_misty_rose">

                                    <div className="center">
                                      <b>Inbound Gateway</b>
                                    </div>

                                  </Grid>

                                  <Grid xs={12} className="spacing_5">
                                  </Grid>

                                  <Grid item xs={12} spacing={1}>

                                    <div className="center">
                                      <Grid container xs={12} spacing={1} className="center">

                                        <Grid xs={5} spacing={5}>
                                          <Stack>
                                            <div className="center back_ground_honey_dew border_green">Settlements: {smInboundIngressSettlement}</div>
                                          </Stack>
                                        </Grid>
                                      </Grid>
                                    </div>

                                  </Grid>

                                  <Grid xs={12} className="spacing_5">
                                  </Grid>

                                  <Grid item xs={12} spacing={1} className="border_black back_ground_misty_rose">

                                    <div className="center">
                                      <b>Ingestion</b>
                                    </div>

                                  </Grid>

                                  <Grid xs={12} className="spacing_5">
                                  </Grid>

                                  <Grid item xs={12} spacing={1}>

                                    <div className="center">
                                      <Grid container xs={12} spacing={1} className="center">

                                        <Grid xs={5} spacing={5}>
                                          <Stack>
                                            <div className="center back_ground_honey_dew border_green">Settlements: {smIngressCoreSettlement}</div>
                                          </Stack>
                                        </Grid>
                                      </Grid>
                                    </div>

                                  </Grid>

                                  <Grid xs={12} className="spacing_5">
                                  </Grid>

                                  <Grid item xs={12} spacing={1} className="border_black back_ground_misty_rose">

                                    <div className="center">
                                      <b>Matching</b>
                                    </div>

                                  </Grid>

                                  <Grid xs={12} className="spacing_5">
                                  </Grid>

                                  <Grid item xs={12} spacing={1}>

                                    <div className="center">
                                      <Grid container xs={12} spacing={1} className="center">
                                        <Grid xs={5} spacing={5}>
                                          <Stack>
                                            <div className="center back_ground_honey_dew border_green">Settlements: {smCoreEgressSettlement}</div>
                                          </Stack>
                                        </Grid>

                                      </Grid>
                                    </div>

                                  </Grid>

                                  <Grid xs={12} className="spacing_5">
                                  </Grid>

                                  <Grid item xs={12} spacing={1} className="border_black back_ground_misty_rose">

                                    <div className="center">
                                      <b>Egress</b>
                                    </div>

                                  </Grid>

                                  <Grid xs={12} className="spacing_5">
                                  </Grid>

                                  <Grid item xs={12} spacing={1}>

                                    <div className="center">
                                      <Grid container xs={12} spacing={1} className="center">

                                        <Grid xs={5} spacing={5}>
                                          <Stack>
                                            <div className="center back_ground_honey_dew border_green">Settlements: {smEgressOutboundSettlement}</div>
                                          </Stack>
                                        </Grid>
                                      </Grid>
                                    </div>

                                  </Grid>

                                  <Grid xs={12} className="spacing_5">
                                  </Grid>

                                  <Grid item xs={12} spacing={3} className="border_black back_ground_misty_rose">

                                    <div className="center">
                                      <b>Outbound Gateway</b>
                                    </div>

                                  </Grid>

                                  <Grid xs={12} className="spacing_5">
                                  </Grid>

                                  <Grid item xs={12} spacing={3}>

                                    <div className="center">
                                      <Grid container xs={12} spacing={1} className="center">

                                        <Grid xs={5} spacing={5}>
                                          <Stack>
                                            <div className="center back_ground_honey_dew border_green">Settlements: {smOutboundTmInboundSettlement}</div>
                                          </Stack>
                                        </Grid>
                                      </Grid>
                                    </div>

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

function get_app_recon(recons: any, app_name: any, app_region: any) {
  for (var recon of recons) {
    if ((recon.app_name == app_name) && (recon.app_region == app_region)) {
      // var app_state:IAppRecon = {
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
      return recon
    }
  }
  return {};
}

export default ApplicationRecon;

