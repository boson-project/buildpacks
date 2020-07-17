ARG version=tip
FROM quay.io/boson/faas-stack-build:ubi8-${version}

ARG stack_id
ENV CNB_STACK_ID=${stack_id}
LABEL io.buildpacks.stack.id=${stack_id}

# Install Golang
USER root
RUN dnf install -y golang

ENV HOME /projects/go-function
WORKDIR $HOME
RUN chown cnb:cnb $HOME
USER cnb
