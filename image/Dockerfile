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
    && yum clean all

STOPSIGNAL SIGRTMIN+3

ENV container=docker

COPY manifest.json tmpfiles.template service.template config.json.template /exports/
COPY dbus.service HOST-usr.mount HOST-dev.mount HOST-run.mount HOST-tmp.mount /etc/systemd/system/
COPY google-accounts-daemon-rootdir.conf /etc/systemd/system/google-accounts-daemon.service.d/rootdir.conf

RUN rm -f /etc/machine-id /etc/fstab /var/lib/rpm/__db.*
RUN mkdir -p /HOST/usr /HOST/dev /HOST/var /HOST/run /HOST/tmp \
  && cd /HOST \
  && ln -s usr/lib64 lib64 \
  && cd var \
  && ln -s ../run/lock lock \
  && ln -s spool/mail mail \
  && systemctl enable HOST-usr.mount \
  && systemctl enable HOST-dev.mount \
  && systemctl enable HOST-run.mount \
  && systemctl enable HOST-tmp.mount

CMD [ "/usr/sbin/init" ]

