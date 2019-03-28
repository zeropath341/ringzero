#!/bin/bash

iptables -t nat -A POSTROUTING -s 172.24.1.0/24 -o tun0 -j MASQUERADE

ip rule del from all fwmark 2 2>/dev/null

export TUNIP0=`ifconfig | grep tun0 -A1 | grep "inet " | awk '{print $2}'`
export TUNDEV0=`ifconfig | grep tun0  | cut -f1 -d ":"`
export TUNROUTE0=`route -n | grep tun0 | awk '{ print $1 }'`
ip route flush table tbl_vpn0
ip route add table tbl_vpn0 default dev $TUNDEV0 via $TUNIP0
ip route add table tbl_vpn0 $TUNROUTE0 dev $TUNDEV0 src $TUNIP0
ip route add table tbl_vpn0 172.24.1.0/24 dev wlan0 src 172.24.1.1
ip rule add from $TUNIP0 table tbl_vpn0
ip rule add fwmark 0x2 table tbl_vpn0


iptables -t mangle -F
iptables -t mangle -X
ip route flush cache
iptables -t mangle -A PREROUTING -s 172.24.1.0/24 -j MARK --set-mark 2
iptables -t mangle -A POSTROUTING -j CONNMARK --restore-mark
iptables -t mangle -A POSTROUTING -m mark ! --mark 0 -j ACCEPT
iptables -t mangle -A POSTROUTING -o $TUNDEV0 -j MARK --set-mark 2
iptables -t mangle -A POSTROUTING -s 172.24.1.0/24 -m conntrack --ctstate NEW -j MARK --set-mark 2
iptables -t mangle -A POSTROUTING -j CONNMARK --save-mark

