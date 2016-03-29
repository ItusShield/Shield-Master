#!/bin/bash

BLACKLIST=/etc/itus/lists/black.list

# Remove blank lines
sed -i '/^$/d' $BLACKLIST

# Remove quotation marks
sed -i 's/"//g' $BLACKLIST
 
ip=$(uci get network.blockdomain.ipaddr)
while read -r line || [[ -n "$line" ]]; do
        ADDRESS="/${line}/${ip}"
        echo "address=${ADDRESS}" >> /etc/ITUS_DNS.txt
done < "$1"
