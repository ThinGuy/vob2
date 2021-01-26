
update-lxd-maas-profile() {
cat <<EOF|lxc profile edit ${LXD_PROFILE_NAME}
config:
  migration.incremental.memory: "true"
  raw.lxc: |-
    lxc.cgroup.devices.allow = c 10:237 rwm
    lxc.cgroup.devices.allow = b 7:* rwm
    lxc.apparmor.profile = unconfined
    lxc.mount.auto = proc:rw sys:rw cgroup:rw
  security.nesting: "true"
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
    final_message: "MAAS install complete"
    package_update: true
    package_upgrade: true
    packages: [postgresql, postgresql-contrib, squashfuse, jq, qemu-kvm, ]
    runcmd:
      - set -x
      - curl -sSlL http://resource-server.orangebox.me/v2/auth/store/assertions | snap ack /dev/stdin
      - snap set core proxy.store=5chsmuZltMQH8CxQ1Q0br5T604V7DkkF
      - snap refresh core --edge
      - snap install keepalived --candidate --classic
      - |
    ca-certs:
      trusted: |
        -----BEGIN CERTIFICATE-----
        MIIEAzCCAuugAwIBAgIJANOExur7ucsrMA0GCSqGSIb3DQEBCwUAMIGDMQswCQYD
        VQQGEwJVUzEWMBQGA1UECAwNTWFzc2FjaHVzZXR0czESMBAGA1UEBwwJTGV4aW5n
        dG9uMQ4wDAYDVQQKDAVDZXJ0czEaMBgGA1UECwwRU2VsZi1TaWduZWQgQ2VydHMx
        HDAaBgNVBAMME3NlcnZlci5vcmFuZ2Vib3gubWUwHhcNMTgwOTEzMDM0NzQ0WhcN
        MjgwOTEwMDM0NzQ0WjCBgzELMAkGA1UEBhMCVVMxFjAUBgNVBAgMDU1hc3NhY2h1
        c2V0dHMxEjAQBgNVBAcMCUxleGluZ3RvbjEOMAwGA1UECgwFQ2VydHMxGjAYBgNV
        BAsMEVNlbGYtU2lnbmVkIENlcnRzMRwwGgYDVQQDDBNzZXJ2ZXIub3JhbmdlYm94
        Lm1lMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA50afBPa8nDdWVFh9
        T6zsSs9YTl0hKBOstEbv2JvpIgSd8+DKaW+cMH9OFTeIH0mhyorlzkAmntIg1lKl
        NrHhF8bdB1R3POXpcTg7RonrKSd34u9FJLJ31/8YrObssPxSxxFZq/Wyrdew59S8
        fTVnqxsSAF2JMkJIda5zb9mimHzYlUJ+sHU458K1e3PFPnYudiHITVF8UJhuqEOy
        +bGT4aphAtI3bHZRpkohDd7IysEgeYUPSWYDSpDB5pmFjq9DrOuVdtFCnXYATOCE
        MPNvF96fQkktsqbGg3+kx/lJrjbo65yN38rKFp4UXtDEy+S5E5fxo53d5vsIpLHX
        VEWuKQIDAQABo3gwdjAdBgNVHQ4EFgQUSlWO13/GRZutNi0wFNUrcM8/VYUwHwYD
        VR0jBBgwFoAUSlWO13/GRZutNi0wFNUrcM8/VYUwDwYDVR0TAQH/BAUwAwEB/zAO
        BgNVHQ8BAf8EBAMCAa4wEwYDVR0lBAwwCgYIKwYBBQUHAwEwDQYJKoZIhvcNAQEL
        BQADggEBAA7/d0mYZNgvylWgIlPiQaQ9GJvAlPRwk5q+9DiX+nrLfGqcr+MQlHpJ
        oJcJo38vWsmpmIoMfmGqqNrizxHQdD6hk6qljqaRdg7JPdS05hUsJt9SDZkcrlCc
        dQN006APfo5zg4oj+sci9d4CIM99aTj6JVZd0mmyChc8fJUqLuK1jr/dYo8we6Gf
        njx0CDaDvYj+7GeJnjJEjyPyzQf12xUJ0eE00XjRdcrQ1QPulBMv2yVcybUE8gNG
        0vwBtC/rhcjOc9LwHORBHJFbP4VIK+pTT5MeXRJvaWt+NC8GLUcCUdhM+Rb2uVy3
        0QUX/dAWesc6ErIaRirgBLsOEi2uE7Q=
        -----END CERTIFICATE-----      
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
        deb \$SECURITY \$RELEASE-security main universe restricted multiverse
      sources:
        maas-next-proposed.list:
          source: deb http://ppa.orangebox.me/maas/next-proposed/ubuntu \$RELEASE main
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
    ssh_authorized_keys:
$(find ~/.ssh -iname "*.pub"|xargs -n1 -P1 bash -c 'printf -- "      - %s\n" "$(cat $0)"')
description: lxd profile for HA MAAS
devices:
  eth0:
    name: eth0
    nictype: bridged
    parent: ${LXD_USE_BRIDGE}
    type: nic
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
}

export LXD_IPV4_GW=10.0.0.254
export LXD_DNS='172.27.20.1,8.8.8.8,8.8.4.4'
export LXD_DOMAIN=orangebox.lan
export LXD_TZ='America/Los_Angeles'
export LXD_LANG='en_US.UTF-8'
export LXD_USE_BRIDGE='mbr0'
export LXD_APT_URI=http://ubuntu-archive.orangebox.me/ubuntu
export LXD_SEC_URI=http://ubuntu-archive.orangebox.me/ubuntu
export LXD_IPV4_CIDR=10.0.0.11/24
export LXD_USE_BRIDGE='mbr0'
export LXD_PROFILE_NAME='maas01'
update-lxd-maas-profile
export LXD_IPV4_CIDR=10.0.0.12/24
export LXD_USE_BRIDGE='mbr0'
export LXD_PROFILE_NAME='maas02'
update-lxd-maas-profile
export LXD_IPV4_CIDR=10.0.0.13/24
export LXD_USE_BRIDGE='mbr0'
export LXD_PROFILE_NAME='maas03'
update-lxd-maas-profile
for i in {1..3};do lxc profile assign maas0$i maas0$i;done
