ARG version=tip
FROM quay.io/boson/faas-stack-run:ubi8-minimal-${version}

ARG stack_id
ENV CNB_STACK_ID=${stack_id}
LABEL io.buildpacks.stack.id=${stack_id}

USER root
COPY ./nodejs.module /etc/dnf/modules.d
RUN microdnf install --nodocs -y nodejs tar

ENV NODE_PATH $HOME/node_modules
ENV NODE_ENV production
ENV PORT 8080
