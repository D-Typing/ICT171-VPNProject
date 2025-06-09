#!/bin/bash

# Bash script will check if there is a client with the inputted 
# username and if so then it will find and delete the client 
# certificate status along with removing them from the system.

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
