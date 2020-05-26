FROM registry.access.redhat.com/ubi8/ubi:latest

ARG cnb_uid=1000
ARG cnb_gid=1001

# Create user and group
RUN groupadd -g ${cnb_gid} cnb && \
  useradd -u ${cnb_uid} -g cnb -s /bin/bash cnb

# Set required CNB information
ENV CNB_USER_ID=${cnb_uid}
ENV CNB_GROUP_ID=${cnb_gid}
