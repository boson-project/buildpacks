ARG version=tip
FROM quay.io/boson/faas-stack-run:ubi8-${version}

ARG stack_id
ENV CNB_STACK_ID=${stack_id}
LABEL io.buildpacks.stack.id=${stack_id}

USER root
RUN microdnf module enable -y nodejs:16/minimal && \
    microdnf install --nodocs -y tar
USER cnb

ENV NODE_PATH $HOME/node_modules
ENV NODE_ENV production
ENV PORT 8080
