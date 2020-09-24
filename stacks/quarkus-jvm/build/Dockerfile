ARG version=tip
FROM quay.io/boson/faas-stack-build:ubi8-${version}

ARG stack_id
ENV CNB_STACK_ID=${stack_id}
LABEL io.buildpacks.stack.id=${stack_id}

USER root
RUN dnf module install -y maven:3.6
RUN dnf install -y wget maven tar gzip java-11-openjdk-headless \
    && dnf update -y \
    && dnf clean all -y

ENV HOME /projects/quarkus-function
WORKDIR $HOME
RUN chown cnb:cnb $HOME
USER cnb

