ARG version=tip
FROM quay.io/boson/faas-stack-build:ubi8-${version}

ARG stack_id
ENV CNB_STACK_ID=${stack_id}
LABEL io.buildpacks.stack.id=${stack_id}

# Install Node.js and tar (needed by odo)
USER root
COPY ./nodejs.module /etc/dnf/modules.d
RUN dnf install -y nodejs tar

ENV HOME /projects/node-function
WORKDIR $HOME
RUN chown cnb:cnb $HOME
USER cnb
