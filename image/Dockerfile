FROM centos:7
MAINTAINER "Peter Schiffer" <pschiffe@redhat.com>

COPY google-cloud.repo /etc/yum.repos.d/google-cloud.repo

RUN yum -y --setopt=tsflags=nodocs install \
        ethtool \
        openssh \
        selinux-policy-targeted \
        google-config \
        google-compute-engine \
        google-compute-engine-init \
        \
        less bash-completion iproute vim strace \
    && yum clean all

STOPSIGNAL SIGRTMIN+3

ENV container=docker

COPY manifest.json tmpfiles.template service.template config.json.template /exports/
COPY dbus.service install.service /etc/systemd/system/
COPY run-in-host.sh install.sh /usr/local/bin/
COPY google-accounts-daemon-config.conf /etc/systemd/system/google-accounts-daemon.service.d/config.conf

RUN rm -f /etc/machine-id /etc/fstab /var/lib/rpm/__db.* \
  && mkdir -p /var/lib/google /run/secrets \
  && systemctl enable install.service

CMD [ "/usr/sbin/init" ]

