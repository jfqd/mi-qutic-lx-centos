#!/bin/bash
if /native/usr/sbin/mdata-get mail_smarthost 1>/dev/null 2>&1; then
  if /native/usr/sbin/mdata-get mail_adminaddr 1>/dev/null 2>&1; then
    echo "root: $(/native/usr/sbin/mdata-get mail_adminaddr)" >> /etc/aliases
    newaliases
  fi
  AUTH=""
  if /native/usr/sbin/mdata-get mail_auth_user 1>/dev/null 2>&1 && 
     /native/usr/sbin/mdata-get mail_auth_pass 1>/dev/null 2>&1; then
    AUTH="\"U:$(/native/usr/sbin/mdata-get mail_auth_user)\" \"P:$(/native/usr/sbin/mdata-get mail_auth_pass)\""
  fi
  echo "AuthInfo:$(/native/usr/sbin/mdata-get mail_smarthost)    ${AUTH}" > /etc/mail/authinfo
  chmod 0640 /etc/mail/authinfo
  
  sed -i "s:dnl define(\`SMART_HOST', \`smtp.your.provider')dnl:dnl define(\`SMART_HOST', \`$(/native/usr/sbin/mdata-get mail_smarthost)')dnl\nFEATURE(\`authinfo')dnl:" \
      /etc/mail/sendmail.mc

  /etc/mail/make || true
  service sendmail restart || true
fi
