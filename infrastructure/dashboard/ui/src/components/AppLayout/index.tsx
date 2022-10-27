// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import React, {FunctionComponent, useMemo} from 'react';
import AppLayoutBase from 'aws-northstar/layouts/AppLayout';
import HeaderBase from 'aws-northstar/components/Header';
import SideNavigationBase, { SideNavigationItem, SideNavigationItemType } from 'aws-northstar/components/SideNavigation';
import BreadcrumbGroup from 'aws-northstar/components/BreadcrumbGroup';


import ApiHandler from "../../common/api";

const AppLayout: FunctionComponent = ( {children} ) => {

  const Header = useMemo(() => (
       <HeaderBase title="App Rotation"  />
  ), []);
  const Breadcrumbs = useMemo(() => <BreadcrumbGroup rootPath=""/>, []);;
  const SideNavigation = useMemo(() => {

    return <SideNavigationBase
    header={{text: 'Dashboard', href: '/'}}
    items={
      getNavigation()
    }
    />
  }, []);

  function getNavigation() {
    let navs: Array<SideNavigationItem> = [];

    let nav1:SideNavigationItem = {text: 'Application State', type: SideNavigationItemType.LINK, href: '/App-State'}
    let nav2:SideNavigationItem = {text: 'Runbook Executions', type: SideNavigationItemType.LINK, href: '/Runbook-Executions'}
    let nav3:SideNavigationItem = {text: 'Application Recon', type: SideNavigationItemType.LINK, href: '/App-Recon'}
    let nav4:SideNavigationItem = {text: 'Application Admin', type: SideNavigationItemType.LINK, href: '/App-Admin'}
    let nav5:SideNavigationItem = {"text": "Application Monitor", "type": SideNavigationItemType.SECTION, "expanded": true,
               "items": [{"text": "Trade Matching", "type": SideNavigationItemType.LINK, "href": "/TM-App-Monitor"},
                         {"text": "Settlement", "type": SideNavigationItemType.LINK, "href": "/SM-App-Monitor"}]}
    let nav6:SideNavigationItem = {"text": "Application Testing", "type": SideNavigationItemType.SECTION, "expanded": true,
      "items": [{"text": "Acceptance Testing", "type": SideNavigationItemType.LINK, "href": "/Acceptance-Testing"},
                {"text": "Integration Testing", "type": SideNavigationItemType.LINK, "href": "/Integration-Testing"},
                {"text": "Chaos Testing", "type": SideNavigationItemType.LINK, "href": "/Chaos-Testing"}]}
    navs.push(nav1)
    navs.push(nav2)
    navs.push(nav3)
    navs.push(nav4)
    navs.push(nav5)
    navs.push(nav6)

    return navs;
  }

    return <AppLayoutBase
        header={Header}
        navigation={SideNavigation}
        breadcrumbs={Breadcrumbs}
    >
        {children}
    </AppLayoutBase>
}

export default AppLayout;