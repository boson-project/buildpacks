ARG version=tip
FROM quay.io/boson/faas-stack-build:ubi8-${version}

ARG stack_id
ENV CNB_STACK_ID=${stack_id}
LABEL io.buildpacks.stack.id=${stack_id}

# Install Python 3, tar and a python functions virtual environment
USER root
ENV HOME /projects/python-function
COPY ./python.module /etc/dnf/modules.d
RUN dnf install --nodocs -y python38 tar

WORKDIR $HOME
RUN chown cnb:cnb $HOME
USER cnb
