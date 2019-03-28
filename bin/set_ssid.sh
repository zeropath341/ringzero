#!/bin/bash

HOSTAPD_CONF="/etc/hostapd/hostapd.conf"
PREFIX=OPTUN

# ssid from wlan0 mac address
SUFFIX=`ifconfig wlan0 | grep ether | awk '{print $2}' | cut -d ":" -f 4,5,6 | tr -d :`
SSID=$PREFIX-${SUFFIX^^}

# wpa pass from revision and serial
REV=`cat /proc/cpuinfo | grep Revision | cut -d ' ' -f 2`
SERIAL=`cat /proc/cpuinfo | grep Serial | cut -d ' ' -f 2`
WPAPWD=${REV}$(echo $SERIAL | sed 's/^0*//')

# replace hostapd.conf
sed -i -e "s/^ssid=.*/ssid=$SSID/g" $HOSTAPD_CONF
sed -i -e "s/^wpa_passphrase=.*/wpa_passphrase=${WPAPWD^^}/g" $HOSTAPD_CONF

