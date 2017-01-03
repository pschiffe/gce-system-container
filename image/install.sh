#!/bin/bash

set -euo pipefail

cp -a /etc/dhcp/dhclient.d/google_hostname.sh /HOST/etc/dhcp/dhclient.d/google_hostname.sh
cp -a /usr/bin/set_hostname /HOST/usr/bin/set_hostname

exit 0

