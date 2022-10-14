#!/bin/bash

sudo chmod 777 hostname 
cat > /etc/hostanme <<EOF
SRV-LIN-02
EOF
sudo reboot