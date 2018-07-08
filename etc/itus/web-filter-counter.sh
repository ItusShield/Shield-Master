#!/bin/sh
#################################################################################################
# File name  web-filter-counter.sh								#
# Created by Roadrunnere42									#
# version 1											#
# Last Modified 13 August 2017									#
# Files using it	/usr/lib/ula/model/cbi/e2guardian.lua					#
#			/tmp/web_filter_counter.log						#
# Purpose - To check which web filters are selected in the web filter window and write the	#
#	number of ips that each section is blocking to /tmp/web-filter-counter.log		#
#################################################################################################

# write the text to the top of the web_filter_counter.log file and place black line
echo "These are the number of ip addresses that the Shield is blocking in each web filter section that's ticked" > /tmp/web_filter_counter.log
echo \ >>/tmp/web_filter_counter.log

# obtain the web filter that's been selected by check of 1
FILTERS=`grep content_ /etc/config/e2guardian | grep \'1\' | cut -d "_" -f 2 | cut -d ' ' -f 1`
echo "$FILTERS" > /tmp/ramdisk/FILTERS
# create loop
for filter in $(cat /tmp/ramdisk/FILTERS)
do
# counter the number of lines in  each selected web filter list and prints then to file
wc -l /etc/itus/lists/$filter | awk  '{print $filter }' >> /tmp/web_filter_counter.log
echo \ >>/tmp/web_filter_counter.log
done
