FROM bosonproject/faas-stack-run:ubi8-minimal

ARG stack_id
ENV CNB_STACK_ID=${stack_id}
LABEL io.buildpacks.stack.id=${stack_id}

ENV HOME /projects/quarkus-function
WORKDIR $HOME
USER root
RUN chown cnb:cnb $HOME
USER cnb

ENV PORT 8080
