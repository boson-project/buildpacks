ARG version=tip
FROM quay.io/boson/faas-stack-run:ubi8-${version}

ARG stack_id
ENV CNB_STACK_ID=${stack_id}
LABEL io.buildpacks.stack.id=${stack_id}

USER cnb

ENV PORT 8080
