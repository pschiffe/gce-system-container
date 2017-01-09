#!/bin/bash

set -euo pipefail

cp -a /etc/sysctl.d/11-gce-network-security.conf /HOST/etc/sysctl.d/11-gce-network-security.conf
cp -a /etc/udev/rules.d/*gce*rules /HOST/etc/udev/rules.d/

if ! grep -q '^ForwardToConsole=yes' /HOST/etc/systemd/journald.conf; then
    echo 'ForwardToConsole=yes' >> /HOST/etc/systemd/journald.conf
fi

exit 0

