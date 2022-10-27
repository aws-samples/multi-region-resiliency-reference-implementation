// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import React, {ComponentType, FunctionComponent} from 'react';
import {BrowserRouter as Router, Route, useHistory} from 'react-router-dom';
import NorthStarThemeProvider from 'aws-northstar/components/NorthStarThemeProvider';
import AppLayout from "./components/AppLayout";
import {HomepageContent} from "./components/home/HomePageContent";
import ApplicationState from "./components/State/ApplicationState";
import ApplicationAdmin from "./components/State/ApplicationAdmin";
import ApplicationRecon from "./components/State/ApplicationRecon";
import TMApplicationMonitor from "./components/State/TMApplicationMonitor";
import SMApplicationMonitor from "./components/State/SMApplicationMonitor";
import AcceptanceTesting from "./components/State/AcceptanceTesting";
import IntegrationTesting from "./components/State/IntegrationTesting";
import ExecutionDashboard from "./components/State/ExecutionDashboard";
import ExecutionView from "./components/State/ExecutionView";
import ChaosTesting from "./components/State/ChaosTesting";

const withLayout = (Component: ComponentType): FunctionComponent => (props) => (
    <AppLayout>
      <Component {...props} />
    </AppLayout>);

const App = () => {
  const history = useHistory();

  return (
      <NorthStarThemeProvider>
        <Router>
          <Route exact path='/' component={withLayout(HomepageContent)}/>
          <Route exact path='/app-State' component={withLayout(ApplicationState)}/>
          <Route exact path='/Runbook-Executions' component={withLayout(ExecutionDashboard)}/>
          <Route exact path='/Runbook-Execution-Detail' component={withLayout(ExecutionView)}/>
          <Route exact path='/app-Admin' component={withLayout(ApplicationAdmin)}/>
          <Route exact path='/app-Recon' component={withLayout(ApplicationRecon)}/>
          <Route exact path='/TM-App-Monitor' component={withLayout(TMApplicationMonitor)}/>
          <Route exact path='/SM-App-Monitor' component={withLayout(SMApplicationMonitor)}/>
          <Route exact path='/Acceptance-Testing' component={withLayout(AcceptanceTesting)}/>
          <Route exact path='/Integration-Testing' component={withLayout(IntegrationTesting)}/>
          <Route exact path='/Chaos-Testing' component={withLayout(ChaosTesting)}/>
        </Router>
      </NorthStarThemeProvider>
  );
}

export default App;
