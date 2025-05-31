#!/bin/bash
USERNAME=$1
cd /etc/openvpn/easy-rsa
echo yes | ./easyrsa revoke $USERNAME
./easyrsa gen-crl
cp pki/crl.pem /etc/openvpn/crl.pem