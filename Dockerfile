
FROM ubuntu:16.04

LABEL maintainer "Peter Rosell <peter.rosell@gmail.com>"

# install openvpn and yubico pam module
RUN . /etc/lsb-release && \
    echo "deb http://ppa.launchpad.net/yubico/stable/ubuntu $DISTRIB_CODENAME main" >> /etc/apt/sources.list && \
    echo "deb-src http://ppa.launchpad.net/yubico/stable/ubuntu $DISTRIB_CODENAME main " >> /etc/apt/sources.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 32CBA1A9 && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        nano \
        curl \
        libcurl3 \
        inetutils-syslogd \
        libpam-ldap \
        libpam-radius-auth \
        libpam-yubico \
    && \
    apt-get clean autoclean && apt-get autoremove -y && rm -rf /var/lib/{apt,dpkg,cache,log}/

RUN . /etc/lsb-release && \
    curl -s https://swupdate.openvpn.net/repos/repo-public.gpg | apt-key add && \
    echo "deb http://build.openvpn.net/debian/openvpn/stable $DISTRIB_CODENAME main" > /etc/apt/sources.list.d/openvpn-aptrepo.list && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        openvpn \
        iptables \
        git \
    && \
    apt-get clean autoclean && apt-get autoremove -y && rm -rf /var/lib/{apt,dpkg,cache,log}/

# Get easy-rsa
RUN git clone https://github.com/OpenVPN/easy-rsa.git /tmp/easy-rsa && \
    cd && \
# Cleanup
    rm -rf /tmp/easy-rsa/.git && cp -a /tmp/easy-rsa /usr/local/share/ && \
    rm -rf /tmp/easy-rsa/ && \
    ln -s /usr/local/share/easy-rsa/easyrsa3/easyrsa /usr/local/bin && \
    chmod 774 /usr/local/bin/*

# Enable these copy commands if you want to used libraries from source
#COPY --from=pam_yubikey /usr/local/lib/security/pam_yubico.so /lib/security/
#COPY --from=pam_yubikey /usr/local/lib/libykclient.so.3 /usr/lib/
#COPY --from=pam_yubikey /usr/local/lib/libykclient.so.3.6.0 /usr/lib/
#COPY --from=pam_yubikey /usr/local/lib/libykpers-1.so.1 /usr/lib/
#COPY --from=pam_yubikey /usr/local/lib/libykpers-1.so.1.18.1 /usr/lib/
#COPY --from=pam_yubikey /usr/local/lib/libyubikey.so.0 /usr/lib/
#COPY --from=pam_yubikey /usr/local/lib/libyubikey.so.0.1.8 /usr/lib/

# Needed by scripts
ENV OPENVPN=/etc/openvpn \
    EASYRSA=/usr/local/share/easy-rsa/easyrsa3 \
    EASYRSA_PKI=/etc/openvpn/pki \
    EASYRSA_VARS_FILE=/etc/openvpn/vars

VOLUME ["/etc/openvpn"]

EXPOSE 1194/udp

WORKDIR /etc/openvpn
CMD ["startopenvpn"]

ADD bin /usr/local/bin
ADD package /
