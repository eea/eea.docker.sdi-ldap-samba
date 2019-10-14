FROM centos:7

MAINTAINER michimau <mauro.michielon@eea.europa.eu>

RUN yum install -y epel-release
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
                   vim \
                   httpd \
                   php \
                   php-ldap \
                   mod_ssl \
                   mod_ldap \
                   sudo \
                   expect

RUN easy_install supervisor

RUN mkdir -p /etc/supervisor.d
RUN mkdir -p /var/log/supervisor

#COPY smb.conf /etc/samba/smb.conf
COPY config/nsswitch.conf /etc/nsswitch.conf
COPY config/nslcd.conf /etc/nslcd.conf
COPY config/system-auth /etc/pam.d/system-auth
COPY config/password-auth /etc/pam.d/password-auth
COPY config/index.php config/auth.php /var/www/html/

RUN sed -i 's/index.html/index.php/g' /etc/httpd/conf/httpd.conf
#COPY q-text/q-text-as-data-1.7.1-1.noarch.rpm /q-text-as-data.rpm
COPY q-text/q-text-as-data-1.7.1-1.noarch.rpm config/sambaPrimaryGroupSID.ldif config/sambaSID.ldif config/changeSlapdPassword.ldif config/updateSID.sh config/deleteUsers.sh entrypoint.sh /
RUN rpm -ivh /q-text-as-data-1.7.1-1.noarch.rpm

COPY config/supervisord.conf /etc/supervisord.conf
COPY  config/supervisor-nslcd.conf \
      config/supervisor-slapd.conf \
      config/supervisor-smb.conf \
      config/supervisor-httpd.conf \
      config/supervisor-updatesid.conf \
      /etc/supervisor.d/

COPY config/smbldap-passwd-wrapper /usr/local/sbin/smbldap-passwd-wrapper

RUN echo 'Defaults:apache !requiretty' >> /etc/sudoers
RUN echo 'apache  ALL = NOPASSWD: /usr/local/sbin/smbldap-passwd-wrapper' >> /etc/sudoers

COPY run.sh /

RUN chmod 755 /*.sh

EXPOSE 137/udp 138/udp 139 445 389 80 443

ENTRYPOINT ["/run.sh"]
