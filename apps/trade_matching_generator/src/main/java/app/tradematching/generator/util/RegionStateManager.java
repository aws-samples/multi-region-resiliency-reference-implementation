// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.generator.util;

import app.tradematching.generator.config.AwsConfig;
import app.tradematching.generator.interfaces.IStateAction;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;
import software.amazon.awssdk.http.apache.ApacheHttpClient;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.route53recoverycluster.Route53RecoveryClusterClient;
import software.amazon.awssdk.services.route53recoverycluster.model.GetRoutingControlStateRequest;
import software.amazon.awssdk.services.route53recoverycluster.model.GetRoutingControlStateResponse;
import software.amazon.awssdk.services.route53recoverycluster.model.RoutingControlState;
import software.amazon.awssdk.services.route53recoverycontrolconfig.Route53RecoveryControlConfigClient;
import software.amazon.awssdk.services.route53recoverycontrolconfig.model.*;

import javax.annotation.PostConstruct;
import java.net.URI;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ExecutionException;
import java.util.stream.Collectors;

@Slf4j
@Component
public class RegionStateManager {
    @Autowired
    AwsConfig awsConfig;

    Route53RecoveryControlConfigClient configClient;
    List<ClusterEndpoint> clusterEndpoints;
    ControlPanel routingControlPanel;
    RoutingControl routingControl;
    String clusterArn;
    boolean currentState = false;                 //true = on which is the goto state
    private static Object LOCK = new Object();
    private IStateAction action;

    public RegionStateManager(IStateAction action){
        this.action = action;
    }

    @PostConstruct
    public void prepareRegionStateCheck(){
        log.info(awsConfig.awsProperties.toString());
        log.info(awsConfig.tradeGeneratorProperties.toString());
        configClient = awsConfig.getArcConfigClient();
        clusterArn = awsConfig.awsProperties.getRout53arcClusterArn();
        try {
            clusterEndpoints = getClusterEndpoints();
            routingControlPanel = getControlPanel();
            routingControl = getRoutingControl();
        } catch (ExecutionException | InterruptedException e) {
            log.error("Error checking region state ", e);

        }
    }

    @EventListener(ApplicationReadyEvent.class)
    public void checkRegionState() {
        this.action=action;
        try {
            while (true) {
                boolean newActiveState = getRoutingControlState();
                if (newActiveState != currentState) {
                    log.info("Region active state updated.");
                    currentState = newActiveState;
                    if (currentState) {
                        log.info("This region is active!");
                        action.start();
                    } else {
                        // turn off jms listener
                        log.info("This region is not active! Not Producing messages!");
                        action.stop();
                    }
                }
                // for testing purposes
//                log.info("sleep test...");
                synchronized (LOCK) {
                    LOCK.wait(5000);
                }
            }
        } catch (InterruptedException e) {
            log.error("Region check interrupted ", e);
        }
    }

    private List<ClusterEndpoint> getClusterEndpoints() throws ExecutionException, InterruptedException {
        DescribeClusterResponse response = configClient.describeCluster(
                DescribeClusterRequest.builder().clusterArn(clusterArn).build());
        List<ClusterEndpoint> relevant = new ArrayList<>();
        List<ClusterEndpoint> clusters = response.cluster().clusterEndpoints();
        for (ClusterEndpoint c : clusters)
        {
            if (c.region().equalsIgnoreCase("us-east-1") || c.region().equalsIgnoreCase("us-west-2"))
                relevant.add(c);
        }
        return relevant;
    }

    private ControlPanel getControlPanel() throws ExecutionException, InterruptedException {
        List<ControlPanel> controlPanels = configClient.listControlPanels(
                ListControlPanelsRequest.builder().clusterArn(clusterArn).build()).controlPanels();

        log.info(awsConfig.awsProperties.getControlPanel());
        List<ControlPanel> cpanels = controlPanels.stream().filter(cp -> cp.name().equalsIgnoreCase(awsConfig.awsProperties.getControlPanel()))
                .collect(Collectors.toList());

        return cpanels.get(0);
    }

    private RoutingControl getRoutingControl() throws ExecutionException, InterruptedException {
        List<RoutingControl> routingControls = configClient.listRoutingControls(
                ListRoutingControlsRequest.builder().controlPanelArn(routingControlPanel.controlPanelArn()).build()
        ).routingControls();

        return routingControls.stream().filter(rc -> rc.name().equalsIgnoreCase(awsConfig.awsProperties.getRoutingControl()))
                .collect(Collectors.toList()).get(0);
    }

    private boolean getRoutingControlState() {
        for (ClusterEndpoint clusterEndpoint : clusterEndpoints) {
            try {
                Route53RecoveryClusterClient client = Route53RecoveryClusterClient.builder()
                        .endpointOverride(URI.create(clusterEndpoint.endpoint()))
                        .httpClient(ApacheHttpClient.create())
                        .region(Region.of(clusterEndpoint.region())).build();
                GetRoutingControlStateResponse response = client.getRoutingControlState(
                        GetRoutingControlStateRequest.builder()
                                .routingControlArn(routingControl.routingControlArn()).build());
                return response.routingControlState().equals(RoutingControlState.ON);
            } catch (Exception e){
                log.error("Error hitting endpoint: " + clusterEndpoint + " ", e);
            }
        }
        return false;
    }
}
