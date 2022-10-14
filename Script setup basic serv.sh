#!/bin/bash

sudo chmod hostname 777
cat > /etc/hostanme <<EOF
SRV-LIN-02
EOF
sudo reboot