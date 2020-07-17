ARG version=tip
FROM quay.io/boson/faas-stack-build:ubi8-${version}

ARG stack_id
ENV CNB_STACK_ID=${stack_id}
LABEL io.buildpacks.stack.id=${stack_id}

USER root
RUN dnf module install -y maven:3.6
RUN dnf install -y wget maven tar gzip gcc glibc-devel zlib-devel

RUN wget -q -O - "https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-20.1.0/graalvm-ce-java11-linux-amd64-20.1.0.tar.gz" | \
  tar -xzf - -C /opt
RUN mv /opt/graalvm-ce-java11-20.1.0 /opt/graalvm
RUN /opt/graalvm/bin/gu --auto-yes install native-image

ENV JAVA_HOME /opt/graalvm
ENV GRAALVM_HOME /opt/graalvm
ENV PATH $GRAALVM_HOME/bin:$PATH

ENV HOME /projects/quarkus-function
WORKDIR $HOME
RUN chown cnb:cnb $HOME
USER cnb

