# Apache Artemis ActiveMQ

##############################################################
############            Build Image             ##############
##############################################################

FROM openjdk:8-jre-alpine

ENV ARTEMIS_ACTIVEMQ_VERSION=2.8.0

# install packages for alpine
RUN apk update && apk add --no-cache wget

WORKDIR /opt

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

RUN "/opt/apache-artemis-${ARTEMIS_ACTIVEMQ_VERSION}/bin/artemis" user add --user read --password read --role view
RUN "/opt/apache-artemis-${ARTEMIS_ACTIVEMQ_VERSION}/bin/artemis" user add --user consumer --password consumer --role consumer
RUN "/opt/apache-artemis-${ARTEMIS_ACTIVEMQ_VERSION}/bin/artemis" user add --user publisher --password publisher --role publisher


RUN if (echo "${ARTEMIS_ACTIVEMQ_VERSION" | grep -Eq "(1.5\\.[3-5][^1]\\.[0-9]\\.[0-9]+" ); then touch /opt/apache-artemis/bin/broker/.perf-journal-completed; fi

RUN ln -s "/opt/apache-artemis-${ARTEMIS_ACTIVEMQ_VERSION}" /opt/apache-artemis && chmod -R 777 /opt/apache-artemis

EXPOSE 8161 9404 5672 61616 1098 1099

RUN chmod -R 777 /opt/apache-artemis/bin/broker

RUN mkdir /opt/apache-artemis/bin/acs/lock && chmod -R 777 /opt/apache-artemis/bin/acs/lock

RUN sed -i 's/localhost/0.0.0.0/g' /opt/apache-artemis-${ARTEMIS_ACTIVEMQ_VERSION}/bin/broker/etc/bootstrap.xml