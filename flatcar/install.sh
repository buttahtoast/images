#!/bin/sh
mount -L CIDATA /mnt
mount -L cidata /mnt
if [ -f "/mnt/user-data" ]; then
  coreos-cloudinit --from-file /mnt/user-data 
fi
