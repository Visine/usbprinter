#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user" 2>&1
  me=`basename $0`
  sudo "./$me"
  exit 0
fi

bname="/etc/cups.bak"
if [[ -e $bname ]] ; then
    i=1
    while [[ -e $bname.$i ]] ; do
        let i++
    done
    bname=$bname.$i
fi

cp -R /etc/cups $bname

wget https://github.com/Visine/usbprinter/raw/master/usbprinter.tar.gz -P /tmp/

service cups stop

tar xpvzf /tmp/usbprinter.tar.gz -C /
rm /tmp/usbprinter.tar.gz
sed -i -e  's/DeviceURI.*$/DeviceURI usbprinter:\/dev\/usb\/printer/g' /etc/cups/printers.conf
udevadm control --reload
udevadm trigger --action=add

service cups start

if [[ ! -e /dev/usb/printer ]];
    shutdown -r +2
fi