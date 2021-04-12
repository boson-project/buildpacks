ARG version=tip
FROM quay.io/boson/faas-stack-build:ubi8-${version}

ARG stack_id
ENV CNB_STACK_ID=${stack_id}
LABEL io.buildpacks.stack.id=${stack_id}

ENV HOME /projects/quarkus-function
WORKDIR $HOME

USER root
RUN dnf module install -y maven:3.6 \
    && dnf install -y wget maven tar gzip gcc glibc-devel zlib-devel \
    && dnf update -y \
    && dnf clean all -y \
    && chown cnb:cnb $HOME \
    && wget -q -O - "https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-21.0.0.2/graalvm-ce-java11-linux-amd64-21.0.0.2.tar.gz" | \
        tar -xzf - -C /opt \
    && mv /opt/graalvm-ce-java11-21.0.0.2 /opt/graalvm \
    && /opt/graalvm/bin/gu --auto-yes install native-image

ENV JAVA_HOME /opt/graalvm
ENV GRAALVM_HOME /opt/graalvm
ENV PATH $GRAALVM_HOME/bin:$PATH

USER cnb

