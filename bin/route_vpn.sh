#!/bin/bash

iptables -t nat -F
iptables -t nat -A POSTROUTING -s 172.24.1.96 -o tun1 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 172.24.1.0/24 -o tun0 -j MASQUERADE
#iptables -A FORWARD -i wlan0 -o tun0 -s 192.168.24.0/24 -j ACCEPT
#iptables -A FORWARD -i tun0 -o wlan0 -d 192.168.24.0/24 -j ACCEPT

#ip rule del from all fwmark 1 2>/dev/null
#ip route flush table tbl_net
#ip route add table tbl_net default dev enp0s3 via 10.0.2.2
#ip route add table tbl_net 192.168.24.0/24 dev enp0s8 src 192.168.24.1
#ip route add table tbl_net 10.0.2.0/24 dev enp0s3 src 10.0.2.254
#ip rule add from 10.0.2.2 table tbl_net
#ip rule add fwmark 0x1 table tbl_net

ip rule del from all fwmark 2 2>/dev/null

export TUNIP0=`ifconfig | grep tun0 -A1 | grep "inet " | awk '{print $2}'`
export TUNDEV0=`ifconfig | grep tun0  | cut -f1 -d ":"`
export TUNROUTE0=`route -n | grep tun0 | awk '{ print $1 }'`
ip route flush table tbl_vpn0
ip route add table tbl_vpn0 default dev $TUNDEV0 via $TUNIP0
ip route add table tbl_vpn0 $TUNROUTE0 dev $TUNDEV0 src $TUNIP0
ip route add table tbl_vpn0 172.24.1.0/24 dev wlan0 src 172.24.1.1
#ip route add table tbl_vpn0 10.64.64.64/32 dev ppp0 src 10.64.64.64
ip rule add from $TUNIP0 table tbl_vpn0
ip rule add fwmark 0x2 table tbl_vpn0


export TUNIP1=`ifconfig | grep tun1 -A1 | grep "inet " | awk '{print $2}'`
export TUNDEV1=`ifconfig | grep tun1  | cut -f1 -d ":"`
export TUNROUTE1=`route -n | grep tun1 | awk '{ print $1 }'`
ip route flush table tbl_vpn1
ip route add table tbl_vpn1 default dev $TUNDEV1 via $TUNIP1
ip route add table tbl_vpn1 $TUNROUTE1 dev $TUNDEV1 src $TUNIP1
ip route add table tbl_vpn1 172.24.1.0/24 dev wlan0 src 172.24.1.1
#ip route add table tbl_vpn0 10.64.64.64/32 dev ppp0 src 10.64.64.64
ip rule add from $TUNIP1 table tbl_vpn1
ip rule add fwmark 0x3 table tbl_vpn1
for i in /proc/sys/net/ipv4/conf/*/rp_filter; do echo 0 > "$i"; done


iptables -t mangle -F
iptables -t mangle -X
ip route flush cache
iptables -t mangle -A PREROUTING -s 172.24.1.0/24 -j MARK --set-mark 2
iptables -t mangle -A PREROUTING -s 172.24.1.96 -j MARK --set-mark 3
#iptables -t mangle -A PREROUTING -s 192.168.24.12 -p tcp --dport 80 -j MARK --set-mark 2
iptables -t mangle -A POSTROUTING -j CONNMARK --restore-mark
iptables -t mangle -A POSTROUTING -m mark ! --mark 0 -j ACCEPT
iptables -t mangle -A POSTROUTING -o ppp0 -j MARK --set-mark 1
iptables -t mangle -A POSTROUTING -o $TUNDEV0 -j MARK --set-mark 2
iptables -t mangle -A POSTROUTING -o $TUNDEV1 -j MARK --set-mark 3
iptables -t mangle -A POSTROUTING -s 172.24.1.0/24 -m conntrack --ctstate NEW -j MARK --set-mark 2
iptables -t mangle -A POSTROUTING -s 172.24.1.96 -m conntrack --ctstate NEW -j MARK --set-mark 3
iptables -t mangle -A POSTROUTING -j CONNMARK --save-mark

