#!/bin/bash

set -euo pipefail

rm -f \
    /HOST/etc/dhcp/dhclient.d/google_hostname.sh \
    /HOST/usr/bin/set_hostname 

exit 0

