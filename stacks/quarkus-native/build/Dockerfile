ARG version=tip
FROM quay.io/boson/faas-stack-build:ubi8-${version}

ARG stack_id
ENV CNB_STACK_ID=${stack_id}
LABEL io.buildpacks.stack.id=${stack_id}

ENV HOME /projects/quarkus-function
WORKDIR $HOME

USER root
RUN dnf module install -y maven:3.6 \
    && dnf install -y openssl-devel wget maven tar gzip gcc glibc-static glibc-devel zlib-devel gcc-c++ \
    && dnf update -y \
    && dnf clean all -y \
    && chown cnb:cnb $HOME \
    && wget -q -O - "https://github.com/graalvm/mandrel/releases/download/mandrel-21.0.0.0-Final/mandrel-java11-linux-amd64-21.0.0.0-Final.tar.gz" | \
        tar -xzf - -C /opt \
    && mv /opt/mandrel-java11-21.0.0.0-Final /opt/mandrel

ENV JAVA_HOME /opt/mandrel
ENV GRAALVM_HOME /opt/mandrel
ENV PATH $GRAALVM_HOME/bin:$PATH

USER cnb
