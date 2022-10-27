// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
package app.tradematching.inboundgateway.services;

import app.tradematching.inboundgateway.jms.ConsumerMessageListener;
import app.tradematching.inboundgateway.jms.ReceiverConfig;
import app.tradematching.inboundgateway.utils.AwsConfig;
import lombok.extern.slf4j.Slf4j;
import org.apache.activemq.ActiveMQConnectionFactory;
import org.apache.activemq.broker.BrokerFactory;
import org.apache.activemq.broker.BrokerService;

import javax.jms.*;

@Slf4j
public class InboundGatewayService implements Runnable {
    AwsConfig config;
    public boolean listening = true;

    public InboundGatewayService(AwsConfig config)
    {
        this.config = config;
    }
    @Override
    public void run() {
        log.info("Starting Inbound gateway Listener");
        Connection connection = null;
        Session session = null;
        try {
//                BrokerService broker = BrokerFactory.createBroker(new URI(
//                        "broker:(tcp://localhost:61616)"));
//                broker.start();
            ReceiverConfig jmsConfig = new ReceiverConfig(
                    config.awsProperties.getBrokerUrl(),
                    config.awsProperties.getUsername(),
                    config.awsProperties.getPassword());

            ConnectionFactory connectionFactory = jmsConfig.getConnectionFactory();
            connection = connectionFactory.createConnection();
            connection.setClientID("trades");
            session = connection.createSession(false,
                    Session.AUTO_ACKNOWLEDGE);
            Topic topic = session.createTemporaryTopic();
            MessageConsumer consumer1 = session.createConsumer(topic);
            ConsumerMessageListener listener = new ConsumerMessageListener("TradesConsumer", config);
            consumer1.setMessageListener(listener);
            connection.start();
        } catch (JMSException e) {
            log.error(String.valueOf(e));
        } finally {
            if (connection != null) {
                try {
                    connection.close();
                } catch (JMSException e) {
                    e.printStackTrace();
                }
            }
//                broker.stop();
        }

        while(listening) {
            try {
                Thread.sleep(3000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
        //shut down listener
        try {
            connection.close();
            session.close();
        } catch (JMSException e) {
            e.printStackTrace();
        }


    }
}
