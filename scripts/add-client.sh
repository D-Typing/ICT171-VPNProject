#!/bin/bash

USERNAME=$1
cd /etc/openvpn/easy-rsa || exit 1

if [[ -f "pki/issued/$USERNAME.crt" ]]; then
    echo "[!] Certificate for user '$USERNAME' already exists. Overwriting..."
    echo yes | ./easyrsa --batch build-client-full "$USERNAME" nopass
else
    ./easyrsa --batch build-client-full "$USERNAME" nopass
fi

OVPN_FILE="/home/ubuntu/users/$USERNAME.ovpn"
cp /etc/openvpn/client-template.txt "$OVPN_FILE"
cat pki/ca.crt >> "$OVPN_FILE"
cat pki/issued/$USERNAME.crt >> "$OVPN_FILE"
cat pki/private/$USERNAME.key >> "$OVPN_FILE"

echo "[+] Configuration for '$USERNAME' created at $OVPN_FILE"
