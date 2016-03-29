#!/bin/bash
while read -r line || [[ -n "$line" ]]; do
        sed -i '/'$line'/d' /etc/ITUS_DNS.txt
done < "$1"
