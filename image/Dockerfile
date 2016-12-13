FROM centos:7
MAINTAINER "Peter Schiffer" <pschiffe@redhat.com>

COPY google-cloud.repo /etc/yum.repos.d/google-cloud.repo

RUN yum -y --setopt=tsflags=nodocs install \
        ethtool \
        openssh \
        google-compute-engine \
        google-compute-engine-init \
        google-config \
        \
        less bash-completion iproute vim strace \
    && yum clean all \
    && systemctl disable sshd

STOPSIGNAL SIGRTMIN+3

RUN rm -f /etc/machine-id /etc/fstab /var/lib/rpm/__db.*

ENV container=docker

COPY manifest.json tmpfiles.template service.template config.json.template /exports/
COPY dbus.service /etc/systemd/system/dbus.service

CMD [ "/usr/sbin/init" ]

