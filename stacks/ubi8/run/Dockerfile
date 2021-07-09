FROM registry.access.redhat.com/ubi8/ubi-minimal:8.4

# Set required CNB information
ARG stack_id
ARG cnb_uid=1000
ARG cnb_gid=1001

LABEL io.buildpacks.stack.id=${stack_id}

ENV CNB_STACK_ID=${stack_id}
ENV CNB_USER_ID=${cnb_uid}
ENV CNB_GROUP_ID=${cnb_gid}
ENV HOME /workspace

# Create user and group
RUN microdnf install -y shadow-utils tar && \
  groupadd -g ${cnb_gid} cnb && \
  useradd -u ${cnb_uid} -g cnb -s /bin/bash cnb && \
  mkdir ${HOME} && \
  chown cnb:cnb ${HOME}

USER ${CNB_USER_ID}:${CNB_GROUP_ID}

WORKDIR ${HOME}
