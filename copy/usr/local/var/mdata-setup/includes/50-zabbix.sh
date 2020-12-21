#!/bin/bash

if mdata-get zabbix_pski 1>/dev/null 2>&1; then
  PSKI=$(mdata-get zabbix_pski)

  if mdata-get zabbix_psk 1>/dev/null 2>&1; then
    PSK=$(mdata-get zabbix_psk)

    echo "${PSK}" > /etc/zabbix/zabbix_agentd.psk
    chmod 0400 /etc/zabbix/zabbix_agentd.psk
    chown zabbix:zabbix /etc/zabbix/zabbix_agentd.psk

    sed -i \
        -e "s|# TLSAccept=unencrypted|TLSAccept=psk|" \
        -e "s|# TLSConnect=unencrypted|TLSConnect=psk|" \
        -e "s|# TLSPSKIdentity=|TLSPSKIdentity=${PSKI}|" \
        -e "s|# TLSPSKFile=|TLSPSKFile=/etc/zabbix/zabbix_agentd.psk|" \
        /etc/zabbix/zabbix_agentd.conf

  fi
fi

if mdata-get zabbix_server 1>/dev/null 2>&1; then
  ZABBIX_SERVER=$(mdata-get zabbix_server)
  sed -i \
      -e "s|Server=127.0.0.1|Server=${ZABBIX_SERVER}|" \
      -e "s|ServerActive=127.0.0.1|# ServerActive=${ZABBIX_SERVER}|" \
      /etc/zabbix/zabbix_agentd.conf

  HOSTNAME=$(/bin/hostname)
  sed -i \
      -e "s|Hostname=Zabbix server|Hostname=${HOSTNAME}|" \
      /etc/zabbix/zabbix_agentd.conf

  # disable zabbix systemd cause of issues
  systemctl stop zabbix-agent || true
  # and use old init.d
  echo "* Use old init.d for zabbix"
  sed -i \
      -e "s|exit 0|/etc/init.d/zabbix start; exit 0|" \
      /lib/smartdc/joyent_rc.local
  sed -i \
      -e "s|exit 0|/etc/init.d/zabbix start; exit 0|" \
      /etc/rc.local
  /etc/init.d/zabbix start
fi
