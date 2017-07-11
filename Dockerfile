FROM centos:7

MAINTAINER michimau <mauro.michielon@eea.europa.eu>

RUN yum install -y samba \
                   samba-client \
                   samba-common \
                   libnss-ldap \
                   libpam-ldap \
                   nss-pam-ldapd \
                   python-setuptools \
                   openldap-servers \
                   openldap-clients \
                   smbldap-tools \
                   vim 

RUN easy_install supervisor
#RUN yum -y --enablerepo=extras install epel-release then yum install smbldap-tools

COPY supervisord.conf /etc/supervisord.conf

#COPY smb.conf /etc/samba/smb.conf
COPY nsswitch.conf /etc/nsswitch.conf
COPY nslcd.conf /etc/nslcd.conf
COPY system-auth /etc/pam.d/system-auth
COPY password-auth /etc/pam.d/password-auth

RUN mkdir -p /etc/supervisor.d
RUN mkdir -p /var/log/supervisor

COPY supervisor-slapd.conf /etc/supervisor.d/supervisor-slapd.conf
COPY supervisor-updatesid.conf /etc/supervisor.d/supervisor-updatesid.conf
COPY supervisor-smb.conf /etc/supervisor.d/supervisor-smb.conf
COPY supervisor-nslcd.conf /etc/supervisor.d/supervisor-nslcd.conf

COPY sambaPrimaryGroupSID.ldif /sambaPrimaryGroupSID.ldif
COPY sambaSID.ldif /sambaSID.ldif
COPY updateSID.sh /updateSID.sh
COPY changeSlapdPassword.ldif /changeSlapdPassword.ldif

ADD container-files /

ADD run.sh /
RUN chmod 755 /*.sh

EXPOSE 137/udp 138/udp 139 445 389

ENTRYPOINT ["/config/bootstrap.sh"]
