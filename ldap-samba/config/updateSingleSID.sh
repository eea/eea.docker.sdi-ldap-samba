#!/bin/bash

uuid=$(uuidgen)
mkdir -p /tmp/$uuid

localSID=$(sudo net getlocalsid | awk -F ' ' '{print $6}')
echo localSID: $localSID
uid=$1

cp /sambaSID.ldif /tmp/$uuid/sambaSID$uid.ldif
cp /sambaPrimaryGroupSID.ldif /tmp/$uuid/sambaPrimaryGroupSID$uid.ldif

sambaSID=$(ldapsearch -x -LLL -h localhost -b"ou=Users,dc=eea,dc=europa,dc=eu" -s sub "uid=$uid" | awk -F ' ' '/sambaSID/ {print $2}' | tail -c 5)
sambaPrimaryGroupSID=$(ldapsearch -x -LLL -h localhost -b"ou=Users,dc=eea,dc=europa,dc=eu" -s sub "uid=$uid" | awk -F ' ' '/gidNumber/ {print $2}' | tail -c 4)

if [ ! -z "$sambaSID" ]; then
  #echo $localSID-$sambaSID
  sed "s#UID#$uid#g" -i /tmp/$uuid/sambaSID$uid.ldif
  sed "s#SAMBASID#$sambaSID#g" -i /tmp/$uuid/sambaSID$uid.ldif
  sed "s#LOCALSID#$localSID#g" -i /tmp/$uuid/sambaSID$uid.ldif
  ldapmodify -a -x -H ldapi:/// -D "cn=admin,dc=eea,dc=europa,dc=eu" -w $SLAPD_PASSWORD -f /tmp/$uuid/sambaSID$uid.ldif
fi

if [ ! -z "$sambaPrimaryGroupSID" ]; then
  #echo $localSID-$sambaPrimaryGroupSID
  sed "s#UID#$uid#g" -i /tmp/$uuid/sambaPrimaryGroupSID$uid.ldif
  sed "s#SAMBAPRIMARYGROUPSID#$sambaPrimaryGroupSID#g" -i /tmp/$uuid/sambaPrimaryGroupSID$uid.ldif
  sed "s#LOCALSID#$localSID#g" -i /tmp/$uuid/sambaPrimaryGroupSID$uid.ldif
  ldapmodify -a -x -H ldapi:/// -D "cn=admin,dc=eea,dc=europa,dc=eu" -w $SLAPD_PASSWORD -f /tmp/$uuid/sambaPrimaryGroupSID$uid.ldif
fi

rm -f /tmp/$uuid/sambaSID$uid.ldif
rm -f /tmp/$uuid/sambaPrimaryGroupSID$uid.ldif
