#!/bin/bash

while [ $(ps -ef | grep slapd | wc -l) -lt 2 ]; do
  echo  'waiting for sldap to be up  - sleeping 5'
  sleep 5
done

DATE=$(date +"%Y%m%d%H%M")
slapcat -n 0 | gzip -9 > $BACKUPDIR/$DATE-config.ldif.gz
slapcat -n 1 | gzip -9 > $BACKUPDIR/$DATE-data.ldif.gz

HASHSLAPDPASSWORD=$(slappasswd -s $SLAPD_PASSWORD)
cp changeSlapdPassword.ldif changeSlapdPasswordInstance.ldif
sed "s#HASHSLAPDPASSWORD#$HASHSLAPDPASSWORD#g" -i changeSlapdPasswordInstance.ldif

ldapadd -Y EXTERNAL -H ldapi:/// -f changeSlapdPasswordInstance.ldif

localSID=$(net getlocalsid | awk -F ' ' '{print $6}')
#echo $localSID
ldapsearch -x -LLL -h localhost -b"ou=Users,dc=eea,dc=europa,dc=eu" | awk -F ' ' '/uid/ {print $2}' > /tmp/ldapusers.txt

while read uid; do
  echo $uid
  cp sambaSID.ldif sambaSID$uid.ldif
  cp sambaPrimaryGroupSID.ldif sambaPrimaryGroupSID$uid.ldif

  sambaSID=$(ldapsearch -x -LLL -h localhost -b"ou=Users,dc=eea,dc=europa,dc=eu" -s sub "uid=$uid" | awk -F ' ' '/sambaSID/ {print $2}' | tail -c 5)
  #echo "sambaSID: ${sambaSID}"
  sambaPrimaryGroupSID=$(ldapsearch -x -LLL -h localhost -b"ou=Users,dc=eea,dc=europa,dc=eu" -s sub "uid=$uid" | awk -F ' ' '/gidNumber/ {print $2}' | tail -c 4)
  #echo "sambaPrimaryGroupSID: ${sambaPrimaryGroupSID}"

  if [ ! -z "$sambaSID" ]; then
    echo $localSID-$sambaSID
    sed "s#UID#$uid#g" -i sambaSID$uid.ldif
    sed "s#SAMBASID#$sambaSID#g" -i sambaSID$uid.ldif
    sed "s#LOCALSID#$localSID#g" -i sambaSID$uid.ldif
    ldapmodify -a -x -H ldapi:/// -D "cn=admin,dc=eea,dc=europa,dc=eu" -w $SLAPD_PASSWORD -f sambaSID$uid.ldif
  fi

  if [ ! -z "$sambaPrimaryGroupSID" ]; then
    echo $localSID-$sambaPrimaryGroupSID
    sed "s#UID#$uid#g" -i sambaPrimaryGroupSID$uid.ldif
    sed "s#SAMBAPRIMARYGROUPSID#$sambaPrimaryGroupSID#g" -i sambaPrimaryGroupSID$uid.ldif
    sed "s#LOCALSID#$localSID#g" -i sambaPrimaryGroupSID$uid.ldif
    ldapmodify -a -x -H ldapi:/// -D "cn=admin,dc=eea,dc=europa,dc=eu" -w $SLAPD_PASSWORD -f sambaPrimaryGroupSID$uid.ldif
  fi

  sambaSID=''
  sambaPrimaryGroupSID=''
 
  rm -f sambaSID$uid.ldif
  rm -f sambaPrimaryGroupSID$uid.ldif
  #rm -f $uid.ldif
done </tmp/ldapusers.txt
