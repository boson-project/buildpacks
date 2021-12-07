ARG version=tip
FROM quay.io/boson/faas-stack-build:ubi8-${version}

ARG stack_id
ENV CNB_STACK_ID=${stack_id}
LABEL io.buildpacks.stack.id=${stack_id}

# Install Node.js and build dependencies
USER root
RUN dnf module install -y nodejs:16 && \
    dnf install -y --nodocs tar git
USER cnb

