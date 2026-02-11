#!/usr/bin/env bash
set -euo pipefail

# Your username
USER="USER"

# Your path to tun2socks
TUN2SOCKS="/opt/tun2socks/tun2socks"

# Your socks proxy
SOCKS_PORT="1080"
SOCKS="10.200.200.1:$SOCKS_PORT"

# Custom namespace name
NS="proxy"

# Veth pair names
VETH0="veth_proxy0"
VETH1="veth_proxy1"

# Veth addresses
# Make sure they are in the same subnet
# and Host veth matches with socks addr
VETH0_ADDR="10.200.200.1/24"
VETH1_ADDR="10.200.200.2/24"

handler() {
    ip netns delete "$NS"
    ip link delete "$VETH0"
}

trap handler EXIT

ip netns add "$NS"

ip link add "$VETH0" type veth peer name "$VETH1"
ip link set "$VETH1" netns proxy

ip addr add "$VETH0_ADDR" dev "$VETH0"
ip link set "$VETH0" up

ip -n "$NS" addr add "$VETH1_ADDR" dev "$VETH1"
ip -n "$NS" link set "$VETH1" up
ip -n "$NS" link set lo up

ip -n "$NS" tuntap add dev tun0 mode tun
ip -n "$NS" addr add 10.0.0.1/24 dev tun0
ip -n "$NS" link set tun0 up
ip -n "$NS" route add default via 10.0.0.1 dev tun0

nsenter --net=/var/run/netns/"$NS" sudo -u "$USER" "$TUN2SOCKS" -device tun0 -proxy socks5://"$SOCKS"
