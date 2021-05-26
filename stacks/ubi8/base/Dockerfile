FROM registry.access.redhat.com/ubi8/ubi:8.4

ARG cnb_uid=1000
ARG cnb_gid=1001

ENV HOME /workspace

# Create user and group
RUN groupadd -g ${cnb_gid} cnb && \
  useradd -u ${cnb_uid} -g cnb -s /bin/bash cnb && \
  mkdir ${HOME}
# Set required CNB information
ENV CNB_USER_ID=${cnb_uid}
ENV CNB_GROUP_ID=${cnb_gid}

RUN chown cnb:cnb ${HOME}
USER cnb

WORKDIR ${HOME}
