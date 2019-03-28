#!/bin/bash
DT=`date "+%Y-%m-%d %H:%M:%S %Z"`

echo "[+] Timestamp: $DT"
echo "[-] Signal Info:"
sudo qmicli -d /dev/cdc-wdm0 --nas-get-signal-info
echo "[-] IP Info:"
curl ipinfo.io
echo
echo "[-] Speed Test:"
speedtest --simple
