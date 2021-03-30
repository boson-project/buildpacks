ARG version=tip
FROM quay.io/boson/faas-stack-run:ubi8-minimal-${version}

ARG stack_id
ENV CNB_STACK_ID=${stack_id}
LABEL io.buildpacks.stack.id=${stack_id}

USER root
COPY ./python.module /etc/dnf/modules.d
RUN microdnf install --nodocs -y python3 tar wget && \
    wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.5/dumb-init_1.2.5_x86_64 && \
    chmod +x /usr/local/bin/dumb-init && \
    microdnf remove wget tar && \
    microdnf clean all

ENV HOME /projects/python-function
WORKDIR $HOME
RUN chown cnb:cnb $HOME
USER cnb

ENV PORT 8080
