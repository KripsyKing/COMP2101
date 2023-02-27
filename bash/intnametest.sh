#!/bin/bash

interface=$(ifconfig -s | awk '{print$1}')

for interface in $interface; do
  if [ $interface="Iface" ];then
	echo "skipping Iface";
  fi
  echo "Interface name: $interface";
  sleep 1;
done
