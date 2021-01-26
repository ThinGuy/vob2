cat <<EOF|lxc network edit airstack-br0
config:
  ipv4.address: 10.0.0.254/24
  ipv4.nat: "true"
  ipv6.address: none
  dns.mode: dynamic
  ipv4.dhcp: false
managed: false
name: airstack-br0
type: "bridge"
raw.dnsmasq: |-
  domain=airstack
  server=/airstack/10.0.0.11
  local=/airstack/
EOF

cat <<EOF|lxc network edit airstack-br1
config:
  ipv4.address: 172.16.0.254/24
  ipv4.nat: "true"
  ipv6.address: none
  dns.mode: dynamic
  ipv4.dhcp: false
  ipv4.routing: true
description: ""
managed: false
name: airstack-br1
type: "bridge"
raw.dnsmasq: "domain=maas server=/maas/10.0.0.11 local=/maas/"
EOF

cat <<EOF|lxc network edit airstack-br2
config:
  ipv4.address: 192.168.0.254/24
  ipv4.nat: "true"
  ipv6.address: none
  dns.mode: dynamic
  ipv4.dhcp: false
  ipv4.routing: true
description: ""
managed: false
name: airstack-br2
type: "bridge"
raw.dnsmasq: "domain=maas server=/maas/10.0.0.11 local=/maas/"
EOF
