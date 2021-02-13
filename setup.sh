#!/bin/bash

declare error

if [[ $EUID -ne 0 ]]; then
   echo 'NaClShuttle: This script must be run as root.'
   exit 1
fi

function echo_error
{
  echo -n 'NaClShuttle: [ERROR] '
  echo $1
  error=true
}

if [ $1 = '-S' ] || [ $1 = '-s' ]; then
  echo 'NaClShuttle: Setting up network settings... '
  echo 1 > /proc/sys/net/ipv4/ip_forward >/dev/null 2>&1 || echo_error 'Failed to enable IP forwarding.'
  iptables -t nat -A POSTROUTING -j MASQUERADE >/dev/null 2>&1 || echo_error 'Failed to setup iptables.'
  echo 'NaClShuttle: Creating TAP device... '
  ip tuntap add tap0 mode tap > /dev/null 2>&1 || echo_error 'Failed to create TAP device. Does it already exist?'
  ifconfig tap0 10.8.0.1/24 > /dev/null 2>&1 || echo_error 'Failed to configure TAP device. Does the TAP device exist?'
  echo -n 'NaClShuttle: NaClShuttle setup completed'
  if [ "$error" = true ]; then
    echo ' with errors, check output above.'
  else
    echo '.'
  fi
fi
