ARG version=tip
FROM quay.io/boson/faas-stack-run:ubi8-minimal-${version}

ARG stack_id
ENV CNB_STACK_ID=${stack_id}
LABEL io.buildpacks.stack.id=${stack_id}

ENV HOME /projects/spring-cloud-function
WORKDIR $HOME
USER root

ARG JAVA_PACKAGE=java-11-openjdk-headless
ARG RUN_JAVA_VERSION=1.3.8

ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en'

# Install java and the run-java script
# Also set up permissions for user `1001`
RUN microdnf install curl ca-certificates ${JAVA_PACKAGE} \
    && microdnf update \
    && microdnf clean all \
    && curl https://repo1.maven.org/maven2/io/fabric8/run-java-sh/${RUN_JAVA_VERSION}/run-java-sh-${RUN_JAVA_VERSION}-sh.sh -o /usr/local/bin/run-java.sh \
    && chmod "a+rx" /usr/local/bin/run-java.sh \
    && echo "securerandom.source=file:/dev/urandom" >> /etc/alternatives/jre/lib/security/java.security \
    && chown cnb:cnb $HOME


USER cnb

ENV PORT 8080

EXPOSE 8080
EXPOSE 5005
