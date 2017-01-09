#!/bin/bash

set -euo pipefail

cp -a /etc/dhcp/dhclient.d/google_hostname.sh /HOST/etc/dhcp/dhclient.d/google_hostname.sh
cp -a /usr/bin/set_hostname /HOST/usr/local/bin/set_hostname
cp -a /etc/sysctl.d/11-gce-network-security.conf /HOST/etc/sysctl.d/11-gce-network-security.conf
cp -a /etc/udev/rules.d/*gce*rules /HOST/etc/udev/rules.d/

if ! grep -q '^ForwardToConsole=yes' /HOST/etc/systemd/journald.conf; then
    echo 'ForwardToConsole=yes' >> /HOST/etc/systemd/journald.conf
fi

exit 0

