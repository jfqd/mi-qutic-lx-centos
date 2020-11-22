#!/bin/bash

if [[ `grep systemd_health_check /etc/cron.d/systemd_health_check |wc -l` -eq 0 ]]; then

cat >> /etc/cron.d/systemd_health_check << EOF
MAILTO=root
#
*/2 * * * *     root   /usr/local/bin/systemd_health_check
# END
EOF

fi
