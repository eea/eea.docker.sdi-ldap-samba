#!/bin/bash

cp -r smbldap_bind.conf /etc/smbldap-tools/smbldap_bind.conf
sed "s#SLAPD_PASSWORD#$SLAPD_PASSWORD#g" -i /etc/smbldap-tools/smbldap_bind.conf

chown -R ldap:ldap /var/lib/ldap
chown -R ldap:ldap /etc/openldap/slapd.d

echo -e "Starting supervisord..."
supervisord -c /etc/supervisord.conf
