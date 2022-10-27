// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import React, {FunctionComponent, useEffect, useState} from 'react';
import {ColumnLayout, Column, Container, Box, Button} from "aws-northstar";
import Stack from "aws-northstar/layouts/Stack";
import './styles.css';
import approtation from "./approtation.png";
import {useOktaAuth} from "@okta/okta-react";
import {IUserInfo} from "../../interfaces";
import {useDispatch} from "react-redux";

import {useHistory} from "react-router-dom";

const Homepage: FunctionComponent = () => {
    return <Stack>
        <HomepageContent/>
    </Stack>
}

// The content in the main content area of the App layout
export function HomepageContent() {

    // const [request, setRequest] = useState(false);
    // const [review, setReview] = useState(false);
    // const [audit, setAudit] = useState(false);
    //
    // const {oktaAuth} = useOktaAuth();
    //
    // const dispatch = useDispatch();
    const history = useHistory();
    //
    // function createAccountMap(groups: string[]) {
    //     let accountMap = new Map();
    //     for (var group of groups) {
    //         if (group === 'aws-temp#Reviewer') {
    //             setReview(true);
    //             ApiHandler.reviewer = true;
    //         } else if (group === 'aws-temp#Auditor') {
    //             setAudit(true)
    //             ApiHandler.auditor = true;
    //         } else {
    //             let words = group.split('#');
    //             let account = words[2]
    //             let role = words[1]
    //             if (accountMap.has(account)) {
    //                 accountMap.get(account).push(role)
    //             } else {
    //                 let roles: Array<string> = [];
    //                 roles.push(role);
    //                 accountMap.set(account, roles)
    //             }
    //             setRequest(true);
    //             ApiHandler.requester = true;
    //         }
    //     }
    //     return accountMap;
    // }
    //
    // const login = async () => {
    //     if (oktaAuth.isLoginRedirect()) {
    //         await oktaAuth.handleLoginRedirect();
    //     } else if (!await oktaAuth.isAuthenticated()) {
    //         // Start the browser based oidc flow, then parse tokens from the redirect callback url
    //         oktaAuth.signInWithRedirect();
    //     }
    // }
    //
    // const secinfo = async () => {
    //
    //     const userInfo: IUserInfo = {
    //         token: "",
    //         user: "",
    //
    //         requester: false,
    //         reviewer: false,
    //         auditor: false,
    //
    //         accountMap: new Map([])
    //     }
    //
    //     const claims = await oktaAuth.getUser();
    //     userInfo.user = claims.email ? claims.email : "";
    //     userInfo.accountMap = createAccountMap(claims.groups);
    //
    //     const tokenManager = oktaAuth.tokenManager;
    //     const accessToken = await tokenManager.get('accessToken');
    //     const idToken = await tokenManager.get('idToken');
    //     if ("accessToken" in accessToken && "idToken" in idToken) {
    //         const authorization_value1 = 'Bearer '.concat(accessToken.accessToken ? accessToken.accessToken : "");
    //         const authorization_value2 = authorization_value1.concat(' ');
    //         const authorization_value3 = authorization_value2.concat(idToken.idToken ? idToken.idToken : "");
    //
    //         userInfo.token = authorization_value3;
    //     }
    //
    //     userInfo.requester = request;
    //     userInfo.reviewer = review;
    //     userInfo.auditor = audit;
    //     dispatch(storeUserInfoAction(userInfo));
    // }

    const onOpenClick = () => {
        history.push(getLink());
    }

    const getLink = () => {

        return "/app-state";
    }

    return (
        <div>
            <div className="awsui-grid awsui-util-p-s">
                <div className="awsui-util-pt-xxl awsui-row">
                    <div
                        className="custom-home-main-content-area col-xxs-10 offset-xxs-1 col-s-6 col-l-5 offset-l-2 col-xl-6">

                        <Container headingVariant='h4'
                                   title="Availability & Resiliency">
                            <div className="awsui-util-container back_ground_white text_black border_black">
                                <h1 className="awsui-text-large">
                                    <strong>&nbsp;&nbsp;App Rotation</strong>
                                </h1>
                                <div><strong>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Rotate Applications to Different Region</strong></div>
                                <div>
                                    <br/>
                                </div>
                                <Box>
                                    &nbsp;&nbsp;&nbsp;&nbsp;<Button variant="primary" onClick={onOpenClick}>Open
                                    dashboard</Button>&nbsp;&nbsp;&nbsp;&nbsp;
                                </Box>
                                <div>
                                    <br/>
                                </div>
                                <div className="awsui-util-container-header">
                                    {/*<h2>How it works</h2>*/}
                                </div>
                            </div>
                        </Container>

                        <Container headingVariant='h4'
                                   title="Architecture">
                            <div className="awsui-util-container back_ground_white text_black">
                                <div className="awsui-util-container-header">
                                    {/*<h2>How it works</h2>*/}
                                </div>
                                <img src={approtation} width="60%" height="50%" alt="App Rotation"/>
                            </div>
                        </Container>

                        <Container headingVariant='h4'
                                   title="How it works">
                            <div className="awsui-util-container">

                                <div>
                                    <ColumnLayout>

                                        <div data-awsui-column-layout-root={true}>
                                            <ul>
                                                <li>
                                                    Customer has identified two inter-dependent applications <b>Trade Matching</b> and <b>Settlement</b> to explore resiliency requirements and design resilient architecture.
                                                </li>
                                                <li>
                                                    Customer has tiering system for their clearing and settlement applications ranging from critical (Tier 0/1/2) to less critical (Tier 3/4//5). The two apps selected are Tier 1.
                                                </li>
                                                <li>
                                                    The trade matching and settlement applications should meet Customer Tier 1 RPO/RTO requirement. RPO=30s & RTO=2hrs.
                                                </li>
                                                <li>
                                                    Investment Managers and Brokers submit trade messages through different channels (Queue, SFTP, Stream, HTTP) into the Trade Matching system. Trade Matching system performs matching function, sends acknowledgement to the client and sends settlement instruction to the Settlement system.
                                                </li>
                                                <li>
                                                    Clearing Agents submit settlement instructions to the Settlement system and Trade Matching system sends Settlement messages to the Settlement system. Settlement system performs matching function and sends matching status back to Trade Matching system and Clearing Agent.
                                                </li>
                                                <li>
                                                    Trade Matching system and Settlement system runs actively in one region and stand-by in another region. They can be active in the same region or a different region. E.g. Trade Matching system is active in us-east-1 and Settlement system is active in us-west-2. Customer operates in us-east-1 and us-west-2.
                                                </li>
                                                <li>
                                                    Both systems are rotatable between regions. They can be run in a given region for an extended period of time, and can be rotated to another region independently. Each of the the system is a separate “consistency group”, which means the subcomponents are expected to run in the same region.
                                                </li>
                                                <li>
                                                    Two scenarios need to be accounted for 1) App Rotation – Planned Failover  and 2) Disaster Recovery – Unplanned Failover, for an extended period.
                                                </li>
                                                <li>
                                                    Performance of the system is not critical at this point, but expected to process thousands of  messages per second
                                                </li>
                                            </ul>
                                        </div>

                                    </ColumnLayout>
                                </div>
                            </div>
                        </Container>

                    </div>

                </div>
            </div>
        </div>
    );
}


export default Homepage;

