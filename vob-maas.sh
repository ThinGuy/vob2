export LXD_DOMAIN=orangebox.me
export LXD_TZ='America/Los_Angeles'
export LXD_LANG='en_US.UTF-8'
export LXD_SEC_URI='http://us.archive.ubuntu.com/ubuntu'
export LXD_APT_URI='http://us.archive.ubuntu.com/ubuntu'
export LXD_IP='10.171.5.10/24'
export LXD_GW='10.171.5.1'
export LXD_DNS='10.171.5.1'
export LXD_BRIDGE='ob-ra01-rs01'
export LXD_PROFILE_NAME='ob-maas-ra01'

lxc 2>/dev/null profile delete ${LXD_PROFILE_NAME}
lxc 2>/dev/null profile delete ${LXD_PROFILE_NAME}
lxc profile create ${LXD_PROFILE_NAME}

cat <<EOF|sed '/^$/d;/^### ci-section/d;s/[ \t]*$//'|lxc profile edit ${LXD_PROFILE_NAME}
config:
  migration.incremental.memory: "true"
  linux.kernel_modules: ip_tables,ip6_tables
  raw.lxc: |
    lxc.apparmor.profile = unconfined
    lxc.mount.auto = proc:rw sys:rw cgroup:rw
    lxc.cap.drop = 
    lxc.cgroup.devices.allow = a
  security.privileged: "true"
  user.network-config: |
    version: 2
    ethernets:
      eth0:
        dhcp4: false
        dhcp6: false
    bridges:
      br0:
        interfaces: [eth0]
        dhcp4: false
        dhcp6: false
        optional: false
        addresses: [${LXD_IP}]
        gateway4: ${LXD_GW}
        nameservers:
          addresses: [${LXD_DNS}]
          search: [${LXD_DOMAIN}]
        parameters:
          priority: 1
          stp: False
          forward-delay: 0
  user.user-data: |
    #cloud-config
    timezone: ${LXD_TZ}
    locale: ${LXD_LANG}
    final_message: "${LXD_PROFILE_NAME} installation completed in \$UPTIME seconds"
    package_update: true
    package_upgrade: true
    packages: [postgresql, postgresql-contrib, postgresql-client, mlocate, jq]
    ca-certs:
      trusted: |
        -----BEGIN CERTIFICATE-----
        MIID6TCCAtGgAwIBAgIUMSsrjKj7dv4iDXP86w6wtenms1AwDQYJKoZIhvcNAQEL
        BQAwgYMxCzAJBgNVBAYTAlVTMRYwFAYDVQQIDA1NYXNzYWNodXNldHRzMRIwEAYD
        VQQHDAlMZXhpbmd0b24xDjAMBgNVBAoMBUNlcnRzMRowGAYDVQQLDBFTZWxmLVNp
        Z25lZCBDZXJ0czEcMBoGA1UEAwwTaW5mcmExLm9yYW5nZWJveC5tZTAeFw0xOTA5
        MjAxODU0MjlaFw0yOTA5MTcxODU0MjlaMIGDMQswCQYDVQQGEwJVUzEWMBQGA1UE
        CAwNTWFzc2FjaHVzZXR0czESMBAGA1UEBwwJTGV4aW5ndG9uMQ4wDAYDVQQKDAVD
        ZXJ0czEaMBgGA1UECwwRU2VsZi1TaWduZWQgQ2VydHMxHDAaBgNVBAMME2luZnJh
        MS5vcmFuZ2Vib3gubWUwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDH
        RPcoW+hGto2BDv6nrMkSKfqlUsFEpS5fx2ghpl7mVzbHVvRaSijM0EZ2yUjWY1F5
        2WZF/Qd20brZdTCdsEg1HSoVO1iBF7oy7l9QfFXdMcDw5goQajGw5hPPk6d0NPUn
        kNRVN//pXyyxtKFGJFXi/A76qGB2BHKB7rCM28HfS/gtFjTtlE45SacMudoHz3sr
        VIHZVJ73Or7rFROJpVavNT5a+NkWWepw0DDOmy03OiceIzek5Foi5q5X1D/dZb0E
        x8virzhc9BHt1eeBnlTgoK3hHM2iMNQ++S6LLfnfTHcZrD+JVGJE1eb3mw4HP1f9
        h1oF5uFFtCb+WxQ5SS6FAgMBAAGjUzBRMB0GA1UdDgQWBBQeP2lHMLmYjzNQfh8F
        vFxg/nUAljAfBgNVHSMEGDAWgBQeP2lHMLmYjzNQfh8FvFxg/nUAljAPBgNVHRMB
        Af8EBTADAQH/MA0GCSqGSIb3DQEBCwUAA4IBAQCJCdtDuDE1o62XwC9cybd0klvp
        HCpEQrZ6bTjiU6R0uG77KljMlrxkkJLEyKfFJRtZ9+v9L+YT5zp+YR/CX+3p5res
        k0uMMTdbo6HENIUGZtR4bvO1+sS34Fmo6iB2vz00QOxeZoFalltLDFp4ZXPvZz/1
        54dMSXO0Fxcnb0aEODwMIdx+PUHqBxWKDcnpNoeO4JVING29tYw356h6s+UiL2EA
        hrSYCdNuY15Ttu0KjAQALxpT9nyNX9OWEIWZnf9Xer0yRq3F2IDjDRAPgSQ0b8FW
        J4x1+aaXFcXzATZO1/pv8XAZoJtax8x0i/zOpojNjNLpXtN3WousoF4kNBK3
        -----END CERTIFICATE-----
    ssh_authorized_keys:
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDgxwRj4Nzva7052DBrmw+Ho1UA7zCmm0VtdyDeVXVT5aFUucxoqX4cVIf08/YU5mfpmH2+979cjo5QfLHKOlJx740UenO6VAjIY/6FBvJytBj2HoQ7LS04M1mrFaec/C0ocP/Un26ekPxk7lRpUDlX9ucmvu9yh5CQx4+HQVWKvj8pIwBLFFNh3vffIbN5n88SgqhmDfajAicqDtFiDgVtVKPOorTO3iJCW+Cammgy2qDT5rh7qm4kfEdnr2lbsuNYhV97X7f09Uw0xqMN4MPiJJBOo+9oB+/zkidbGTlVO8atWPWng1li/Y3LbPqAgH6WYpMoDF/qb7wcVAoEnus03ltXC34ABtl3vvP01sub4xuDUuNAEHWqdSarGvBfOEteRFTtWNb5CdBjytb1n6J82SlxgX6ZqB1mPxbZrMOwsy+6jHegs7sEHaSvOIRmjfMSUtRt/s37AUr+7ogNefQE5c2eITWs22yX2nNI0lT0xHQ4Fp6j6AIBMuma8SqA9pU= ubuntu@vob
$(find ~/.ssh -iname "*.pub"|xargs -n1 -P1 bash -c 'printf -- "      - %s\n" "$(cat $0)"')  
    apt:
      conf: |
        APT {
          Get {
            Assume-Yes "true";
            Fix-Broken "true";
          };
        };
      primary:
        - arches: [amd64]
          uri: ${LXD_APT_URI}
      security:
        - arches: [amd64]
          uri: ${LXD_SEC_URI}
      sources_list: |
        deb \$PRIMARY \$RELEASE main universe restricted multiverse
        deb \$PRIMARY \$RELEASE-updates main universe restricted multiverse
        deb \$PRIMARY \$RELEASE-backports main universe restricted multiverse
        deb \$SECURITY \$RELEASE-security main universe restricted multiverse   
    bootcmd:
      - set -x
      - [ cloud-init-per, once, aupdate, apt, update, -qq ]
      - [ cloud-init-per, once, isquashfuse, apt, install, squashfuse, -yqq ]
      - [ cloud-init-per, once, rlxd, apt, purge, lxd\\*, -yqq ]
      - [ cloud-init-per, once, aremove, apt, autoremove, -yq ]
    runcmd:
      - set -x
      - sed '1s|PATH=\x22|&/snap/bin\x3a|g' /etc/environment
      - . /etc/environment
      - su - $(id -un 1000) -c 'printf "y\n"|ssh-keygen -f ~/.ssh/id_rsa -P ""'
      - su - $(id -un 1000) -c 'cat ~/.ssh/id_rsa.pub >>  ~/.ssh/authorized_keys'
      - echo -en 'net.ipv4.ip_forward = 1\nnet.ipv4.conf.all.accept_redirects = 1\nnet.ipv6.conf.all.disable_ipv6 = 1\nnet.ipv6.conf.default.disable_ipv6 = 1\nnet.ipv6.conf.lo.disable_ipv6 = 1\n' >> /etc/sysctl.conf
      - sysctl -p /etc/sysctl.conf
      - echo -en '#!/bin/bash\n# /etc/rc.local\n\n/etc/sysctl.d\n/etc/init.d/procps restart\n\nexit 0\n' > /etc/rc.local
      - chmod +x /etc/rc.local
      - curl -sSlL http://resource-server.orangebox.me/v2/auth/store/assertions | snap ack /dev/stdin
      - snap set core proxy.store=ncy6sJdPbVbamjpKnUY10jer4Mr5wIDP
      - |-
        cat <<EOS|tee -a /home/ubuntu/.ssh/config
        Host 10.171.*.* ob-ra0?-rs0?.${LXD_DOMAIN} ob-ra0?-rs0? ob-maas-ra0?.${LXD_DOMAIN} ob-maas-ra0?
          AddressFamily inet
          CheckHostIP no
          ForwardX11Trusted yes
          ForwardX11 yes
          IdentityFile /home/ubuntu/.ssh/id_rsa
          LogLevel FATAL
          SendEnv LANG LC_*
          StrictHostKeyChecking no
          UserKnownHostsFile /dev/null
          User ubuntu
          XAuthLocation /usr/bin/xauth
        EOS
      - |-
        cat <<EOP|tee -a /etc/postgresql/\${PGSQL_VER}/main/pg_hba.conf
        host replication postgres $(hostname -i)/32 reject
        host replication postgres $(hostname -s) reject
        host replication postgres 10.171.0.0/16 trust
        host maasdb maas 0/0 md5
        EOP
      - |-
        cat <<EOC|tee -a /etc/postgresql/\${PGSQL_VER}/main/postgresql.conf
        listen_addresses = '*'
        max_connections = 400
        wal_level = hot_standby
        synchronous_commit = on
        archive_mode = on
        archive_command = 'test ! -f /var/lib/postgresql/\${PGSQL_VER}/main/pg_archive/%f && cp %p /var/lib/postgresql/\${PGSQL_VER}/main/pg_archive/%f'
        max_wal_senders = 10
        wal_keep_segments = 256
        hot_standby = on
        restart_after_crash = off
        hot_standby_feedback = on
        EOC
      - |-
        cat <<EOH|tee /etc/hosts
        127.0.0.1 localhost
        10.171.5.10 ob-maas-ra01.${LXD_DOMAIN} ob-maas-ra01
        10.171.6.10 ob-maas-ra02.${LXD_DOMAIN} ob-maas-ra02
        EOH
      - bash -c 'ssh-keyscan -H ob-maas-ra01.${LXD_DOMAIN},10.171.5.10|tee -a ~/.ssh/known_hosts'
      - bash -c 'ssh-keyscan -H ob-maas-ra02.${LXD_DOMAIN},10.171.6.10|tee -a ~/.ssh/known_hosts'
description: MAAS Profile for Virtual Orangebox
devices:
  aadisable:
    path: /sys/module/nf_conntrack/parameters/hashsize
    source: /dev/null
    type: disk
  aadisable1:
    path: /sys/module/apparmor/parameters/enabled
    source: /dev/null
    type: disk
  eth0:
    name: eth0
    nictype: bridged
    parent: ${LXD_BRIDGE}
    type: nic
  kvm:
    path: /dev/kvm
    type: unix-char
  mem:
    path: /dev/mem
    type: unix-char
  tun:
    path: /dev/net/tun
    type: unix-char
  vhost-net:
    mode: "0600"
    path: /dev/vhost-net
    type: unix-char
  root:
    path: /
    pool: default
    type: disk
name: ${LXD_PROFILE_NAME}
EOF
