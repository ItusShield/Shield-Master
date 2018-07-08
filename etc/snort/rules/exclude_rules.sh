#!/bin/bash
#################################################################################################
# version 1											#
# Created by Roadrunnere42 									#
# Modified : 13th August 2017									#
# Called by /usr/lib/lua/luci/model/cbi/snort.lua						#
#################################################################################################
EXCLUDE_RULES=/etc/snort/rules/exclude.rules
SNORT_RULES=/etc/snort/rules/snort.rules

# Remove all blank lines
sed -i '/^$/d' $EXCLUDE_RULES

# Remove all non-numeric entries
sed -i '/[^0-9]/d' $EXCLUDE_RULES

# Remove all blanks so gui accepts list properly
sed -r 's/\s//g' $EXCLUDE_RULES

while read -r line || [[ -n "$line" ]]; do
	sed -i '/sid:'$line'/d' $SNORT_RULES
done < $EXCLUDE_RULES
