// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.settlement.inbound.utils;

import app.settlement.inbound.config.AwsConfig;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.jms.config.JmsListenerEndpointRegistry;
import org.springframework.jms.listener.DefaultMessageListenerContainer;
import org.springframework.jms.listener.MessageListenerContainer;
import org.springframework.stereotype.Component;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.route53recoverycluster.Route53RecoveryClusterClient;
import software.amazon.awssdk.services.route53recoverycluster.model.GetRoutingControlStateRequest;
import software.amazon.awssdk.services.route53recoverycluster.model.GetRoutingControlStateResponse;
import software.amazon.awssdk.services.route53recoverycluster.model.RoutingControlState;
import software.amazon.awssdk.services.route53recoverycontrolconfig.Route53RecoveryControlConfigClient;
import software.amazon.awssdk.services.route53recoverycontrolconfig.model.*;

import javax.annotation.PostConstruct;
import java.net.URI;
import java.util.Collection;
import java.util.List;
import java.util.concurrent.ExecutionException;
import java.util.stream.Collectors;

@Slf4j
@Component
public class RegionStateManager {
    AwsConfig awsConfig;
    JmsListenerEndpointRegistry jmsListenerEndpointRegistry;
    Route53RecoveryControlConfigClient configClient;
    List<ClusterEndpoint> clusterEndpoints;
    ControlPanel routingControlPanel;
    RoutingControl routingControl;
    String clusterArn;
    boolean activeState = false;
    private static Object LOCK = new Object();

    public RegionStateManager(AwsConfig awsConfig, JmsListenerEndpointRegistry jmsListenerEndpointRegistry){
        this.awsConfig = awsConfig;
        this.jmsListenerEndpointRegistry = jmsListenerEndpointRegistry;
    }

    @PostConstruct
    public void prepareRegionStateCheck(){
        configClient = awsConfig.getArcConfigClient();
        clusterArn = awsConfig.awsProperties.getArcClusterArn();
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
        try {
            while (true) {
                boolean newActiveState = getRoutingControlState();
                if (newActiveState != activeState) {
                    log.info("Region active state updated.");
                    activeState = newActiveState;
                    if (activeState) {
                        log.info("This region is active!");
                        Collection<MessageListenerContainer> listeners = jmsListenerEndpointRegistry.getListenerContainers();
                        for(MessageListenerContainer container : listeners){
                            DefaultMessageListenerContainer dmlc = (DefaultMessageListenerContainer) container;
                            dmlc.initialize();
                        }
                        jmsListenerEndpointRegistry.start();
                    } else {
                        // turn off jms listener
                        log.info("This region is not active! Not listening to queue!");
                        jmsListenerEndpointRegistry.stop();
                        Collection<MessageListenerContainer> listeners = jmsListenerEndpointRegistry.getListenerContainers();
                        for(MessageListenerContainer container : listeners){
                            DefaultMessageListenerContainer dmlc = (DefaultMessageListenerContainer) container;
                            dmlc.shutdown();
                        }
                    }
                }
                synchronized (LOCK) {
                    LOCK.wait(1000);
                }
            }
        } catch (InterruptedException e) {
            log.error("Region check interrupted ", e);
        }
    }

    private List<ClusterEndpoint> getClusterEndpoints() throws ExecutionException, InterruptedException {
        DescribeClusterResponse response = configClient.describeCluster(
                DescribeClusterRequest.builder().clusterArn(clusterArn).build());
        return response.cluster().clusterEndpoints();
    }

    private ControlPanel getControlPanel() throws ExecutionException, InterruptedException {
         List<ControlPanel> controlPanels = configClient.listControlPanels(
                ListControlPanelsRequest.builder().clusterArn(clusterArn).build()).controlPanels();
        return controlPanels.stream().filter(cp -> cp.name().equalsIgnoreCase(awsConfig.awsProperties.getControlPanel()))
                .collect(Collectors.toList()).get(0);
    }

    private RoutingControl getRoutingControl() throws ExecutionException, InterruptedException {
        List<RoutingControl> routingControls = configClient.listRoutingControls(
                ListRoutingControlsRequest.builder().controlPanelArn(routingControlPanel.controlPanelArn()).build()
        ).routingControls();
        return routingControls.stream().filter(rc -> rc.name().equalsIgnoreCase(awsConfig.awsProperties.getRoutingControlPrefix() + awsConfig.awsProperties.getRegion()))
                .collect(Collectors.toList()).get(0);
    }

    private boolean getRoutingControlState() {
        for (ClusterEndpoint clusterEndpoint : clusterEndpoints) {
            try {
                Route53RecoveryClusterClient client = Route53RecoveryClusterClient.builder()
                        .endpointOverride(URI.create(clusterEndpoint.endpoint()))
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
