#!/bin/bash
USERNAME=$1
cd /etc/openvpn/easy-rsa || exit 1

if [ ! -f "pki/issued/$USERNAME.crt" ]; then
    exit 1
fi

# Revoke cert
echo yes | ./easyrsa revoke "$USERNAME"
./easyrsa gen-crl
cp pki/crl.pem /etc/openvpn/crl.pem

rm -f /home/ubuntu/users/$USERNAME.ovpn

echo "User '$USERNAME' revoked."
