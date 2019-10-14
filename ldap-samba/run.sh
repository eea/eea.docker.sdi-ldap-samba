#!/bin/bash

chown -R ldap:ldap /var/lib/ldap
chown -R ldap:ldap /etc/openldap/slapd.d

echo -e "Starting supervisord..."
supervisord -c /etc/supervisord.conf
