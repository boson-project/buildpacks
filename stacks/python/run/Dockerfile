ARG version=tip
FROM quay.io/boson/faas-stack-run:ubi8-minimal-${version}

ARG stack_id
ENV CNB_STACK_ID=${stack_id}
LABEL io.buildpacks.stack.id=${stack_id}

USER root
COPY ./python.module /etc/dnf/modules.d
RUN microdnf install --nodocs -y python38 tar

ENV PORT 8080
