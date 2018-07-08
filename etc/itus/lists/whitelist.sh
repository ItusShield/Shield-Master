#!/bin/bash
# whitelist.sh
# modified by roadrunnere42
# removes blanks lines, whitespaces at begining and end of entre and www.
# removes duplicated entres after whitelist been added to itus_dns.txt

WHITELIST=/etc/itus/lists/white.list
# Remove blank lines
sed -i '/^$/d' $WHITELIST

# Remove whirespaces at begin of line
sed -i 's/^ *//' $WHITELIST

# Remove www. at begin of line
sed -i 's/^www.*//' $WHITELIST

while read -r line || [[ -n "$line" ]]; do
        sed -i '/'$line'/d' /etc/ITUS_DNS.txt
done < "$1"

#removes duplicate lines
awk '!a[$0]++' /etc/ITUS_DNS.txt
#sed -i '$!N; /^\(.*\)\n\1$/!P; D' /etc/ITUS_DNS.txt
