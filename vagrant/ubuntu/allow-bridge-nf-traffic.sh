#!/bin/bash
modprobe br_netfilter
sysctl -p /etc/sysctl.conf
sysctl net.bridge.bridge-nf-call-iptables=1
