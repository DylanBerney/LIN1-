#!/bin/bash

ip="10.10.10.12/24"
dns1=10.10.10.11
dns2=10.10.10.2
gateway=10.10.10.2
domain="lin1.local"

sudo bash -c 'cat > /etc/hostname <<EOF
SRV-LIN-02
EOF'

sudo bash -c 'cat > /etc/network/interfaces <<EOF
source /etc/network/interfaces.d/*

auto lo
iface lo inet loopback

allow-hotplug ens32
iface ens32 inet static
    address '$ip'
    gateway '$gateway'
    dns-nameservers '$dns1'
    dns-nameservers '$dns2'
    dns-search '$domain'
EOF'

sudo reboot