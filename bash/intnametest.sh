#!/bin/bash

interface=$(ifconfig -s | awk '{print$1}')

for interface in $interface; do
  echo "Interface name: $interface";
  sleep 3;
  if [ $interface="Iface" ];then
	echo "skipping Iface";
  fi
done
