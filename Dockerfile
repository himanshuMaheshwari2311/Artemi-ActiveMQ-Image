# Apache Artemis ActiveMQ

##############################################################
############            Build Image             ##############
##############################################################

FROM openjdk:8-jre-alpine

ENV ARTEMIS_ACTIVEMQ_VERSION=2.8.0

# install packages for alpine
RUN apk update && apk add --no-cache wget

WORKDIR /opt

# COPY ./apache-artemis-2.8.0-bin.tar.gz .

RUN wget --no-check-certificate "https://repository.apache.org/content/repositories/releases/org/apache/activemq/apache-artemis/${ARTEMIS_ACTIVEMQ_VERSION}/apache-artemis-${ARTEMIS_ACTIVEMQ_VERSION}-bin.tar.gz" \
    && tar xfz "apache-artemis-${ARTEMIS_ACTIVEMQ_VERSION}-bin.tar.gz" \
    && ln -s "/opt/apache-artemis-${ARTEMIS_ACTIVEMQ_VERSION}" "/opt/apache-artemis" \
    && rm "apache-artemis-${ARTEMIS_ACTIVEMQ_VERSION}-bin.tar.gz"

WORKDIR /opt/apache-artemis/bin
RUN chmod 777 artemis

RUN "/opt/apache-artemis-${ARTEMIS_ACTIVEMQ_VERSION}/bin/artemis" create broker \
--home /opt/apache-artemis \
--user admin \
--password admin \
--role amq \ 
--require-login \ 
--cluster-user admin \ 
--cluster-password admin ;

RUN "/opt/apache-artemis-${ARTEMIS_ACTIVEMQ_VERSION}/bin/broker/bin/artemis" user add --user read --password read --role view
RUN "/opt/apache-artemis-${ARTEMIS_ACTIVEMQ_VERSION}/bin/broker/bin/artemis" user add --user consumer --password consumer --role consumer
RUN "/opt/apache-artemis-${ARTEMIS_ACTIVEMQ_VERSION}/bin/broker/bin/artemis" user add --user publisher --password publisher --role publisher


RUN if (echo "${ARTEMIS_ACTIVEMQ_VERSION}" | grep -Eq "(1.5\\.[3-5][^1]\\.[0-9]\\.[0-9]+)" ); then touch /opt/apache-artemis/bin/broker/.perf-journal-completed; fi

RUN ln -s "/opt/apache-artemis-${ARTEMIS_ACTIVEMQ_VERSION}" /opt/apache-artemis && chmod -R 777 /opt/apache-artemis

RUN chmod -R 777 /opt/apache-artemis/bin/broker

RUN mkdir /opt/apache-artemis/bin/broker/lock && chmod -R 777 /opt/apache-artemis/bin/broker/lock

RUN sed -i 's/localhost/0.0.0.0/g' /opt/apache-artemis-${ARTEMIS_ACTIVEMQ_VERSION}/bin/broker/etc/bootstrap.xml

RUN sed -i 's/localhost//g' /opt/apache-artemis-${ARTEMIS_ACTIVEMQ_VERSION}/bin/broker/etc/jolokia-access.xml

# adding little tuning to the broker instance
RUN sed -i 's/1048576/10048576/g' /opt/apache-artemis-${ARTEMIS_ACTIVEMQ_VERSION}/bin/broker/etc/broker.xml \
    && sed -i 's/<\/journal-file-size>/<\/journal-file-size>\n\n\t<journal-buffer-size>1048576<\/journal-buffer-size>/g' /opt/apache-artemis-${ARTEMIS_ACTIVEMQ_VERSION}/bin/broker/etc/broker.xml \
    && sed -i 's/\"consume\"\ roles=\"amq\"/\"consume\"\ roles=\"amq,consumer\"/g' /opt/apache-artemis-${ARTEMIS_ACTIVEMQ_VERSION}/bin/broker/etc/broker.xml \
    && sed -i 's/\"browse\"\ roles=\"amq\"/\"browse\"\ roles=\"amq,consumer\"/g' /opt/apache-artemis-${ARTEMIS_ACTIVEMQ_VERSION}/bin/broker/etc/broker.xml \
    && sed -i 's/\"send\"\ roles=\"amq\"/\"send\"\ roles=\"amq,publisher\"/g' /opt/apache-artemis-${ARTEMIS_ACTIVEMQ_VERSION}/bin/broker/etc/broker.xml \
    && sed -i 's/\"createNonDurableQueue\"\ roles=\"amq\"/\"createNonDurableQueue\"\ roles=\"amq,publisher,consumer\"/g' /opt/apache-artemis-${ARTEMIS_ACTIVEMQ_VERSION}/bin/broker/etc/broker.xml \
    && sed -i 's/\"createDurableQueue\"\ roles=\"amq\"/\"createDurableQueue\"\ roles=\"amq,publisher,consumer\"/g' /opt/apache-artemis-${ARTEMIS_ACTIVEMQ_VERSION}/bin/broker/etc/broker.xml \
    && sed -i 's/\"createAddress\"\ roles=\"amq\"/\"createAddress\"\ roles=\"amq,publisher,consumer\"/g' /opt/apache-artemis-${ARTEMIS_ACTIVEMQ_VERSION}/bin/broker/etc/broker.xml \
    && sed -i 's/<max-disk-usage>90/<max-disk-usage>100/g' /opt/apache-artemis-${ARTEMIS_ACTIVEMQ_VERSION}/bin/broker/etc/broker.xml \
    && sed -i 's/61616/61616?clientFailureCheckPeriod\=100000;keepAlive\=true;consumerWindowSize\=0;handshake-timeout\=0;/g' /opt/apache-artemis-${ARTEMIS_ACTIVEMQ_VERSION}/bin/broker/etc/broker.xml \
    && sed -i 's/<\/journal-buffer-size>/<\/journal-buffer-size>\n\n\t<connection-ttl-override>1000000<\/connection-ttl-override>\n/g' /opt/apache-artemis-${ARTEMIS_ACTIVEMQ_VERSION}/bin/broker/etc/broker.xml

RUN sed -i 's/\"list\*\" roles=\"view,update,amq\"/\"list\*\" roles=\"view,update,amq,consumer\"/g' /opt/apache-artemis-${ARTEMIS_ACTIVEMQ_VERSION}/bin/broker/etc/management.xml \
    && sed -i 's/\"get\*\" roles=\"view,update,amq\"/\"list\*\" roles=\"view,update,amq,consumer\"/g' /opt/apache-artemis-${ARTEMIS_ACTIVEMQ_VERSION}/bin/broker/etc/management.xml \
    && sed -i 's/\"list\*\" roles=\"view,update,amq\"/\"list\*\" roles=\"view,update,amq,publisher\"/g' /opt/apache-artemis-${ARTEMIS_ACTIVEMQ_VERSION}/bin/broker/etc/management.xml

RUN sed -i 's/-Xm[xs][^ \"]*//g' /opt/apache-artemis-${ARTEMIS_ACTIVEMQ_VERSION}/bin/broker/etc/artemis.profile \
    && sed -i 's/JAVA_ARGS=\"/JAVA_ARGS=\"-Djava.net.preferIPv4Addresses=true -Djava.net.preferIPv4Stack=true -XX:MaxHeapSize=512m -XX:InitialHeapSize=256m -XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap /g' /opt/apache-artemis-${ARTEMIS_ACTIVEMQ_VERSION}/bin/broker/etc/artemis.profile

EXPOSE 8161 9404 5672 61616 1098 1099

WORKDIR /opt/apache-artemis/bin/broker/bin

CMD ["./artemis", "run"]