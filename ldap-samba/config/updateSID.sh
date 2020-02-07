#!/bin/bash

echo  'sldap started'

DATE=$(date +"%Y%m%d%H%M")
#slapcat -n 0 | gzip -9 > $BACKUPDIR/$DATE-config.ldif.gz
#slapcat -n 1 | gzip -9 > $BACKUPDIR/$DATE-data.ldif.gz
uuid=$(uuidgen)
mkdir -p /tmp/$uuid

while true; do
  out="`ldapsearch -x -LLL -h localhost -b sambaDomainName=GAUR,ou=Domains,dc=eea,dc=europa,dc=eu | grep sambaMinPwdAge | wc -c 2>&1`"
  #echo -e $out
  if [ $out -ne 0 ]; then
    echo  'sldap started'
    break
  fi
  echo -e "\nLDAP server still isn't up, waiting ...\n"
  sleep 3
done

if [ ! -z "$sambaPrimaryGroupSID" ]; then
   HASHSLAPDPASSWORD=$(slappasswd -s $SLAPD_PASSWORD)
   cp -rf changeSlapdPassword.ldif /tmp/$uuid/changeSlapdPasswordInstance.ldif
   sed "s#HASHSLAPDPASSWORD#$HASHSLAPDPASSWORD#g" -i /tmp/$uuid/changeSlapdPasswordInstance.ldif
   ldapadd -Y EXTERNAL -H ldapi:/// -f /tmp/$uuid/changeSlapdPasswordInstance.ldif
fi 

localSID=$(sudo net getlocalsid | awk -F ' ' '{print $6}')
echo localSID: $localSID
ldapsearch -x -LLL -h localhost -b"ou=Users,dc=eea,dc=europa,dc=eu" | awk -F ' ' '/uid:/ {print $2}' > /tmp/$uuid/ldapusers.txt

while read uid; do
  #echo $uid
  #sleep 1
  cp sambaSID.ldif /tmp/$uuid/sambaSID$uid.ldif
  cp sambaPrimaryGroupSID.ldif /tmp/$uuid/sambaPrimaryGroupSID$uid.ldif

  sambaSID=$(ldapsearch -x -LLL -h localhost -b"ou=Users,dc=eea,dc=europa,dc=eu" -s sub "uid=$uid" | awk -F ' ' '/sambaSID/ {print $2}' | tail -c 5)
  #echo "sambaSID: ${sambaSID}"
  sambaPrimaryGroupSID=$(ldapsearch -x -LLL -h localhost -b"ou=Users,dc=eea,dc=europa,dc=eu" -s sub "uid=$uid" | awk -F ' ' '/gidNumber/ {print $2}' | tail -c 4)
  #echo "sambaPrimaryGroupSID: ${sambaPrimaryGroupSID}"

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

  sambaSID=''
  sambaPrimaryGroupSID=''
 
  #rm -f /tmp/$uuid/sambaSID$uid.ldif
  #rm -f /tmp/$uuid/sambaPrimaryGroupSID$uid.ldif

done </tmp/$uuid/ldapusers.txt
