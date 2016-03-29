#!/bin/bash

EXCLUDE_RULES=/etc/snort/rules/exclude.rules
SNORT_RULES=/etc/snort/rules/snort.rules

# Remove all blank lines
sed -i '/^$/d' $EXCLUDE_RULES

# Remove all non-numeric entries
sed -i '/[^0-9]/d' $EXCLUDE_RULES

while read -r line || [[ -n "$line" ]]; do
        sed -i '/sid:'$line'/d' $SNORT_RULES
done < $EXCLUDE_RULES
