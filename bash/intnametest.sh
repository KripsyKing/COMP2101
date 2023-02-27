#!/bin/bash

interface=$(ifconfig -s | awk '{print$1}' | tail -n 3)

for interface in $interface; do
  if [ $interface="Iface" ];then
	echo "skipping Iface";
  fi
  echo "Interface name: $interface";
  sleep 1;
done
