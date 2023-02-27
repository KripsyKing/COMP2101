#!/bin/bash

interface=$(ifconfig -s | awk '{print$1}')

for interface in $interface; do
  sleep 1;
  if [ $interface="Iface" ];then
	echo "skipping Iface";
  fi
done
