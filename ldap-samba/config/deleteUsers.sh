#!/bin/bash

echo user > allowedUsers.txt

ldapsearch -D "cn=Accounts browser,o=EIONET,l=Europe" -w $CENTRAL_LDAP_PASSWORD -H ldaps://$CENTRAL_LDAP_URL  -b "cn=eea-staff,cn=eea,ou=Roles,o=EIONET,l=Europe" | grep uniqueMember|  awk '/ / {print $2}' | sed -e 's/uid=\(.*\),ou=Users,o=EIONET,l=Europe/\1/' >> allowedUsers.txt

ldapsearch -D "cn=Accounts browser,o=EIONET,l=Europe" -w $CENTRAL_LDAP_PASSWORD -H ldaps://$CENTRAL_LDAP_URL  -b "cn=eionet-group-sdi,cn=eionet-group,cn=eionet,ou=Roles,o=EIONET,l=Europe" | grep uniqueMember|  awk '/ / {print $2}' | sed -e 's/uid=\(.*\),ou=Users,o=EIONET,l=Europe/\1/' >> allowedUsers.txt

echo user > sdiUsers.txt
ldapsearch -x -LLL -h localhost -b "ou=Users,dc=eea,dc=europa,dc=eu" | grep uid= |  awk '/ / {print $2}' | sed -e 's/uid=\(.*\),ou=Users,dc=eea,dc=europa,dc=eu/\1/' >> sdiUsers.txt

NUMUSERS="$( wc -l allowedUsers.txt  | awk '/ / {print $1}')"
#echo $NUMUSERS

if [ $NUMUSERS \> 1 ];
then
  q -H -t "select a.user from sdiUsers.txt as a where a.user not in (select b.user from allowedUsers.txt as b)" > usersToDelete.txt

  while read user; do
    echo "deleting: " $user
    ldapdelete  -D "cn=admin,dc=eea,dc=europa,dc=eu" -w $SLAPD_PASSWORD -H ldap:// "uid=$user,ou=Users,dc=eea,dc=europa,dc=eu"
  done <usersToDelete.txt
else
  echo "no users from Ldap, aborted"
fi;
