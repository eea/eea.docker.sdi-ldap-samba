FROM debian:12.5

MAINTAINER dpopescu22 <daniel.popescu@eaudeweb.ro>

RUN apt-get update
RUN apt-get install -y samba \
                   samba-client \
                   samba-common \
                   libnss-ldap \
                   libpam-ldap \
#                   nss-pam-ldapd \
                   python3-setuptools \
#                   openldap-servers \
                   slapd \
#                   openldap-clients \
                   ldap-utils \
                   smbldap-tools \
                   vim \
                   apache2 \
                   php \
                   php-ldap \
#                   mod_ssl \
#                   mod_ldap \
                   sudo \
                   expect \
		   supervisor \
		   python3-q-text-as-data \
		   uuid-runtime

#RUN sed -i 's/index.html/index.php/g' /etc/httpd/conf/httpd.conf
COPY config/sambaPrimaryGroupSID.ldif config/sambaSID.ldif config/changeSlapdPassword.ldif config/updateSID.sh config/updateSingleSID.sh config/deleteUsers.sh config/smbldap_bind.conf entrypoint.sh run.sh /

RUN mkdir -p /etc/supervisor.d
RUN mkdir -p /var/log/supervisor

#COPY smb.conf /etc/samba/smb.conf
COPY config/nsswitch.conf config/nslcd.conf /etc/

COPY config/system-auth config/password-auth /etc/pam.d/
COPY config/index.php config/auth.php config/samba.css /var/www/html/

COPY config/supervisord.conf /etc/supervisord.conf
COPY  config/supervisor-nslcd.conf \
      config/supervisor-slapd.conf \
      config/supervisor-smb.conf \
      config/supervisor-httpd.conf \
      config/supervisor-updatesid.conf \
      /etc/supervisor.d/

COPY config/smbldap-passwd-wrapper /usr/local/sbin/smbldap-passwd-wrapper

RUN echo 'apache  ALL = NOPASSWD: /usr/local/sbin/smbldap-passwd-wrapper' >> /etc/sudoers
RUN echo 'apache  ALL = NOPASSWD: /usr/sbin/smbldap-useradd' >> /etc/sudoers
RUN echo 'apache  ALL = NOPASSWD: /usr/bin/net' >> /etc/sudoers

RUN echo 'Defaults:apache !requiretty' >> /etc/sudoers
RUN echo 'apache  ALL = NOPASSWD: SAMBA' >> /etc/sudoers

RUN chmod 755 /*.sh

EXPOSE 137/udp 138/udp 139 445 389 80 443

ENTRYPOINT ["/run.sh"]
