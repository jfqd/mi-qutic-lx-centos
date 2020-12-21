#!/bin/bash

if /native/usr/sbin/mdata-get ipv6_gateway 1>/dev/null 2>&1; then
  GW=$(/native/usr/sbin/mdata-get ipv6_gateway)
  mkdir -p /etc/inet
  touch /etc/inet/static_routes
  /native/usr/sbin/route -p add -inet6 default ${GW}
fi