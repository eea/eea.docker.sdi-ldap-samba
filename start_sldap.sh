#!/bin/bash

echo sleeping 15
sleep 15
echo finished sleeping
slapd -d  256 -u ldap -g ldap -h "ldapi:/// ldap:/// ldaps://
