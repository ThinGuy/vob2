make-lxd-maas() {
lxc 2>/dev/null delete ${LXD_PROFILE_NAME} --force
lxc 2>/dev/null delete ${LXD_PROFILE_NAME} --force
lxc 2>/dev/null profile delete ${LXD_PROFILE_NAME}
lxc 2>/dev/null profile delete ${LXD_PROFILE_NAME}
lxc profile create ${LXD_PROFILE_NAME}

cat <<EOF|lxc profile edit ${LXD_PROFILE_NAME}
config:
  migration.incremental.memory: "true"
  linux.kernel_modules: ip_tables,ip6_tables,netlink_diag,nf_nat,overlay,vhost,vhost_net,openvswitch
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
        addresses: [${LXD_IPV4_CIDR}]
        gateway4: ${LXD_IPV4_GW}
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
    packages: [maas-common, prips, apt-utils, postgresql, postgresql-contrib, locate, repmgr]
    write_files:
    -   encoding: b64
        content: ${RSA_KEY}
        path: /var/tmp/.ssh/id_rsa
        permissions: '0600'
        owner: root:root
    -   encoding: b64
        content: ${RSA_PUB}
        path: /var/tmp/.ssh/id_rsa.pub
        permissions: '0640'
        owner: root:root
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
      - ${RSA_PUB_RAW}
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
      sources:
        maas-next-proposed.list:
          source: deb http://ppa.launchpad.net/maas/2.7ubuntu \$RELEASE main
          key: |
            -----BEGIN PGP PUBLIC KEY BLOCK-----
            
            mQINBFXVlyMBEACqM3iz2EGJE0iE3/AAbNCnbBB25m3AWaSxJk+GJfkAAYWGqAKi
            uWceCcetdNKNTKd8frSZFsRB7IceZr0u5sWpSYur6uoMNHzS8Y5cGdyAVrnEZtbd
            ak652x13jlX7nrcE9g//lD0w254XW1Loyy5YOGWfUmJkGImndFWtkqd1J7SCVMMW
            5l/nS4LwsOx/wTxL5m/cFQLi67JyJGqszKXS88oHT1YFBWPyl1VcXifFwecH/32f
            Rr6WGpEAaxGF4dO45WGvJIQs2yiT5f9ha3tuJCbzI58t9BxiR1MMZ9AAPjdNO6JZ
            kX2q+/uqgJg9IWNcJ4E+fCgl/hvoB3AURXHmaagH7nMb/6OA/QFSbiR3eciSJ89c
            EkK+7d0br+p2+shO/dOV6lUrbidVVjiiTdmYlyXzuPcvPWVYmXjDzsOi0sSZZNMq
            8G3/pAavjyGUvZtb781V1j9/8l3o5ScAPzzamT2W4rF+nCh1iHYz7+wP2XDNifE/
            oK7fLNb0ig1G5S4PCqZHUp95LUaJrFczYCPwlERUxIC3B9a+UC3SdZmRuuSENWNs
            YxKUlbU07GCrjxtcDhQHGQDVJDUGbqqkA4B/iKrwW3reA5fHo3yocQMX7YR6C2/Q
            n+wn/EoEPIB1wkzAQvarnNCCdwjD5AB1VhANEFwUKMWHDEsofKOSTBYvgQARAQAB
            tBZMYXVuY2hwYWQgUFBBIGZvciBNQUFTiQI4BBMBAgAiBQJV1ZcjAhsDBgsJCAcD
            AgYVCAIJCgsEFgIDAQIeAQIXgAAKCRAE5/3FaE1KHDH8D/9Mdc+4tw8foj6lILCg
            fBRi9S37tOyV2m5YvD+qRzefUYgFKXYxleO+H9cjFH2XyHIBwa15dD/Yg+DkcAKb
            9f/a1llHNTzLkHiNVQl4tl8qeJPj2Obm53HsjhazIgh0L208GRGJxO4HSBbrBTo8
            FNF00Cl52josZdG1mPCSDuJm1AkeY9q4WeAOnekquz2qjUa+L8J8z+HVPC9rUryE
            NXdwCyh3TE0G0occjUAsb5oOu3bcKSbVraq+trhjp9sz7o7O4lc4+cT2gFIWl1Rp
            1djzXH8flU/s3U1vl0RcIFEZbuqsuDWukpxozq4M5y7VKq4y5dq7Y0PbMuJ0Dvgn
            Bn4fbboMji4LYfgn++vosZv/MXkPIg6wubxdejVdrEoFRFxCcYqW4wObY8vxrvDr
            Mjp4HrQ2guN8OJDUYnLdVv9P1MMKDAMrDjRdy3NsBpd7GuA9hXRXBPZ8y74nIwCR
            jEDnIz5jsws9PxZIVabieoCI6RibJMw8qpuicM97Ss2Uq5vURvTBQ3f6wYjCMsdt
            yqjz6TVJ3zwK9NPfMhXGVrrsxBOxO382r6XXuUbTcXZTDjAkoMsBqfjidlGDGTb3
            Un0LkZJfpXrmZehyvO/GlsoYiFDhGf+EXJzKwRUEuJlIkVEZ72OtuoUMoBrjuADR
            lJQUW0ZbcmpOxjK1c6w08nhSvA==
            =QeWQ
            -----END PGP PUBLIC KEY BLOCK-----      
    bootcmd:
      - set -x
      - [ cloud-init-per, once, aupdate, apt, update, -qq ]
      - [ cloud-init-per, once, isquashfuse, apt, install, squashfuse, -yqq ]
      - [ cloud-init-per, once, rlxd, apt, purge, lxd\\*, -yqq ]
      - [ cloud-init-per, once, aremove, apt, autoremove, -yq ]
    runcmd:
      - set -x
      - curl -sSlL http://resource-server.orangebox.me/v2/auth/store/assertions | snap ack /dev/stdin
      - snap set core proxy.store=5chsmuZltMQH8CxQ1Q0br5T604V7DkkF
      - snap refresh core --edge
      - virsh net-destroy default && virsh net-undefine default
      - |-
        cat <<EOS|tee -a /home/ubuntu/.ssh/config
        Host 10.0.0.* maas01 maas02 maas03
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
      - snap install keepalived --candidate --classic
      - |-
        cat <<EOK|tee /etc/keepalived/keepalived.conf
        ! Configuration file for keepalived on ${LXD_PROFILE_NAME}
        global_defs {
           notification_email {
             sysadmin@${LXD_DOMAIN}
           }
           notification_email_from ${LXD_PROFILE_NAME}@${LXD_DOMAIN}
           smtp_server localhost
           smtp_connect_timeout 30
        }
        
        vrrp_instance maasdb {
            state MASTER
            interface br0
            virtual_router_id 69
            priority $((104-(10#${LXD_PROFILE_NAME//maas/})))
            advert_int 1
            authentication {
                auth_type PASS
                auth_pass ubuntu4maas
            }
            virtual_ipaddress {
                ${LXD_PG_VIP}
            }
        }
        EOK
      - snap restart keepalived.daemon
      - updatedb
      - export PGSQL_VER="\$(\$(locate bin/postgres) -V|awk '{split(\$3,a,/\./);print a[1]}')"
      - systemctl stop postgresql
      - echo manual > /etc/postgresql/\${PGSQL_VER}/main/start.conf
      - if [ "\$(hostname -s)" = "maas01" ];then pg_ctlcluster \${PGSQL_VER} main start;fi
      - if [ "\$(hostname -s)" = "maas01" ];then su postgres -c 'cd /var/lib/postgresql;psql -c "CREATE ROLE repuser PASSWORD '"'"'md58ab1a75fe519fbd497653a855134aef7'"'"' NOSUPERUSER NOCREATEDB NOCREATEROLE INHERIT LOGIN REPLICATION CONNECTION LIMIT 10"';fi
      - |-
        cat <<EOP|tee -a /etc/postgresql/\${PGSQL_VER}/main/pg_hba.conf
        host replication repuser 10.0.0.10/32 md5
        host replication repuser 10.0.0.11/32 md5
        host replication repuser 10.0.0.12/32 md5
        host replication repuser 10.0.0.13/32 md5
        host maasdb maas 10.0.0.10/32 md5
        host maasdb maas 10.0.0.11/32 md5
        host maasdb maas 10.0.0.12/32 md5
        host maasdb maas 10.0.0.13/32 md5
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
        shared_preload_libraries = 'repmgr_funcs'
        EOC
      - install -o postgres -g postgres -m 0700 -d /var/lib/postgresql/\${PGSQL_VER}/main/pg_archive
      - install -o postgres -g postgres -m 0700 -d /var/lib/postgresql/\${PGSQL_VER}/tmp
      - install -o postgres -g postgres -m 0600 /dev/null /var/lib/postgresql/\${PGSQL_VER}/tmp/rep_mode.conf
      - if [ -d /var/lib/postgresql/\${PGSQL_VER}/main.bak -a "\$(hostname -s)" != "maas01" ];then rm -rf /var/lib/postgresql/\${PGSQL_VER}/main.bak;fi
      - if [ -d /var/lib/postgresql/\${PGSQL_VER}/main -a "\$(hostname -s)" != "maas01" ];then mv /var/lib/postgresql/\${PGSQL_VER}/main /var/lib/postgresql/\${PGSQL_VER}/main.bak;fi
      - if [ "\$(hostname -s)" = "maas01" ];then pg_ctlcluster \${PGSQL_VER} main restart;fi
      - if [ "\$(hostname -s)" = "maas02" -o "\$(hostname -s)" = "maas03" ];then su -u postgres -c 'pg_basebackup -h 10.0.0.11 -D /var/lib/postgresql/\${PGSQL_VER}/main -v --wal-method=stream';fi
      - cp -a /var/tmp/.ssh/id* /home/ubuntu/.ssh/
      - rm -rf /var/tmp/.ssh
      - chown -R ubuntu:ubuntu /home/ubuntu/.ssh
      - chmod 0760 /home/ubuntu/.ssh
      - |-
        cat <<EOH|tee /etc/hosts
        127.0.0.1 localhost
        10.0.0.5 maas.${LXD_DOMAIN} maas
        10.0.0.10 maas-db.${LXD_DOMAIN} maas-db
        10.0.0.11 maas01.${LXD_DOMAIN} maas01
        10.0.0.12 maas02.${LXD_DOMAIN} maas02
        10.0.0.13 maas03.${LXD_DOMAIN} maas03
        # The following lines are desirable for IPv6 capable hosts
        ::1 ip6-localhost ip6-loopback
        fe00::0 ip6-localnet
        ff00::0 ip6-mcastprefix
        ff02::1 ip6-allnodes
        ff02::2 ip6-allrouters
        ff02::3 ip6-allhosts
        EOH
      - bash -c 'ssh-keyscan -H maas0{1,2,3}.${LXD_DOMAIN},10.0.0.1{1,2,3}|tee -a ~/.ssh/known_hosts'
      - apt-add-repository ppa:maas/2.7 -y
      - if [ "\$(hostname -s)" = "maas01" ];then apt install maas -yq;fi
      - if [ "\$(hostname -s)" = "maas02" -o "\$(hostname -s)" = "maas03" ];then apt install -yq maas-common;fi
      - if [ "\$(hostname -s)" = "maas02" -o "\$(hostname -s)" = "maas03" ];then apt install -yq maas-region-api maas-rack-controller;fi
      - maas-region local_config_set --database-host ${LXD_PG_VIP}
      - sed 's|- http://localhost:5240/MAAS|- http://10.0.0.11:5240/MAAS\n- http://10.0.0.12:5240/MAAS\n- http://10.0.0.13:5240/MAAS\n|g' -i /etc/maas/rackd.conf
description: lxd profile for HA MAAS
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
    parent: ${LXD_USE_BRIDGE}
    type: nic
  mem:
    path: /dev/mem
    type: unix-char
  root:
    path: /
    pool: z-pool
    type: disk
name: ${LXD_PROFILE_NAME}
EOF
}

printf 'y\n'|ssh-keygen 1>/dev/null -t rsa -f /tmp/virtual-orangebox_rsa -P "" -C ubuntu@${LXD_DOMAIN}
export RSA_KEY="$(base64 -w0 /tmp/virtual-orangebox_rsa)"
export RSA_PUB="$(base64 -w0 /tmp/virtual-orangebox_rsa.pub)"
export RSA_PUB_RAW="$(cat /tmp/virtual-orangebox_rsa.pub)"
cat /tmp/virtual-orangebox_rsa.pub|tee -a ~/.ssh/authorized_keys
rm -f /tmp/virtual-orangebox_rsa*
export LXD_PG_VIP=10.0.0.10
export LXD_IPV4_GW=10.0.0.254
export LXD_DNS=172.27.20.1
export LXD_DOMAIN=orangebox.me
export LXD_TZ='America/Los_Angeles'
export LXD_LANG='en_US.UTF-8'
export LXD_USE_BRIDGE='maas-br0'
export LXD_APT_URI=http://ubuntu-archive.orangebox.me/ubuntu
export LXD_SEC_URI=http://ubuntu-archive.orangebox.me/ubuntu
export LXD_IPV4_CIDR=10.0.0.11/24
export LXD_USE_BRIDGE='maas-br0'
export LXD_PROFILE_NAME='maas01'
make-lxd-maas
export LXD_IPV4_CIDR=10.0.0.12/24
export LXD_USE_BRIDGE='maas-br0'
export LXD_PROFILE_NAME='maas02'
make-lxd-maas
export LXD_IPV4_CIDR=10.0.0.13/24
export LXD_USE_BRIDGE='maas-br0'
export LXD_PROFILE_NAME='maas03'
make-lxd-maas
printf '%02d\n' {1..3}|xargs -rn1 -P1 bash -c 'lxc launch local:b maas${0} -p maas${0}'
sleep 15
bash -c 'lxc exec maas01 -- sh -c '"'"'tail -n +0 --pid=$$ -f /var/log/cloud-init-output.log | { sed "/installation completed in/ q" && kill $$ ;}'"'"''
bash -c 'lxc exec maas02 -- sh -c '"'"'tail -n +0 --pid=$$ -f /var/log/cloud-init-output.log | { sed "/installation completed in/ q" && kill $$ ;}'"'"''
bash -c 'lxc exec maas03 -- sh -c '"'"'tail -n +0 --pid=$$ -f /var/log/cloud-init-output.log | { sed "/installation completed in/ q" && kill $$ ;}'"'"''

