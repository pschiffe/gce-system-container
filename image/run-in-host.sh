#!/bin/bash

set -euo pipefail

mount --rbind /HOST/etc/ /etc/
mount --rbind /HOST/home /home/
mount --rbind /HOST/var/spool/mail /var/spool/mail
mount --rbind /HOST/var/lib/google /var/lib/google

exec $@

