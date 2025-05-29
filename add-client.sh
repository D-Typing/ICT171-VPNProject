#!/bin/bash
USERNAME=$1
cd /etc/openvpn/easy-rsa
./easyrsa build-client-full $USERNAME nopass
cp /etc/openvpn/client-template.txt /home/ubuntu/users/$USERNAME.ovpn
cat pki/ca.crt >> /home/ubuntu/users/$USERNAME.ovpn
cat pki/issued/$USERNAME.crt >> /home/ubuntu/users/$USERNAME.ovpn
cat pki/private/$USERNAME.key >> /home/ubuntu/users/$USERNAME.ovpn