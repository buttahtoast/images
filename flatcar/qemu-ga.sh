#!/bin/sh
if [ ! -f /opt/bin/qemu-ga ]; then
  curl https://raw.githubusercontent.com/chifu1234/qemu-ga/main/qemu-ga -o /opt/bin/qemu-ga
fi
checksum="86abd60bf35bda8a88b9294ed9a4c2fcdcbe44f8b659757de3853b0fa2899510"
if echo "$checksum /opt/bin/qemu-ga" | sha256sum -c - ;then
  chmod +x /opt/bin/qemu-ga
  /opt/bin/qemu-ga 
else
  echo "wrong checksum"
fi
