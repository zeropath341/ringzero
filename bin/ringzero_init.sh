#!/bin/bash

DEFAULT_FILE="/etc/default/ringzero"

if grep -q "init=1" $DEFAULT_FILE; then

    # set ssid and wpa_pwd
    echo "[*] Set new SSID"
    /usr/local/bin/set_ssid.sh
    systemctl restart hostapd

    # regenerate sshd certs
    echo "[*] Regenerate SSH certificates"
    rm -v /etc/ssh/ssh_host_*
    dpkg-reconfigure openssh-server
    systemctl restart ssh

    echo "init=0" > $DEFAULT_FILE
fi
