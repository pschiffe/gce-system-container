#!/bin/bash

set -euo pipefail

touch /var/log/lastlog

mount --rbind /HOST/etc/ /etc/
mount --rbind /HOST/home /home/
mount --rbind /HOST/var/spool/mail /var/spool/mail
mount --rbind /HOST/var/log/lastlog /var/log/lastlog
mount --rbind /HOST/var/lib/google /var/lib/google

exec $@

